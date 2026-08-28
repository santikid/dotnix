#include <errno.h>
#include <fcntl.h>
#include <glob.h>
#include <linux/hidraw.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

enum {
    REPORT_SIZE = 91,
    RESPONSE_SIZE = 91,
    STATUS_SUCCESS = 0x02,
    COMMAND_CLASS_POWER = 0x0d,
};

struct response {
    uint8_t bytes[RESPONSE_SIZE];
};

static uint8_t crc(const uint8_t *packet) {
    uint8_t value = 0;
    for (size_t i = 2; i <= 88; ++i)
        value ^= packet[i];
    return value;
}

static int transact(int fd, uint8_t command_id, uint8_t data_size,
                    const uint8_t *args, struct response *response) {
    uint8_t request[REPORT_SIZE] = {0};
    request[2] = 0x1f; /* transaction ID */
    request[6] = data_size;
    request[7] = COMMAND_CLASS_POWER;
    request[8] = command_id;
    memcpy(&request[9], args, data_size);
    request[89] = crc(request);

    for (int attempt = 0; attempt < 3; ++attempt) {
        if (ioctl(fd, HIDIOCSFEATURE(REPORT_SIZE), request) < 0)
            return -1;

        usleep(1000);
        memset(response, 0, sizeof(*response));
        response->bytes[0] = 0; /* feature report ID */
        if (ioctl(fd, HIDIOCGFEATURE(RESPONSE_SIZE), response->bytes) < 0)
            return -1;

        const uint8_t *r = response->bytes;
        if (r[1] == 0x01) { /* busy */
            usleep(8000);
            continue;
        }
        if (r[1] != STATUS_SUCCESS || r[7] != COMMAND_CLASS_POWER ||
            r[8] != command_id) {
            errno = EPROTO;
            return -1;
        }
        return 0;
    }

    errno = EBUSY;
    return -1;
}

static bool is_target(const char *device) {
    const char *name = strrchr(device, '/');
    if (!name)
        return false;

    char path[256];
    snprintf(path, sizeof(path), "/sys/class/hidraw/%s/device/uevent", name + 1);
    FILE *file = fopen(path, "r");
    if (!file)
        return false;

    bool match = false;
    char line[256];
    while (fgets(line, sizeof(line), file)) {
        if (strstr(line, "HID_ID=") && strstr(line, ":00001532:00000276")) {
            match = true;
            break;
        }
    }
    fclose(file);
    return match;
}

static int get_power(int fd, uint8_t zone, uint8_t *mode) {
    const uint8_t args[] = {0x00, zone, 0x00, 0x00};
    struct response response;
    if (transact(fd, 0x82, sizeof(args), args, &response) < 0)
        return -1;
    *mode = response.bytes[11];
    return 0;
}

static int get_boost(int fd, uint8_t zone, uint8_t *level) {
    const uint8_t args[] = {0x00, zone, 0x00};
    struct response response;
    if (transact(fd, 0x87, sizeof(args), args, &response) < 0)
        return -1;
    *level = response.bytes[11];
    return 0;
}

static int set_power(int fd, uint8_t zone, uint8_t mode, bool manual_fan) {
    const uint8_t args[] = {0x00, zone, mode, manual_fan ? 0x01 : 0x00};
    struct response response;
    return transact(fd, 0x02, sizeof(args), args, &response);
}

static int set_boost(int fd, uint8_t zone, uint8_t level) {
    const uint8_t args[] = {0x00, zone, level};
    struct response response;
    return transact(fd, 0x07, sizeof(args), args, &response);
}

static int set_fan(int fd, uint8_t zone, uint16_t rpm) {
    const uint8_t args[] = {0x00, zone, (uint8_t)(rpm / 100)};
    struct response response;
    return transact(fd, 0x01, sizeof(args), args, &response);
}

static const char *power_name(uint8_t mode) {
    static const char *names[] = {"balanced", "gaming", "creator", "silent", "custom"};
    return mode < sizeof(names) / sizeof(names[0]) ? names[mode] : "unknown";
}

static const char *cpu_name(uint8_t level) {
    static const char *names[] = {"low", "medium", "high", "boost"};
    return level < sizeof(names) / sizeof(names[0]) ? names[level] : "unknown";
}

static const char *gpu_name(uint8_t level) {
    static const char *names[] = {"low", "medium", "high"};
    return level < sizeof(names) / sizeof(names[0]) ? names[level] : "unknown";
}

static int show_status(int fd) {
    uint8_t cpu_mode, gpu_mode, cpu_boost, gpu_boost;
    if (get_power(fd, 1, &cpu_mode) || get_power(fd, 2, &gpu_mode) ||
        get_boost(fd, 1, &cpu_boost) || get_boost(fd, 2, &gpu_boost))
        return -1;

    printf("CPU zone: %s; CPU boost: %s\n", power_name(cpu_mode), cpu_name(cpu_boost));
    printf("GPU zone: %s; GPU boost: %s\n", power_name(gpu_mode), gpu_name(gpu_boost));
    return 0;
}

static int apply_action(int fd, const char *action) {
    if (!strcmp(action, "status"))
        return show_status(fd);

    if (!strcmp(action, "balanced") || !strcmp(action, "gaming")) {
        uint8_t mode = !strcmp(action, "gaming") ? 1 : 0;
        return set_power(fd, 1, mode, false) || set_power(fd, 2, mode, false);
    }

    if (!strcmp(action, "custom-max")) {
        return set_power(fd, 1, 4, false) || set_boost(fd, 1, 3) ||
               set_boost(fd, 2, 2) || set_power(fd, 2, 4, false);
    }

    if (!strcmp(action, "gaming-max-fans")) {
        return set_power(fd, 1, 1, true) || set_power(fd, 2, 1, true) ||
               set_fan(fd, 1, 5000) || set_fan(fd, 2, 5000);
    }

    if (!strcmp(action, "fan-auto")) {
        uint8_t cpu_mode, gpu_mode;
        if (get_power(fd, 1, &cpu_mode) || get_power(fd, 2, &gpu_mode))
            return -1;
        return set_power(fd, 1, cpu_mode, false) ||
               set_power(fd, 2, gpu_mode, false);
    }

    errno = EINVAL;
    return -1;
}

static void usage(const char *program) {
    fprintf(stderr,
            "Usage: %s status|balanced|gaming|custom-max|gaming-max-fans|fan-auto\n",
            program);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        usage(argv[0]);
        return 2;
    }

    glob_t devices;
    if (glob("/dev/hidraw*", 0, NULL, &devices) != 0) {
        fprintf(stderr, "No hidraw devices found\n");
        return 1;
    }

    int result = 1;
    for (size_t i = 0; i < devices.gl_pathc; ++i) {
        const char *path = devices.gl_pathv[i];
        if (!is_target(path))
            continue;

        int fd = open(path, O_RDWR | O_CLOEXEC);
        if (fd < 0) {
            fprintf(stderr, "%s: open failed: %s\n", path, strerror(errno));
            continue;
        }

        uint8_t mode;
        if (get_power(fd, 1, &mode) == 0) {
            if (apply_action(fd, argv[1]) == 0) {
                printf("Razer Blade controller: %s applied via %s\n", argv[1], path);
                if (strcmp(argv[1], "status") != 0 && show_status(fd) < 0)
                    perror("Could not verify resulting status");
                result = 0;
            } else {
                perror("Razer EC command failed");
            }
            close(fd);
            break;
        }
        fprintf(stderr, "%s: power-profile probe failed: %s\n", path, strerror(errno));
        close(fd);
    }

    globfree(&devices);
    if (result)
        fprintf(stderr, "No responsive Razer Blade 15 (1532:0276) HID interface found\n");
    return result;
}

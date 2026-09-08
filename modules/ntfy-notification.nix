# Notification setup shared by peer checks and maintenance alerts. Callers provide
# coreutils and curl through writeShellApplication.runtimeInputs.
{
  lib,
  topicFile,
  baseUrl,
  timeoutSeconds ? 15,
}: ''
  topic_file=${lib.escapeShellArg (toString topicFile)}
  if [[ ! -r $topic_file ]]; then
    echo "ntfy: cannot read topic file $topic_file" >&2
    exit 1
  fi
  ntfy_topic=$(tr -d '\r\n' < "$topic_file")
  if [[ ! $ntfy_topic =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "ntfy: topic is empty or contains invalid characters" >&2
    exit 65
  fi
  ntfy_url=${lib.escapeShellArg (lib.removeSuffix "/" baseUrl)}/$ntfy_topic

  send_ntfy() {
    # Keep the private topic out of process arguments.
    printf 'url = "%s"\n' "$ntfy_url" | curl \
      --config - \
      --fail --silent --show-error \
      --connect-timeout 5 \
      --max-time ${toString timeoutSeconds} \
      --retry 2 --retry-all-errors --retry-delay 2 \
      --header "Title: $1" \
      --header "Tags: $2" \
      --header "Priority: $3" \
      --data-raw "$4" \
      --output /dev/null
  }
''

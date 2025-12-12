;;; early-init.el --- Early initialization -*- lexical-binding: t -*-

;; Increase GC threshold during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Disable package.el in favor of straight.el
(setq package-enable-at-startup nil)

;; Disable unnecessary UI elements early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Better font rendering on macOS
(setq mac-allow-anti-aliasing t)
(push '(font . "Iosevka-14") default-frame-alist)
(push '(ns-transparent-titlebar . t) default-frame-alist)
(push '(ns-appearance . dark) default-frame-alist)

;; Faster loading
(setq frame-inhibit-implied-resize t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Native compilation settings
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil)
  (setq native-comp-deferred-compilation t))

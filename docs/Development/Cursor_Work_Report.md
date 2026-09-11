# Cursor Work Report

## Task

Student Profilo: centered identity card, read-only phone / birth date / address, password change, device list, language, local push toggle.

## What changed

- Identity column is centered (`textAlign` + full-width column).
- Read-only personal data from `/me`.
- Password / devices call new account APIs. Language and push are stored locally (app strings stay Italian; push does not send).
- Tests cover contact parse + profile rows.

## Commands

`flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.

# Contributing

## Development requirements

- Xcode 14 or newer with Swift 5.7+.
- Supported deployment targets: iOS 13.0+ and macOS 10.15+.
- `swift-format` for local formatting, using the repository `.swift-format` configuration.

## Before opening a pull request

Run the same checks as CI:

```sh
git diff --check
swift format lint --recursive --strict Package.swift Sources Tests neumorphic-examples/Shared
swift test --scratch-path .build/macos
swift build --target Neumorphic --scratch-path .build/macos-minimum --sdk "$(xcrun --sdk macosx --show-sdk-path)" --triple x86_64-apple-macosx10.15
swift build --scratch-path .build/ios --sdk "$(xcrun --sdk iphoneos --show-sdk-path)" --triple arm64-apple-ios13.0
swiftc -typecheck -swift-version 6 -strict-concurrency=complete -target arm64-apple-macosx14.0 -module-name Neumorphic Sources/Neumorphic/*.swift
swift package diagnose-api-breaking-changes v2.1.0 --products Neumorphic
```

When changing documentation, also validate the DocC catalog:

```sh
docc_temp_dir="$(mktemp -d)"
docc_symbols_dir="${docc_temp_dir:?}/symbol-graphs"
docc_archive_path="${docc_temp_dir:?}/Neumorphic.doccarchive"
mkdir -p "$docc_symbols_dir"
swift build --target Neumorphic --scratch-path .build/docc \
  -Xswiftc -emit-symbol-graph \
  -Xswiftc -emit-symbol-graph-dir \
  -Xswiftc "$docc_symbols_dir"
xcrun docc convert Sources/Neumorphic/Neumorphic.docc \
  --additional-symbol-graph-dir "$docc_symbols_dir" \
  --fallback-display-name Neumorphic \
  --fallback-bundle-identifier com.gewill.neumorphic \
  --output-path "$docc_archive_path" \
  --warnings-as-errors
```

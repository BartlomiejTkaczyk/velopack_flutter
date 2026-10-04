# Capturo maintenance fork

Based on upstream `GigaDroid/velopack_flutter` version 0.3.2, commit
`402a796c15e57570034c084b86e52f98527671c5`. The upstream MIT license is retained.

The only behavior change is in `hook/build.dart`: return successfully when
`input.config.buildCodeAssets` is false, before accessing `input.config.code`.
Flutter's debug asset synchronization can invoke the hook with no requested
asset types and no code configuration. Upstream 0.3.2 dereferences that missing
configuration and terminates the Flutter debug session while the app stays open.
Native builds still use the original Rust builder and platform checks.

`test/build_hook_test.dart` reproduces the empty asset request and checks that
the hook writes a successful output with no assets. Run it with:

```sh
flutter test test/build_hook_test.dart
```

Capturo pins this fork to a commit SHA. Keep changes minimal; when an upstream
release includes this guard, verify debug startup and hot reload, then switch
Capturo back to the published package. Do not update the fork automatically.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks/hooks.dart';

import '../hook/build.dart' as build_hook;

void main() {
  test('build hook succeeds when no native code assets are requested',
      () async {
    final directory = await Directory.systemTemp.createTemp('velopack_hook_');
    addTearDown(() => directory.delete(recursive: true));

    final outputFile = directory.uri.resolve('output.json');
    final sharedDirectory = directory.uri.resolve('shared/');
    await Directory.fromUri(sharedDirectory).create();

    final builder = BuildInputBuilder();
    builder
      ..setupShared(
        packageRoot: Directory.current.uri,
        packageName: 'velopack_flutter',
        outputFile: outputFile,
        outputDirectoryShared: sharedDirectory,
      )
      ..setupBuildInput()
      ..config.setupBuild(linkingEnabled: false);

    // Reproduce Flutter's asset sync invocation: no asset types or code config.
    final inputFile = File.fromUri(directory.uri.resolve('input.json'));
    await inputFile.writeAsString(jsonEncode(builder.build().json));

    await build_hook.main(['--config=${inputFile.path}']);

    final output = BuildOutputMaybeFailure(
      jsonDecode(await File.fromUri(outputFile).readAsString())
          as Map<String, Object?>,
    );
    expect(output, isA<BuildOutput>());
    expect((output as BuildOutput).assets.encodedAssets, isEmpty);
  });
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter_ffmpeg/ffi.dart';
import 'package:flutter_ffmpeg/ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('make', () async {
    final utf8Encoding = Encoding.getByName('utf-8');
    var cmakePath = 'cmake';
    if (Platform.isWindows) {
      var vsDir = Directory('C:/Program Files (x86)/Microsoft Visual Studio/');
      vsDir = (vsDir.listSync().firstWhere((e) => e is Directory) as Directory)
          .listSync()
          .last as Directory;
      cmakePath = vsDir.path +
          '/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/cmake.exe';
    }
    final buildDir = './build';
    var result = Process.runSync(
      cmakePath,
      ['-S', './', '-B', buildDir],
      workingDirectory: 'test',
      stdoutEncoding: utf8Encoding,
      stderrEncoding: utf8Encoding,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    expect(result.exitCode, 0);

    result = Process.runSync(
      cmakePath,
      ['--build', buildDir, '--verbose'],
      workingDirectory: 'test',
      stdoutEncoding: utf8Encoding,
      stderrEncoding: utf8Encoding,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    expect(result.exitCode, 0);
  });
  test('changeDirectory', () async {
    Directory.current = './test/build/Debug';
  });
  test('avformat', () async {
    final ctx = FormatContext('D:\\CloudMusic\\seven oops - オレンジ.flac');
    final astream = ctx.getStreamInfo().firstWhere(
        (infos) => infos.codecType == AVMediaType.AVMEDIA_TYPE_AUDIO);
    await ctx.play([astream]);
  });
}

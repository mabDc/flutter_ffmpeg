import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/ffi.dart';
import 'package:flutter_ffmpeg/texture.dart';
import 'package:flutter_ffmpeg/ffmpeg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterTexture _texture = FlutterTexture();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Stack(
            children: [
              FutureBuilder(
                future: _texture.getTextureId(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) return Container();
                  return Texture(textureId: snapshot.data);
                },
              ),
              FloatingActionButton(onPressed: () async {
                final ctx = FormatContext('D:\\Downloads\\System\\big_buck_bunny.mp4');
                final stream = ctx.getStreamInfo().firstWhere((infos) => infos.codecType == AVMediaType.AVMEDIA_TYPE_VIDEO);
                final frame = stream.codec.createFrame(AVPixelFormat.AV_PIX_FMT_RGBA);
                await _texture.attatchBuffer(frame.buffer, frame.width, frame.height);
                await ctx.play(stream, frame, () {
                  _texture.onFrame();
                });
              })
            ],
          )),
    );
  }
}

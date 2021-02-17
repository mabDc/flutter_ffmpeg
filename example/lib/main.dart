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

  TextEditingController _controller = TextEditingController(
    text: 'D:\\Downloads\\System\\big_buck_bunny.mp4',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        type: MaterialType.canvas,
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                ),
              ),
              TextButton(
                child: Text("play"),
                onPressed: () async {
                  final ctx = FormatContext(_controller.text);
                  final astream = ctx.getStreamInfo().firstWhere((infos) =>
                      infos.codecType == AVMediaType.AVMEDIA_TYPE_AUDIO);
                  final vstream = ctx.getStreamInfo().firstWhere((infos) =>
                      infos.codecType == AVMediaType.AVMEDIA_TYPE_VIDEO);
                  final frame = (vstream.codec as VideoCodecContext)
                      .createFrame(AV_PIX_FMT_RGBA, () {
                    _texture.onFrame();
                  });
                  await _texture.attatchBuffer(
                      frame.buffer, frame.width, frame.height);
                  await ctx.play([astream, vstream]);
                },
              )
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _texture.getTextureId(),
              builder: (ctx, snapshot) {
                if (snapshot.data == null) return Container();
                return Texture(textureId: snapshot.data);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
                  final ctx = IsolateFormatContext(_controller.text);
                  final streams = await ctx.getStreams();
                  final astream = streams.firstWhere((infos) =>
                      infos.codecType == AVMediaType.AVMEDIA_TYPE_AUDIO);
                  final vstream = streams.firstWhere((infos) =>
                      infos.codecType == AVMediaType.AVMEDIA_TYPE_VIDEO);
                  final frame = await ctx.createFrame(vstream, () {
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

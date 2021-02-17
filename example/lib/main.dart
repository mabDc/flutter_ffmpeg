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
  IsolateFormatContext _lastCtx;

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
                  if (_lastCtx != null) _lastCtx.close();
                  _lastCtx = IsolateFormatContext(_controller.text);
                  final ctx = _lastCtx;
                  final streams = await ctx.getStreams();
                  final playStream = <IsolateFfmpegStream>[];
                  final astream = streams.firstWhere(
                      (infos) =>
                          infos.codecType == AVMediaType.AVMEDIA_TYPE_AUDIO,
                      orElse: () => null);
                  if (astream != null) playStream.add(astream);
                  final vstream = streams.firstWhere(
                      (infos) =>
                          infos.codecType == AVMediaType.AVMEDIA_TYPE_VIDEO,
                      orElse: () => null);
                  if (vstream != null) {
                    playStream.add(vstream);
                    final frame = await ctx.createFrame(vstream, () {
                      _texture.onFrame();
                    });
                    await _texture.attatchBuffer(
                        frame.buffer, frame.width, frame.height);
                  }
                  await ctx.play(playStream);
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

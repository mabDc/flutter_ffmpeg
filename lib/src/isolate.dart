part of 'package:flutter_ffmpeg/ffmpeg.dart';

typedef _DecodeFunc = dynamic Function(Map);

abstract class _IsolateEncodable {
  Map _encode();
}

class IsolateError extends _IsolateEncodable {
  String message;
  String stack;
  IsolateError(message, [stack]) {
    if (message is IsolateError) {
      this.message = message.message;
      this.stack = message.stack;
    } else {
      this.message = message.toString();
      this.stack = (stack ?? StackTrace.current).toString();
    }
  }

  @override
  String toString() {
    return stack == null ? message.toString() : "$message\n$stack";
  }

  static IsolateError _decode(Map obj) {
    if (obj.containsKey(#jsError))
      return IsolateError(obj[#jsError], obj[#jsErrorStack]);
    return null;
  }

  @override
  Map _encode() {
    return {
      #jsError: message,
      #jsErrorStack: stack,
    };
  }
}

class IsolateFunction implements _IsolateEncodable {
  int _isolateId;
  SendPort _port;
  Function(dynamic) _invokable;
  IsolateFunction._fromId(this._isolateId, this._port);

  IsolateFunction._new(this._invokable) {
    _handlers.add(this);
  }

  static ReceivePort _invokeHandler;
  static Set<IsolateFunction> _handlers = Set();

  static get _handlePort {
    if (_invokeHandler == null) {
      _invokeHandler = ReceivePort();
      _invokeHandler.listen((msg) async {
        final msgPort = msg[#port];
        try {
          final handler = _handlers.firstWhere(
            (v) => identityHashCode(v) == msg[#handler],
            orElse: () => null,
          );
          if (handler == null) throw Exception('handler released');
          final ret = _encodeData(await handler._handle(msg[#msg]));
          if (msgPort != null) msgPort.send(ret);
        } catch (e, stack) {
          final err = _encodeData(IsolateError(e, stack));
          if (msgPort != null)
            msgPort.send({
              #error: err,
            });
        }
      });
    }
    return _invokeHandler.sendPort;
  }

  _send(msg) async {
    if (_port == null) return _handle(msg);
    final evaluatePort = ReceivePort();
    _port.send({
      #handler: _isolateId,
      #msg: msg,
      #port: evaluatePort.sendPort,
    });
    final result = await evaluatePort.first;
    if (result is Map && result.containsKey(#error))
      throw _decodeData(result[#error], _isolateDecoders);
    return _decodeData(result, _isolateDecoders);
  }

  _destroy() {
    _handlers.remove(this);
  }

  _handle(msg) async {
    switch (msg) {
      case #dup:
        _refCount++;
        return null;
      case #free:
        _refCount--;
        if (_refCount < 0) _destroy();
        return null;
      case #destroy:
        _destroy();
        return null;
    }
    final args = _decodeData(msg[#args], _isolateDecoders);
    return _invokable(args);
  }

  @override
  Future call(dynamic positionalArguments) async {
    return _send({
      #args: _encodeData(positionalArguments),
    });
  }

  static IsolateFunction _decode(Map obj) {
    if (obj.containsKey(#jsFunctionPort))
      return IsolateFunction._fromId(
        obj[#jsFunctionId],
        obj[#jsFunctionPort],
      );
    return null;
  }

  @override
  Map _encode() {
    return {
      #jsFunctionId: _isolateId ?? identityHashCode(this),
      #jsFunctionPort: _port ?? IsolateFunction._handlePort,
    };
  }

  int _refCount = 0;

  dup() {
    _send(#dup);
  }

  free() {
    _send(#free);
  }

  void destroy() {
    _send(#destroy);
  }
}

class IsolateFrame {
  final int width;
  final int height;
  final Pointer<Uint8> buffer;
  IsolateFrame._new(this.width, this.height, int buffer)
      : buffer = Pointer.fromAddress(buffer);

  static IsolateFrame _decode(Map data) {
    if (data[#frameBuffer] != null)
      return IsolateFrame._new(
        data[#frameWidth],
        data[#frameHeight],
        data[#frameBuffer],
      );
    return null;
  }
}

class IsolateFfmpegStream implements _IsolateEncodable {
  final int index;
  final int codecType;
  IsolateFfmpegStream._new(this.index, this.codecType);

  @override
  Map _encode() => {
        #streamIndexIsolate: index,
      };

  static IsolateFfmpegStream _decode(Map data) {
    if (data[#streamIndex] != null)
      return IsolateFfmpegStream._new(
        data[#streamIndex],
        data[#streamCodecType],
      );
    return null;
  }
}

dynamic _encodeData(data, {Map<dynamic, dynamic> cache}) {
  if (cache == null) cache = Map();
  if (cache.containsKey(data)) return cache[data];
  if (data is _IsolateEncodable) return data._encode();
  if (data is List) {
    final ret = [];
    cache[data] = ret;
    for (int i = 0; i < data.length; ++i) {
      ret.add(_encodeData(data[i], cache: cache));
    }
    return ret;
  }
  if (data is Map) {
    final ret = {};
    cache[data] = ret;
    for (final entry in data.entries) {
      ret[_encodeData(entry.key, cache: cache)] =
          _encodeData(entry.value, cache: cache);
    }
    return ret;
  }
  return data;
}

dynamic _decodeData(data, decoders, {Map<dynamic, dynamic> cache}) {
  if (cache == null) cache = Map();
  if (cache.containsKey(data)) return cache[data];
  if (data is List) {
    final ret = [];
    cache[data] = ret;
    for (int i = 0; i < data.length; ++i) {
      ret.add(_decodeData(data[i], decoders, cache: cache));
    }
    return ret;
  }
  if (data is Map) {
    for (final decoder in decoders) {
      final decodeObj = decoder(data);
      if (decodeObj != null) return decodeObj;
    }
    final ret = {};
    cache[data] = ret;
    for (final entry in data.entries) {
      ret[_decodeData(entry.key, decoders, cache: cache)] =
          _decodeData(entry.value, decoders, cache: cache);
    }
    return ret;
  }
  return data;
}

void _runIsolate(Map spawnMessage) async {
  SendPort sendPort = spawnMessage[#port];
  ReceivePort port = ReceivePort();
  final ctx = FormatContext(spawnMessage[#url]);
  final decoders = <_DecodeFunc>[
    (obj) {
      final index = obj[#streamIndexIsolate];
      if (index != null) return ctx._streams[index];
      return null;
    }
  ];
  sendPort.send(_encodeData(IsolateFunction._new(
    (_msg) async {
      final msg = _decodeData(
        _msg,
        decoders,
      );
      switch (msg[#type]) {
        case #getStreams:
          return ctx.getStreams();
        case #createFrame:
          return ctx._createFrame(msg[#stream], msg[#onFrame]);
        case #play:
          return ctx.play(List<FfmpegStream>.from(msg[#streams]));
        case #close:
          return port.close();
      }
    },
  )));
}

final _isolateDecoders = <_DecodeFunc>[
  IsolateFfmpegStream._decode,
  IsolateFunction._decode,
  IsolateFrame._decode,
  IsolateError._decode,
];

class IsolateFormatContext {
  Future<IsolateFunction> _isolate;

  final String url;

  IsolateFormatContext(this.url);

  _ensureEngine() {
    if (_isolate != null) return;
    ReceivePort port = ReceivePort();
    Isolate.spawn(
      _runIsolate,
      {
        #port: port.sendPort,
        #url: url,
      },
      errorsAreFatal: true,
    );
    _isolate = port.first.then((value) {
      port.close();
      return _decodeData(value, _isolateDecoders) as IsolateFunction;
    });
  }

  Future<List<IsolateFfmpegStream>> getStreams() async {
    _ensureEngine();
    return List<IsolateFfmpegStream>.from(await (await _isolate)({
      #type: #getStreams,
    }));
  }

  List<IsolateFunction> _isolates = [];
  Future<IsolateFrame> createFrame(
      IsolateFfmpegStream stream, void onFrame()) async {
    _ensureEngine();
    final isolate = IsolateFunction._new((_) {
      onFrame();
    });
    _isolates.add(isolate);
    return (await (await _isolate)({
      #type: #createFrame,
      #stream: _encodeData(stream),
      #onFrame: _encodeData(isolate),
    })) as IsolateFrame;
  }

  Future play(
    List<IsolateFfmpegStream> streams,
  ) async {
    _ensureEngine();
    return (await _isolate)({
      #type: #play,
      #streams: _encodeData(streams),
    });
  }

  close() {
    if (_isolate == null) return;
    _isolates.forEach((e) => e.free());
    _isolates.clear();
    final ret = _isolate.then((isolate) async {
      final closePort = ReceivePort();
      await isolate({
        #type: #close,
        #port: closePort.sendPort,
      });
    });
    _isolate = null;
    return ret;
  }
}

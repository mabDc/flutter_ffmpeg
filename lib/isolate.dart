import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'ffi.dart';

void _runIsolate(Map spawnMessage) async {
  SendPort sendPort = spawnMessage[#port];
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);

  final ps = allocate<Pointer>();
  ps.value = Pointer.fromAddress(0);
  final url = Utf8.toUtf8(spawnMessage[#url] ?? "");
  int ret = avformat_open_input(ps, url, Pointer.fromAddress(0), Pointer.fromAddress(0));
  
  free(url);
  await for (final _ in port) {
    
  }

  port.listen((msg) async {
    var data;
    SendPort msgPort = msg[#port];
    try {
      switch (msg[#type]) {
        case #close:
          data = false;
          port.close();
          data = true;
          break;
      }
      if (msgPort != null) msgPort.send(data);
    } catch (e) {
      if (msgPort != null)
        msgPort.send({
          #error: e,
        });
    }
  });
}

class IsolateFFmpeg {
  Future<SendPort> _sendPort;

  final String url;

  IsolateFFmpeg(this.url);

  _ensureEngine() {
    if (_sendPort != null) return;
    ReceivePort port = ReceivePort();
    Isolate.spawn(
      _runIsolate,
      {
        #port: port.sendPort,
        url: url,
      },
      errorsAreFatal: true,
    );
    final completer = Completer<SendPort>();
    port.listen((msg) async {
      if (msg is SendPort && !completer.isCompleted) {
        completer.complete(msg);
        return;
      }
      switch (msg[#type]) {
      }
    }, onDone: () {
      close();
      if (!completer.isCompleted)
        completer.completeError(Exception('isolate close'));
    });
    _sendPort = completer.future;
  }

  close() {
    if (_sendPort == null) return;
    final ret = _sendPort.then((sendPort) async {
      final closePort = ReceivePort();
      sendPort.send({
        #type: #close,
        #port: closePort.sendPort,
      });
      final result = await closePort.first;
      closePort.close();
      if (result is Map && result.containsKey(#error)) throw result[#error];
      return result;
    });
    _sendPort = null;
    return ret;
  }
}

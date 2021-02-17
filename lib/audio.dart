import 'dart:ffi';
import 'dart:math';

import 'ffi.dart';

class AudioClient {
  Pointer<IMMDeviceEnumerator> _pEnumerator;
  Pointer<IMMDevice> _pDevice;
  Pointer<IAudioClient> _pAudioClient;
  Pointer<WAVEFORMATEX> _pwfx;
  Pointer<IAudioRenderClient> _pRenderClient;
  int format;
  int _bufferFrameCount;
  get bufferFrameCount => _bufferFrameCount;
  get sampleRate => _pwfx.ref.nSamplesPerSec;
  get channels => _pwfx.ref.nChannels;

  AudioClient() {
    try {
      _pEnumerator = createIMMDeviceEnumerator();
      if (_pEnumerator.address == 0)
        throw Exception("createIMMDeviceEnumerator failed");
      _pDevice = iMMDeviceEnumeratorGetDefaultAudioEndpoint(_pEnumerator);
      if (_pDevice.address == 0)
        throw Exception("iMMDeviceEnumeratorGetDefaultAudioEndpoint failed");
      _pAudioClient = iMMDeviceActivate(_pDevice);
      if (_pAudioClient.address == 0)
        throw Exception("iMMDeviceActivate failed");
      _pwfx = iAudioClientGetMixFormat(_pAudioClient);
      if (_pwfx.address == 0)
        throw Exception("iAudioClientGetMixFormat failed");
      format = getSampleFormat(_pwfx);
      if (iAudioClientInitialize(_pAudioClient, _pwfx, 10000000) < 0)
        throw Exception("iAudioClientInitialize failed");
      _bufferFrameCount = iAudioClientGetBufferSize(_pAudioClient);
      if (_bufferFrameCount <= 0)
        throw Exception("iAudioClientGetBufferSize failed");
      _pRenderClient = iAudioClientGetService(_pAudioClient);
      if (_pRenderClient.address == 0)
        throw Exception("iAudioClientGetService failed");
    } catch (e) {
      close();
      throw e;
    }
  }

  waitHalfBuffer() {
    return Future.delayed(
        Duration(milliseconds: bufferFrameCount * 1000 / sampleRate ~/ 2));
  }

  int _padding = -1;
  writeBuffer(Pointer<Uint8> data, int length, int bytePerFrame) async {
    if (_pRenderClient == null || _pRenderClient.address == 0)
      throw Exception("audio not initialized");
    int offset = 0;
    while (offset < length) {
      final frames = iAudioClientGetCurrentPadding(_pAudioClient);
      if (frames > bufferFrameCount * 0.8) {
        await waitHalfBuffer();
        continue;
      }
      final requestBuffer =
          min<int>(bufferFrameCount - frames, length - offset);
      final pData = iAudioRenderClientGetBuffer(_pRenderClient, requestBuffer);
      if (pData.address == 0) continue;
      ffiMemcpy(pData, data.elementAt(offset * bytePerFrame),
          requestBuffer * bytePerFrame);
      offset += requestBuffer;
      if (iAudioRenderClientReleaseBuffer(_pRenderClient, requestBuffer, 0) < 0)
        throw Exception("iAudioRenderClientReleaseBuffer failed");
    }
  }

  start() {
    if (_pAudioClient == null && _pAudioClient.address == 0)
      throw Exception("audio not initialized");
    if (iAudioClientStart(_pAudioClient) < 0)
      throw Exception("iAudioClientStart failed");
  }

  stop() {
    if (_pAudioClient == null && _pAudioClient.address == 0)
      throw Exception("audio not initialized");
    if (iAudioClientStop(_pAudioClient) < 0)
      throw Exception("iAudioClientStop failed");
  }

  close() {
    if (_pwfx != null && _pwfx.address != 0) ffiCoTaskMemFree(_pwfx);
    _pwfx = null;
    if (_pRenderClient != null && _pRenderClient.address != 0)
      releaseIUnknown(_pRenderClient);
    _pRenderClient = null;
    if (_pAudioClient != null && _pAudioClient.address != 0)
      releaseIUnknown(_pAudioClient);
    _pAudioClient = null;
    if (_pDevice != null && _pDevice.address != 0) releaseIUnknown(_pDevice);
    _pDevice = null;
    if (_pEnumerator != null && _pEnumerator.address != 0)
      releaseIUnknown(_pEnumerator);
    _pEnumerator = null;
  }
}

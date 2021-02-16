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
      assert(_pEnumerator.address != 0);
      _pDevice = iMMDeviceEnumeratorGetDefaultAudioEndpoint(_pEnumerator);
      assert(_pDevice.address != 0);
      _pAudioClient = iMMDeviceActivate(_pDevice);
      assert(_pAudioClient.address != 0);
      _pwfx = iAudioClientGetMixFormat(_pAudioClient);
      assert(_pwfx.address != 0);
      format = getSampleFormat(_pwfx);
      assert(iAudioClientInitialize(_pAudioClient, _pwfx, 10000000) >= 0);
      _bufferFrameCount = iAudioClientGetBufferSize(_pAudioClient);
      assert(_bufferFrameCount > 0);
      _pRenderClient = iAudioClientGetService(_pAudioClient);
      assert(_pRenderClient.address != 0);
    } catch (e) {
      close();
    }
  }

  waitHalfBuffer() {
    return Future.delayed(
        Duration(milliseconds: bufferFrameCount * 1000 / sampleRate ~/ 2));
  }

  int _padding = -1;
  writeBuffer(Pointer<Uint8> data, int length, int bytePerFrame) async {
    int offset = 0;
    while (offset < length) {
      final frames = iAudioClientGetCurrentPadding(_pAudioClient);
      if (frames > bufferFrameCount * 0.4) {
        await waitHalfBuffer();
        continue;
      }
      final requestBuffer =
          min<int>(bufferFrameCount - frames, length - offset);
      final pData = iAudioRenderClientGetBuffer(_pRenderClient, requestBuffer);
      if (pData.address != 0) {
        ffiMemcpy(pData, data.elementAt(offset * bytePerFrame),
            requestBuffer * bytePerFrame);
        offset += requestBuffer;
      }
      assert(
          iAudioRenderClientReleaseBuffer(_pRenderClient, requestBuffer, 0) >=
              0);
    }
  }

  start() {
    assert(_pAudioClient != null && _pAudioClient.address != 0);
    assert(iAudioClientStart(_pAudioClient) >= 0);
  }

  stop() {
    assert(_pAudioClient != null && _pAudioClient.address != 0);
    assert(iAudioClientStop(_pAudioClient) >= 0);
  }

  close() {
    if (_pwfx != null && _pwfx.address != 0) ffiCoTaskMemFree(_pwfx);
    _pwfx = null;
    if (_pRenderClient != null && _pRenderClient.address != 0)
      releaseIUnknown(_pRenderClient);
    _pRenderClient = null;
    if (_pAudioClient != null && _pAudioClient.address != 0)
      releaseIUnknown(_pAudioClient);
    if (_pDevice != null && _pDevice.address != 0) releaseIUnknown(_pDevice);
    _pDevice = null;
    if (_pEnumerator != null && _pEnumerator.address != 0)
      releaseIUnknown(_pEnumerator);
    _pEnumerator = null;
  }
}

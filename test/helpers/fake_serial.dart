import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:portside/services/serial_service.dart';

/// 실제 포트 없이 세션을 테스트하기 위한 가짜 시리얼 서비스.
/// 보낸 바이트는 [written]에 쌓이고, [emit]으로 장치가 보내는 데이터를 흉내 낸다.
class FakeSerialService extends SerialService {
  final _incoming = StreamController<Uint8List>.broadcast();
  final List<int> written = [];
  bool _open = false;

  @override
  bool get isOpen => _open;

  String get writtenText => utf8.decode(written, allowMalformed: true);

  /// 연결할 때 보내는 깨우기용 Enter(CRLF) 같은 것을 비우고 이후에 보낸 것만 본다.
  void clearWritten() => written.clear();

  void emit(String text) =>
      _incoming.add(Uint8List.fromList(utf8.encode(text)));

  @override
  Stream<Uint8List> open(String portName, int baudRate) {
    _open = true;
    return _incoming.stream;
  }

  @override
  int write(Uint8List bytes) {
    written.addAll(bytes);
    return bytes.length;
  }

  @override
  void close() => _open = false;
}

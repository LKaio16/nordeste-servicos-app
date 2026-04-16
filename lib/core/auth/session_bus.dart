import 'dart:async';

/// Dispara quando access + refresh falham e a sessão deve encerrar na UI.
class SessionBus {
  SessionBus._();
  static final instance = SessionBus._();

  final _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void emitExpired() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}

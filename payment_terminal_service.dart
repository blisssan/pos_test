import 'dart:async';
import 'dart:io';

class PaymentTerminalService {
  static final PaymentTerminalService _singleton = PaymentTerminalService._();

  static PaymentTerminalService get instance => _singleton;

  PaymentTerminalService._(){
    stream = _controller.stream;
    _connect();
  }

  final StreamController<dynamic> _controller = StreamController.broadcast();
  Stream<dynamic>? stream;

  Socket? _socket;

  Stream<dynamic> makePayment(double amount) async* {
    int amountInCents = (amount * 100).toInt();
    yield* stream!;
    _socket?.add([amountInCents]);
  }

  void _connect() async{
    _socket = await Socket.connect('127.0.0.1', 4567);
    _socket?.listen(
      dataHandler,
      onError: errorHandler,
      onDone: doneHandler,
      cancelOnError: false,
    );
  }

  void dataHandler(data) {
    print('Inside Service: ${String.fromCharCodes(data).trim()}');
    _controller.sink.add(data);
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    _socket?.destroy();
    _socket = null;
  }
}

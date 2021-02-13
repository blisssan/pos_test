import 'dart:io';

import 'payment_terminal_service.dart';

PaymentTerminalService? _paymentService;

void main() {
  initiateService();
  stdin.listen((data) {
    String input = String.fromCharCodes(data);
    if (input.trim() == 'totalquit') {
      exit(0);
    }
    if (input.trim() == 'retry') {
      _paymentService?.close();
      initiateService();
    }
    var payment = double.tryParse(input);
    if (payment != null) {
      _paymentService?.makePayment(payment);
    } else {
      _paymentService?.addData(data);
    }
  });
}

void initiateService() async {
  try {
    _paymentService = PaymentTerminalService('127.0.0.1', '4567');
    await _paymentService?.connect();
    print('Connected');
    print('');
    _paymentService?.response?.listen((event) {
      print('===>In stream:');
      print(event);
      print('');
    }).onDone(() {
      print('--->completed');
      print('');
    });
  } on Exception catch (error) {
    print('****  ERROR *****');
    print(error.toString());
  }
}

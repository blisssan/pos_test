import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charcode/ascii.dart';

class PaymentTerminalService {
  static var ascii = AsciiCodec();
  String ip = '127.0.0.1';
  int port = 4567;

  PaymentTerminalService(String ip, String port) {
    this.ip = ip;
    this.port = int.tryParse(port) ?? 4567;
    response = _controller.stream;
  }

  final StreamController<dynamic> _controller = StreamController.broadcast();
  Stream<dynamic>? response;

  Socket? _socket;

  void makePayment(double amount) {
    int amountInCents = (amount * 100).toInt();
    _socket?.add(constructPaymentPacket(amountInCents));
  }

  Future<void> connect() async {
    if (_socket != null) {
      _socketClose();
    }
    _socket = await Socket.connect(ip, port);
    _socket?.listen(
      dataHandler,
      onError: errorHandler,
      onDone: doneHandler,
      cancelOnError: false,
    );
  }

  List<int> constructPaymentPacket(int amountInCents) {
    List<int> paymentRequest = [$0, $0];
    List<int> amountTag = [$0, $0, $1];
    List<int> amountField = ascii.encode(amountInCents.toString());
    return [...paymentRequest, $fs, ...amountTag, ...amountField];
  }

  void dataHandler(data) {
    if (!(data is List<int>)) {
      return;
    }
    if (data.length == 1 && data[0] == $dc1) {
      print('Heart Beat');
      return;
    }
    List<String> responseData = _parseResponseData(data);
    if (responseData.isEmpty) {
      print('Empty Response');
      return;
    }

    _processResponseData(responseData);
  }

  List<String> _parseResponseData(List<int> data) {
    List<int> _temp = [];
    List<String> responseData = [];
    data.forEach((item) {
      if (item == $fs) {
        responseData.add(String.fromCharCodes(_temp));
        _temp = [];
      } else {
        _temp.add(item);
      }
    });
    if (_temp.isNotEmpty) {
      responseData.add(String.fromCharCodes(_temp));
    }
    return responseData;
  }

  void _processResponseData(List<String> responseData) {
    print(responseData);
    String _statusCode = responseData[0];
    _statusCode = _statusCode.substring(0, 2);
    var response =
        TerminalResponse.fromTransactionStatus(_statusCode, responseData);
    _controller.sink.add(response);
  }

  void addData(List<int> data) {
    _socket?.add(data);
  }

  void close() {
    _socketClose();
    _controller.close();
  }

  void _socketClose() {
    _socket?.destroy();
    _socket == null;
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
    close();
  }

  void doneHandler() {
    print('done');
    close();
  }
}

enum TerminalResponseStatus { success, failed, unknown }

class TerminalResponse {
  static Map<String, String> transactionStatuses = {
    '00': 'Approved!',
    '01': 'Partial Approved!',
    '10': 'Declined by host or by card!',
    '11': 'Communication Error!',
    '12': 'Cancelled by User',
    '13': 'Timed out on User Input',
    '14': 'Transaction/Function Not Completed',
    '15': 'Batch Empty',
    '16': 'Declined by Merchant',
    '17': 'Record Not Found',
    '18': 'Transaction Already Voided',
    '30': 'Invalid ECR Parameter',
    '31': 'Battery low',
  };

  TerminalResponseStatus status = TerminalResponseStatus.unknown;

  dynamic data;
  String code = '';
  String message = '';

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'message': message, 'data': data};
  }

  static TerminalResponse fromTransactionStatus(String code, data) {
    String? _statusMessage = transactionStatuses[code];
    if (_statusMessage == null) {
      return TerminalResponse.unknown(code, 'Unknown', data);
    }
    if (code == '00') {
      return TerminalResponse.success(code, _statusMessage, data);
    }
    return TerminalResponse.failure(code, _statusMessage, data);
  }

  TerminalResponse.success(code, String message, dynamic data) {
    this.code = code;
    this.message = message;
    status = TerminalResponseStatus.success;
    this.data = data;
  }

  TerminalResponse.failure(code, String message, dynamic data) {
    this.code = code;
    this.message = message;
    status = TerminalResponseStatus.failed;
    this.data = data;
  }

  TerminalResponse.unknown(code, String message, dynamic data) {
    this.code = code;
    this.message = message;
    status = TerminalResponseStatus.unknown;
    this.data = data;
  }
}

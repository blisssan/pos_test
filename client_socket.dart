import 'dart:io';

import 'package:charcode/ascii.dart';

Socket? socket;

void main() {
  Socket.connect('127.0.0.1', 4567).then((Socket sock) {
    socket = sock;
    if (socket == null) {
      throw Exception("Invalid Socket");
    }
    socket?.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }).catchError((e) {
    print("Unable to connect: $e");
    exit(1);
  });

  //Connect standard in to the socket
  stdin.listen((data) {
    //socket?.write(new String.fromCharCodes(data).trim() + '\n');
    var charBytes = [$0, $0, $fs, $0, $0, $1, $1, $0, $0];
    socket?.add(charBytes);
  });
}

void dataHandler(data) {
  print(new String.fromCharCodes(data).trim());
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

void doneHandler() {
  // socket?.destroy();
  // exit(0);
}

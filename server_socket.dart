import 'dart:io';

void main() {
  ServerSocket.bind(InternetAddress.anyIPv4, 4567).then((ServerSocket server) {
    server.listen(handleClient);
  });
}

void handleClient(Socket client) {
  print('Connection from '
      '${client.remoteAddress.address}:${client.remotePort}');

  client.write("Hello from simple server!\n");
  client.listen(dataHandler,
      onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  client.close();
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

import 'dart:io';

import 'dart:typed_data';

void main() {
  ServerSocket.bind(InternetAddress.anyIPv4, 4567).then((ServerSocket server) {
    server.listen(handleClient, onDone: onDone, onError: onError);
  });
}

void onError(error) {
  print(error);
}

void onDone() {
  print('Server left.');
}

void handleClient(Socket client) {
  print('Connection from '
      '${client.remoteAddress.address}:${client.remotePort}');

  client.listen((event) {
    print(String.fromCharCodes(event).trim());
    List<int> byteData = [];
    String inputHexStr = '39 39 30 1C 31 30 30 30 30 1C 31 30 31 30 30 1C';
    byteData = hexDecode(inputHexStr);
    if (String.fromCharCodes(event).trim() == 'quit') {
      client.close();
      return;
    }
    client.add(byteData);
  }, onError: (error) {
    print(error);
    client.close();
  }, onDone: () {
    print('Done!');
    client.close();
  });
}

const String _ALPHABET = '0123456789abcdef';

List<int> hexDecode(String hex) {
  String str = hex.replaceAll(' ', '');
  str = str.toLowerCase();
  if (str.length % 2 != 0) {
    str = '0' + str;
  }
  Uint8List result = Uint8List(str.length ~/ 2);
  for (int i = 0; i < result.length; i++) {
    int firstDigit = _ALPHABET.indexOf(str[i * 2]);
    int secondDigit = _ALPHABET.indexOf(str[i * 2 + 1]);
    if (firstDigit == -1 || secondDigit == -1) {
      throw FormatException('Non-hex character detected in $hex');
    }
    result[i] = (firstDigit << 4) + secondDigit;
  }
  return result;
}

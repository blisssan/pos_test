import 'dart:convert';
import 'dart:typed_data';

import 'package:charcode/ascii.dart';

void main() {
  var ascii = AsciiCodec();

  var hex = hexDecode('30 30 1C 30 30 31 31 30 30');

  print(hex);

  print(ascii.decode(hex));

  List<int> charBytes = [$0, $0, $fs, $0, $0, $1, $1, $0, $0];

  print(String.fromCharCodes(charBytes));

  print(ascii.decode(charBytes));

  print(hexEncode(charBytes));
}

const String _ALPHABET = "0123456789abcdef";

List<int> hexDecode(String hex) {
  String str = hex.replaceAll(" ", "");
  str = str.toLowerCase();
  if (str.length % 2 != 0) {
    str = '0' + str;
  }
  Uint8List result = Uint8List(str.length ~/ 2);
  for (int i = 0; i < result.length; i++) {
    int firstDigit = _ALPHABET.indexOf(str[i * 2]);
    int secondDigit = _ALPHABET.indexOf(str[i * 2 + 1]);
    if (firstDigit == -1 || secondDigit == -1) {
      throw new FormatException("Non-hex character detected in $hex");
    }
    result[i] = (firstDigit << 4) + secondDigit;
  }
  return result;
}

String hexEncode(List<int> bytes, {bool upperCase = true}) {
  var buffer = new StringBuffer();

  for (int part in bytes) {
    if (part & 0xff != part) {
      throw new FormatException("Non-byte integer detected");
    }
    buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  if (upperCase) {
    return buffer.toString().toUpperCase();
  } else {
    return buffer.toString();
  }
}

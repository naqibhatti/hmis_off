/// Utilities to decode Urdu text encoded as comma-separated hex codes.
/// Example input (comma separated hex bytes): "A0,U1,20,07,08,09,12,32"

class UrduDecoder {
  /// Converts a comma-separated list of hex codes to a Unicode Urdu string.
  /// Unknown tokens are ignored.
  static String convertToUrdu(String text) {
    final StringBuffer sb = StringBuffer();
    final List<String> tokens = text.split(',');

    for (String token in tokens) {
      token = token.trim();
      if (token.isEmpty) continue;

      // Preserve raw newlines if they were injected by the hex generator
      if (token == '\n') {
        sb.write('\n');
        continue;
      }

      switch (token.toUpperCase()) {
        case '20':
          sb.write(' ');
          break;
        case '22':
          sb.write('\u0622');
          break;
        case '27':
          sb.write('\u0627');
          break;
        case '13':
          sb.write('\u0613');
          break;
        case '28':
          sb.write('\u0628');
          break;
        case '2B':
          sb.write('\u062b');
          break;
        case '86':
          sb.write('\u0686');
          break;
        case '88':
          sb.write('\u0688');
          break;
        case '2F':
          sb.write('\u062f');
          break;
        case '10':
          sb.write('\u0610');
          break;
        case '39':
          sb.write('\u0639');
          break;
        case '41':
          sb.write('\u0641');
          break;
        case '3A':
          sb.write('\u063a');
          break;
        case 'AF':
          sb.write('\u06af');
          break;
        case '2D':
          sb.write('\u062d');
          break;
        case 'BE':
          sb.write('\u06be');
          break;
        case 'CC':
          sb.write('\u06cc');
          break;
        case '36':
          sb.write('\u0636');
          break;
        case '2C':
          sb.write('\u062c');
          break;
        case '2E':
          sb.write('\u062e');
          break;
        case '43':
          sb.write('\u0643');
          break;
        case '12':
          sb.write('\u0612');
          break;
        case '44':
          sb.write('\u0644');
          break;
        case '45':
          sb.write('\u0645');
          break;
        case 'BA':
          sb.write('\u06ba');
          break;
        case '46':
          sb.write('\u0646');
          break;
        case '29':
          sb.write('\u0629');
          break;
        case 'A9':
          sb.write('\u06a9');
          break;
        case 'C1':
          sb.write('\u06c1');
          break;
        case '7E':
          sb.write('\u067e');
          break;
        case '42':
          sb.write('\u0642');
          break;
        case '91':
          sb.write('\u0691');
          break;
        case '31':
          sb.write('\u0631');
          break;
        case '35':
          sb.write('\u0635');
          break;
        case '33':
          sb.write('\u0633');
          break;
        case '79':
          sb.write('\u0679');
          break;
        case '2A':
          sb.write('\u062a');
          break;
        case '21':
          sb.write('\u0621');
          break;
        case '38':
          sb.write('\u0638');
          break;
        case '37':
          sb.write('\u0637');
          break;
        case '48':
          sb.write('\u0648');
          break;
        case '98':
          sb.write('\u0698');
          break;
        case '34':
          sb.write('\u0634');
          break;
        case 'D2':
          sb.write('\u06d2');
          break;
        case '30':
          sb.write('\u0630');
          break;
        case '32':
          sb.write('\u0632');
          break;
        case '60':
          sb.write('\u0660');
          break;
        case '61':
          sb.write('\u0661');
          break;
        case '62':
          sb.write('\u0662');
          break;
        case '63':
          sb.write('\u0663');
          break;
        case '64':
          sb.write('\u0664');
          break;
        case '65':
          sb.write('\u0665');
          break;
        case '66':
          sb.write('\u0666');
          break;
        case '67':
          sb.write('\u0667');
          break;
        case '68':
          sb.write('\u0668');
          break;
        case '69':
          sb.write('\u0669');
          break;
        case '0C':
          sb.write(' \u200c');
          break;
        case 'D4':
          sb.write('\u06d4');
          break;
        case '1F':
          sb.write('\u061f');
          break;
        case '02':
          sb.write('\u0602');
          break;
        case '1B':
          sb.write('\u061b');
          break;
        case '7B':
          sb.write('\u007b');
          break;
        case '7D':
          sb.write('\u007d');
          break;
        default:
          // Unknown token -> ignore (or append raw)
          break;
      }
    }

    return sb.toString();
  }

  /// Converts a raw string to a comma-separated list of uppercase hex codes.
  /// Newlines are preserved as "\n," tokens to help layout-aware decoding.
  static String convertToHex(String text) {
    final StringBuffer sb = StringBuffer();
    for (final int codeUnit in text.codeUnits) {
      if (codeUnit == 10) { // '\n'
        sb.write('\n,');
      } else {
        sb.write(codeUnit.toRadixString(16).toUpperCase());
        sb.write(',');
      }
    }
    return sb.toString();
  }
}



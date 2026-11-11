import 'dart:convert';

import 'package:noh_common/framing.dart';
import 'package:test/test.dart';

List<String> decoded(List<List<int>> lines) =>
    lines.map((line) => utf8.decode(line)).toList();

void main() {
  group('LineFramer', () {
    test('une ligne complète est découpée', () {
      final framer = LineFramer();

      final lines = framer.add(utf8.encode('{"id":1,"type":"echo"}\n'));

      expect(decoded(lines), equals(['{"id":1,"type":"echo"}']));
    });

    test('une ligne coupée en trois morceaux est reconstruite', () {
      final framer = LineFramer();
      final bytes = utf8.encode('{"id":2,"type":"echo"}\n');

      final premier = framer.add(bytes.sublist(0, 5));
      final deuxieme = framer.add(bytes.sublist(5, 12));
      final troisieme = framer.add(bytes.sublist(12));

      expect(premier, isEmpty);
      expect(deuxieme, isEmpty);
      expect(decoded(troisieme), equals(['{"id":2,"type":"echo"}']));
    });

    test('deux lignes dans un même morceau donnent deux messages', () {
      final framer = LineFramer();

      final lines = framer.add(
        utf8.encode('{"id":3,"type":"echo"}\n{"id":4,"type":"echo"}\n'),
      );

      expect(decoded(lines), equals([
        '{"id":3,"type":"echo"}',
        '{"id":4,"type":"echo"}',
      ]));
    });

    test('un message incomplet reste en attente', () {
      final framer = LineFramer();

      final avant = framer.add(utf8.encode('{"id":5'));
      final apres = framer.add(utf8.encode(',"type":"echo"}\n'));

      expect(avant, isEmpty);
      expect(decoded(apres), equals(['{"id":5,"type":"echo"}']));
    });

    test('le \\r précédant le LF est retiré', () {
      final framer = LineFramer();

      final lines = framer.add(utf8.encode('{"id":6}\r\n'));

      expect(decoded(lines), equals(['{"id":6}']));
    });

    test('les lignes vides sont ignorées', () {
      final framer = LineFramer();

      expect(framer.add(utf8.encode('\n')), isEmpty);
      expect(framer.add(utf8.encode('\r\n')), isEmpty);
    });

    test('une ligne de exactement la limite est acceptée', () {
      final framer = LineFramer(maxLength: 8);

      final lines = framer.add(utf8.encode('12345678\n'));

      expect(decoded(lines), equals(['12345678']));
    });

    test('une ligne de exactement la limite suivie de CRLF est acceptée', () {
      final framer = LineFramer(maxLength: 8);

      final lines = framer.add(utf8.encode('12345678\r\n'));

      expect(decoded(lines), equals(['12345678']));
    });

    test('une ligne au-delà de la limite lève FrameTooLargeException', () {
      final framer = LineFramer(maxLength: 16);

      expect(
        () => framer.add(utf8.encode('x' * 17)),
        throwsA(isA<FrameTooLargeException>()),
      );
    });

    test('la limite compte les octets UTF-8, pas les caractères', () {
      // 'é' occupe 2 octets : 7 caractères font 14 octets, 8 en font 16.
      final framer = LineFramer(maxLength: 15);

      expect(decoded(framer.add(utf8.encode('é' * 7 + '\n'))),
          equals(['é' * 7]));
      expect(
        () => LineFramer(maxLength: 15).add(utf8.encode('é' * 8)),
        throwsA(isA<FrameTooLargeException>()),
      );
    });

    test('une séquence UTF-8 invalide est renvoyée en octets, sans exception', () {
      final framer = LineFramer();

      final lines = framer.add([0xff, 0x0a]);

      expect(lines.single, equals([0xff]));
    });

    test('la limite par défaut est de 1 Mo', () {
      final framer = LineFramer();
      final tropGrand = List<int>.filled(1048577, 0x61);

      expect(
        () => framer.add(tropGrand),
        throwsA(isA<FrameTooLargeException>()),
      );
    });
  });
}
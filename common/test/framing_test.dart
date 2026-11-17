import 'dart:convert';

import 'package:noh_common/framing.dart';
import 'package:test/test.dart';

List<String> decoded(List<List<int>> messages) =>
    messages.map((msg) => utf8.decode(msg)).toList();

void main() {
  group('LengthPrefixFramer', () {
    test('un message complet est décodé', () {
      final framer = LengthPrefixFramer();
      final json = '{"id":1,"type":"echo"}';
      final body = utf8.encode(json);
      final frame = encodeFrame(body);

      final messages = framer.add(frame);

      expect(decoded(messages), equals([json]));
    });

    test('un message coupé en plusieurs morceaux est reconstruit', () {
      final framer = LengthPrefixFramer();
      final json = '{"id":2,"type":"echo"}';
      final body = utf8.encode(json);
      final frame = encodeFrame(body);

      final premier = framer.add(frame.sublist(0, 3));
      final deuxieme = framer.add(frame.sublist(3, 8));
      final troisieme = framer.add(frame.sublist(8));

      expect(premier, isEmpty);
      expect(deuxieme, isEmpty);
      expect(decoded(troisieme), equals([json]));
    });

    test('deux messages dans un même bloc donnent deux messages', () {
      final framer = LengthPrefixFramer();
      final json1 = '{"id":3,"type":"echo"}';
      final json2 = '{"id":4,"type":"echo"}';
      final body1 = utf8.encode(json1);
      final body2 = utf8.encode(json2);
      final frame = [...encodeFrame(body1), ...encodeFrame(body2)];

      final messages = framer.add(frame);

      expect(decoded(messages), equals([json1, json2]));
    });

    test('un message incomplet reste en attente', () {
      final framer = LengthPrefixFramer();
      final json = '{"id":5,"type":"echo"}';
      final body = utf8.encode(json);
      final frame = encodeFrame(body);

      final avant = framer.add(frame.sublist(0, 5));
      final apres = framer.add(frame.sublist(5));

      expect(avant, isEmpty);
      expect(decoded(apres), equals([json]));
    });

    test('un message vide est accepté', () {
      final framer = LengthPrefixFramer();
      final frame = encodeFrame([]);

      final messages = framer.add(frame);

      expect(messages, isEmpty);
    });

    test('un message de exactement la limite est accepté', () {
      final framer = LengthPrefixFramer(maxLength: 20);
      final body = List<int>.filled(20, 0x61);
      final frame = encodeFrame(body);

      final messages = framer.add(frame);

      expect(messages.single, equals(body));
    });

    test('un message au-delà de la limite lève FrameTooLargeException', () {
      final framer = LengthPrefixFramer(maxLength: 16);
      final body = List<int>.filled(17, 0x61);
      final frame = encodeFrame(body);

      expect(
        () => framer.add(frame),
        throwsA(isA<FrameTooLargeException>()),
      );
    });

    test('la limite par défaut est de 1 Mo', () {
      final framer = LengthPrefixFramer();
      final body = List<int>.filled(1048577, 0x61);
      final frame = encodeFrame(body);

      expect(
        () => framer.add(frame),
        throwsA(isA<FrameTooLargeException>()),
      );
    });

    test('reset vide le buffer et réinitialise l\'état', () {
      final framer = LengthPrefixFramer();
      final json = '{"id":6}';
      final body = utf8.encode(json);
      final frame = encodeFrame(body);

      framer.add(frame.sublist(0, 3));
      framer.reset();

      final messages = framer.add(frame);

      expect(decoded(messages), equals([json]));
    });

    test('encodeFrame produit le bon format', () {
      final body = utf8.encode('test');
      final frame = encodeFrame(body);

      // Les 4 premiers octets doivent être la longueur en Big Endian
      expect(frame[0], equals(0x00));
      expect(frame[1], equals(0x00));
      expect(frame[2], equals(0x00));
      expect(frame[3], equals(0x04));

      // Le corps doit suivre
      expect(frame.sublist(4), equals(body));
    });
  });
}
import 'dart:io';

import 'package:noh_server/src/net/echo_server.dart';
import 'package:test/test.dart';

void main() {
  test('renvoie les octets reçus au client', () async {
    final server = await startEchoServer(port: 0); // port 0 : port libre choisi par le système
    addTearDown(() => server.close());

    final socket = await Socket.connect('127.0.0.1', server.port);
    socket.add('bonjour'.codeUnits);

    final received = await socket.first;
    expect(String.fromCharCodes(received), equals('bonjour'));

    await socket.close();
  });
}
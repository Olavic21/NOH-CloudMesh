import 'dart:io';

/// Démarre un serveur qui renvoie à chaque client les octets qu'il reçoit.
Future<ServerSocket> startEchoServer({int port = 4000}) async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);

  server.listen((Socket client) {
    final remote = '${client.remoteAddress.address}:${client.remotePort}';
    print('Client connecté : $remote');

    client.listen(
      (List<int> data) => client.add(data),
      onError: (Object error) => print('Erreur $remote : $error'),
      onDone: () {
        print('Client déconnecté : $remote');
        client.close();
      },
    );
  });

  return server;
}
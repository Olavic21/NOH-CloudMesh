import 'package:noh_server/src/net/tcp_server.dart';

Future<void> main() async {
  final server = TcpServer(port: 4000);
  await server.start();
  print('N.O.H. CloudMesh server started');

  // Garder le serveur en cours d'exécution
  // Pour arrêter, appuyez sur Ctrl+C
}
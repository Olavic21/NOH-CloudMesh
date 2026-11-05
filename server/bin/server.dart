import 'package:noh_server/src/net/echo_server.dart';

Future<void> main() async {
  final server = await startEchoServer(port: 4000);
  print('Écho TCP en écoute sur ${server.address.address}:${server.port}');
}
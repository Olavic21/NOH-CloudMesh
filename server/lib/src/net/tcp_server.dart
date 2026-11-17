/// Serveur TCP principal pour N.O.H. CloudMesh.
library;

import 'dart:convert';
import 'dart:io';

import 'package:noh_common/framing.dart';
import 'package:noh_common/protocol.dart';
import '../../auth/login_handler.dart';
import '../../database/database.dart';

/// Serveur TCP qui traite les requêtes clients avec Length-Prefix Framing.
class TcpServer {
  TcpServer({required this.port});

  final int port;
  ServerSocket? _server;
  final LengthPrefixFramer _framer = LengthPrefixFramer();
  final LoginHandler _loginHandler = LoginHandler.instance;

  /// Démarre le serveur TCP.
  Future<void> start() async {
    // Connecter à la base de données
    await DatabaseService.instance.connect();

    // Lier le serveur sur le port spécifié
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print('Server listening on port $port');

    // Écouter les connexions entrantes
    _server!.listen(_handleClient);
  }

  /// Arrête le serveur.
  Future<void> stop() async {
    await _server?.close();
    await DatabaseService.instance.close();
    print('Server stopped');
  }

  /// Gère une connexion client.
  void _handleClient(Socket socket) {
    final remote = '${socket.remoteAddress.address}:${socket.remotePort}';
    print('Client connected: $remote');

    // Créer un framer spécifique à cette connexion
    final clientFramer = LengthPrefixFramer();

    socket.listen(
      (List<int> data) {
        // Ajouter les données au framer
        final messages = clientFramer.add(data);

        // Traiter chaque message complet
        for (final message in messages) {
          _handleMessage(socket, message);
        }
      },
      onError: (Object error) {
        print('Error on $remote: $error');
        socket.close();
      },
      onDone: () {
        print('Client disconnected: $remote');
        socket.close();
      },
    );
  }

  /// Traite un message reçu d'un client.
  void _handleMessage(Socket socket, List<int> messageBytes) {
    try {
      // Décoder le message JSON
      final jsonString = utf8.decode(messageBytes);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      print('Received: $jsonString');

      // Parser la requête
      final request = Request.fromJson(json);

      // Router vers le handler approprié
      final response = _routeRequest(request);

      // Envoyer la réponse
      _sendResponse(socket, response);
    } catch (e) {
      print('Error handling message: $e');
      final errorResponse = Response.error(
        'error-${DateTime.now().millisecondsSinceEpoch}',
        'Invalid request format',
      );
      _sendResponse(socket, errorResponse);
    }
  }

  /// Route la requête vers le handler approprié.
  Future<Response> _routeRequest(Request request) async {
    switch (request.action) {
      case RequestAction.login:
        return await _loginHandler.handle(request);
      default:
        return Response.error(
          request.requestId,
          'Action not implemented: ${request.action.value}',
        );
    }
  }

  /// Envoie une réponse au client.
  void _sendResponse(Socket socket, Response response) {
    final json = jsonEncode(response.toJson());
    final body = utf8.encode(json);
    final frame = encodeFrame(body);

    socket.add(frame);
    print('Sent: $json');
  }
}

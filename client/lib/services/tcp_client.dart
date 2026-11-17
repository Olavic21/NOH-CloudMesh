/// Service TCP client pour communiquer avec le serveur.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:noh_common/framing.dart';
import 'package:noh_common/protocol.dart';

/// Service TCP client pour communiquer avec le serveur.
class TcpClient {
  TcpClient({required this.host, required this.port});

  final String host;
  final int port;

  Socket? _socket;
  final LengthPrefixFramer _framer = LengthPrefixFramer();
  final StreamController<Response> _responseController = StreamController.broadcast();
  final StreamController<Event> _eventController = StreamController.broadcast();

  /// État de connexion.
  bool get isConnected => _socket != null;

  /// Stream des réponses du serveur.
  Stream<Response> get responseStream => _responseController.stream;

  /// Stream des événements du serveur.
  Stream<Event> get eventStream => _eventController.stream;

  /// Connecte au serveur TCP.
  Future<void> connect() async {
    if (isConnected) {
      return;
    }

    _socket = await Socket.connect(host, port);
    print('Connected to server at $host:$port');

    // Écouter les données entrantes
    _socket!.listen(
      _handleData,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  /// Déconnecte du serveur.
  void disconnect() {
    _socket?.close();
    _socket = null;
    _framer.reset();
    print('Disconnected from server');
  }

  /// Envoie une requête au serveur et retourne la réponse.
  ///
  /// Cette méthode attend la réponse correspondant à la requête.
  Future<Response> sendRequest(Request request) async {
    if (!isConnected) {
      throw StateError('Not connected to server');
    }

    // Envoyer la requête
    _sendFrame(request.toJson());

    // Attendre la réponse avec le même request_id
    final response = await responseStream
        .firstWhere((r) => r.requestId == request.requestId);

    return response;
  }

  /// Envoie une requête sans attendre la réponse (fire and forget).
  void sendRequestAsync(Request request) {
    if (!isConnected) {
      throw StateError('Not connected to server');
    }
    _sendFrame(request.toJson());
  }

  /// Gère les données reçues du serveur.
  void _handleData(List<int> data) {
    // Ajouter les données au framer
    final messages = _framer.add(data);

    // Traiter chaque message complet
    for (final message in messages) {
      _handleMessage(message);
    }
  }

  /// Gère un message complet reçu du serveur.
  void _handleMessage(List<int> messageBytes) {
    try {
      // Décoder le message JSON
      final jsonString = utf8.decode(messageBytes);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      print('Received: $jsonString');

      // Déterminer le type de message
      final type = json['type'] as String?;

      if (type == MessageType.response.value) {
        // C'est une réponse
        final response = Response.fromJson(json);
        _responseController.add(response);
      } else if (type == MessageType.event.value) {
        // C'est un événement
        final event = Event.fromJson(json);
        _eventController.add(event);
      } else {
        print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  /// Envoie un frame au serveur.
  void _sendFrame(Map<String, dynamic> json) {
    final jsonString = jsonEncode(json);
    final body = utf8.encode(jsonString);
    final frame = encodeFrame(body);

    _socket!.add(frame);
    print('Sent: $jsonString');
  }

  /// Gère les erreurs de connexion.
  void _handleError(Object error) {
    print('Socket error: $error');
    disconnect();
  }

  /// Gère la fermeture de la connexion.
  void _handleDone() {
    print('Connection closed by server');
    disconnect();
  }

  /// Libère les ressources.
  void dispose() {
    disconnect();
    _responseController.close();
    _eventController.close();
  }
}

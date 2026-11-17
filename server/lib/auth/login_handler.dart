/// Handler pour traiter les requêtes LOGIN.
library;

import 'dart:convert';

import 'package:noh_common/models.dart';
import 'package:noh_common/protocol.dart';
import 'auth_service.dart';

/// Handler pour l'action LOGIN.
class LoginHandler {
  LoginHandler._();

  static final LoginHandler _instance = LoginHandler._();
  static LoginHandler get instance => _instance;

  final AuthService _auth = AuthService.instance;

  /// Traite une requête LOGIN et retourne une réponse.
  ///
  /// Le payload doit contenir :
  /// - username: nom d'utilisateur
  /// - password: mot de passe
  Future<Response> handle(Request request) async {
    // Vérifier que l'action est LOGIN
    if (request.action != RequestAction.login) {
      return Response.error(
        request.requestId,
        'Invalid action for LoginHandler',
      );
    }

    // Extraire username et password du payload
    final payload = request.payload;
    if (payload == null) {
      return Response.error(
        request.requestId,
        'Missing payload',
      );
    }

    final username = payload['username'] as String?;
    final password = payload['password'] as String?;

    if (username == null || password == null) {
      return Response.error(
        request.requestId,
        'Missing username or password',
      );
    }

    // Tenter l'authentification
    final session = await _auth.login(username, password);

    if (session == null) {
      return Response.error(
        request.requestId,
        'Invalid username or password',
      );
    }

    // Récupérer les informations de l'utilisateur
    final user = await _auth.getUserById(session.userId);

    if (user == null) {
      return Response.error(
        request.requestId,
        'User not found after login',
      );
    }

    // Retourner le succès avec le token et les infos utilisateur
    return Response.success(
      request.requestId,
      data: {
        'token': session.token,
        'user': user.toJson(),
        'expires_at': session.expiresAt?.toIso8601String(),
      },
    );
  }
}

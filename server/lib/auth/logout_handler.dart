/// Handler pour traiter les requêtes LOGOUT.
library;

import 'package:noh_common/protocol.dart';
import 'auth_service.dart';

/// Handler pour l'action LOGOUT.
class LogoutHandler {
  LogoutHandler._();

  static final LogoutHandler _instance = LogoutHandler._();
  static LogoutHandler get instance => _instance;

  final AuthService _auth = AuthService.instance;

  /// Traite une requête LOGOUT et retourne une réponse.
  ///
  /// Le token doit être fourni dans la requête.
  Future<Response> handle(Request request) async {
    // Vérifier que l'action est LOGOUT
    if (request.action != RequestAction.logout) {
      return Response.error(
        request.requestId,
        'Invalid action for LogoutHandler',
      );
    }

    // Vérifier que le token est présent
    final token = request.token;
    if (token == null || token.isEmpty) {
      return Response.error(
        request.requestId,
        'Missing token',
      );
    }

    // Supprimer la session
    final success = await _auth.logout(token);

    if (!success) {
      return Response.error(
        request.requestId,
        'Session not found or already expired',
      );
    }

    return Response.success(
      request.requestId,
      data: {'message': 'Logged out successfully'},
    );
  }
}

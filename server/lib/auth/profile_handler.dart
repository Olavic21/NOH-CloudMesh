/// Handler pour traiter les requêtes GET_PROFILE et UPDATE_PROFILE.
library;

import 'package:noh_common/protocol.dart';
import 'auth_service.dart';

/// Handler pour les actions de profil utilisateur.
class ProfileHandler {
  ProfileHandler._();

  static final ProfileHandler _instance = ProfileHandler._();
  static ProfileHandler get instance => _instance;

  final AuthService _auth = AuthService.instance;

  /// Traite une requête GET_PROFILE ou UPDATE_PROFILE.
  Future<Response> handle(Request request) async {
    switch (request.action) {
      case RequestAction.getProfile:
        return await _handleGetProfile(request);
      case RequestAction.updateProfile:
        return await _handleUpdateProfile(request);
      default:
        return Response.error(
          request.requestId,
          'Invalid action for ProfileHandler',
        );
    }
  }

  /// Récupère le profil de l'utilisateur connecté.
  Future<Response> _handleGetProfile(Request request) async {
    // Vérifier le token
    final token = request.token;
    if (token == null || token.isEmpty) {
      return Response.unauthorized(request.requestId);
    }

    // Récupérer l'utilisateur par token
    final user = await _auth.getUserByToken(token);
    if (user == null) {
      return Response.unauthorized(request.requestId);
    }

    return Response.success(
      request.requestId,
      data: {'user': user.toJson()},
    );
  }

  /// Met à jour le profil de l'utilisateur connecté.
  Future<Response> _handleUpdateProfile(Request request) async {
    // Vérifier le token
    final token = request.token;
    if (token == null || token.isEmpty) {
      return Response.unauthorized(request.requestId);
    }

    // Récupérer l'utilisateur par token
    final user = await _auth.getUserByToken(token);
    if (user == null) {
      return Response.unauthorized(request.requestId);
    }

    // Extraire les données à mettre à jour
    final payload = request.payload;
    if (payload == null) {
      return Response.error(
        request.requestId,
        'Missing payload',
      );
    }

    // Pour l'instant, on ne permet que la mise à jour du nom complet et de l'email
    final fullName = payload['full_name'] as String?;
    final email = payload['email'] as String?;

    // TODO: Implémenter la mise à jour en base de données
    // Pour l'instant, on retourne les données mises à jour sans les sauvegarder

    final updatedUser = user.copyWith(
      fullName: fullName ?? user.fullName,
      email: email ?? user.email,
    );

    return Response.success(
      request.requestId,
      data: {'user': updatedUser.toJson()},
    );
  }
}

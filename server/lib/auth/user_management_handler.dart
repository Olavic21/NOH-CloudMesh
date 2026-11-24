/// Handler pour la gestion des utilisateurs (admin).
library;

import 'package:noh_common/models.dart';
import 'package:noh_common/protocol.dart';
import 'auth_service.dart';

/// Handler pour les actions d'administration des utilisateurs.
class UserManagementHandler {
  UserManagementHandler._();

  static final UserManagementHandler _instance = UserManagementHandler._();
  static UserManagementHandler get instance => _instance;

  final AuthService _auth = AuthService.instance;

  /// Traite une requête d'administration des utilisateurs.
  Future<Response> handle(Request request) async {
    // Vérifier que l'utilisateur est admin
    final token = request.token;
    if (token == null || token.isEmpty) {
      return Response.unauthorized(request.requestId);
    }

    final currentUser = await _auth.getUserByToken(token);
    if (currentUser == null) {
      return Response.unauthorized(request.requestId);
    }

    if (currentUser.role != UserRole.admin) {
      return Response.error(
        request.requestId,
        'Access denied: admin role required',
      );
    }

    // Router vers la méthode appropriée
    switch (request.action) {
      case RequestAction.listUsers:
        return await _handleListUsers(request);
      case RequestAction.createUser:
        return await _handleCreateUser(request);
      case RequestAction.updateUser:
        return await _handleUpdateUser(request);
      case RequestAction.deleteUser:
        return await _handleDeleteUser(request);
      default:
        return Response.error(
          request.requestId,
          'Invalid action for UserManagementHandler',
        );
    }
  }

  /// Liste tous les utilisateurs.
  Future<Response> _handleListUsers(Request request) async {
    final users = await _auth.listUsers();

    return Response.success(
      request.requestId,
      data: {
        'users': users.map((u) => u.toJson()).toList(),
      },
    );
  }

  /// Crée un nouvel utilisateur.
  Future<Response> _handleCreateUser(Request request) async {
    final payload = request.payload;
    if (payload == null) {
      return Response.error(request.requestId, 'Missing payload');
    }

    final username = payload['username'] as String?;
    final email = payload['email'] as String?;
    final password = payload['password'] as String?;
    final roleStr = payload['role'] as String?;
    final fullName = payload['full_name'] as String?;
    final serviceId = payload['service_id'] as int?;

    if (username == null || email == null || password == null || roleStr == null) {
      return Response.error(
        request.requestId,
        'Missing required fields: username, email, password, role',
      );
    }

    UserRole role;
    try {
      role = UserRole.fromString(roleStr);
    } catch (e) {
      return Response.error(request.requestId, 'Invalid role: $roleStr');
    }

    final user = await _auth.createUser(
      username: username,
      email: email,
      password: password,
      role: role,
      fullName: fullName,
      serviceId: serviceId,
    );

    if (user == null) {
      return Response.error(request.requestId, 'Failed to create user');
    }

    return Response.success(
      request.requestId,
      data: {'user': user.toJson()},
    );
  }

  /// Met à jour un utilisateur.
  Future<Response> _handleUpdateUser(Request request) async {
    final payload = request.payload;
    if (payload == null) {
      return Response.error(request.requestId, 'Missing payload');
    }

    final userId = payload['user_id'] as int?;
    if (userId == null) {
      return Response.error(request.requestId, 'Missing user_id');
    }

    final username = payload['username'] as String?;
    final email = payload['email'] as String?;
    final password = payload['password'] as String?;
    final roleStr = payload['role'] as String?;
    final fullName = payload['full_name'] as String?;
    final serviceId = payload['service_id'] as int?;

    UserRole? role;
    if (roleStr != null) {
      try {
        role = UserRole.fromString(roleStr);
      } catch (e) {
        return Response.error(request.requestId, 'Invalid role: $roleStr');
      }
    }

    final user = await _auth.updateUser(
      userId: userId,
      username: username,
      email: email,
      password: password,
      role: role,
      fullName: fullName,
      serviceId: serviceId,
    );

    if (user == null) {
      return Response.error(request.requestId, 'User not found');
    }

    return Response.success(
      request.requestId,
      data: {'user': user.toJson()},
    );
  }

  /// Supprime un utilisateur.
  Future<Response> _handleDeleteUser(Request request) async {
    final payload = request.payload;
    if (payload == null) {
      return Response.error(request.requestId, 'Missing payload');
    }

    final userId = payload['user_id'] as int?;
    if (userId == null) {
      return Response.error(request.requestId, 'Missing user_id');
    }

    // Empêcher la suppression de soi-même
    final currentUser = await _auth.getUserByToken(request.token!);
    if (currentUser != null && currentUser.id == userId) {
      return Response.error(
        request.requestId,
        'Cannot delete your own account',
      );
    }

    final success = await _auth.deleteUser(userId);

    if (!success) {
      return Response.error(request.requestId, 'User not found');
    }

    return Response.success(
      request.requestId,
      data: {'message': 'User deleted successfully'},
    );
  }
}

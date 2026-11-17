/// Service d'authentification pour le serveur.
library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:noh_common/models.dart';
import '../database/database.dart';

/// Service d'authentification.
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final DatabaseService _db = DatabaseService.instance;

  /// Hash un mot de passe avec bcrypt.
  ///
  /// Note: Pour l'instant, on utilise SHA-256 car bcrypt nécessite
  /// une dépendance supplémentaire. On migrera vers bcrypt plus tard.
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Vérifie si un mot de passe correspond au hash stocké.
  bool verifyPassword(String password, String storedHash) {
    final computedHash = hashPassword(password);
    return computedHash == storedHash;
  }

  /// Génère un jeton de session aléatoire.
  String generateToken() {
    final random = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      random[i] = (crypto.Random.secure().nextInt(256));
    }
    return base64Encode(random);
  }

  /// Authentifie un utilisateur avec username et mot de passe.
  ///
  /// Retourne une Session si l'authentification réussit, null sinon.
  Future<Session?> login(String username, String password) async {
    // 1. Chercher l'utilisateur par username
    final userResult = await _db.queryOne(
      'SELECT id, username, email, role, full_name, service_id, password_hash '
      'FROM users WHERE username = @username',
      parameters: {'username': username},
    );

    if (userResult == null) {
      print('User not found: $username');
      return null;
    }

    // 2. Vérifier le mot de passe
    final storedHash = userResult['password_hash'] as String;
    if (!verifyPassword(password, storedHash)) {
      print('Invalid password for user: $username');
      return null;
    }

    // 3. Créer une nouvelle session
    final userId = userResult['id'] as int;
    final token = generateToken();
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));

    final sessionResult = await _db.queryOne(
      'INSERT INTO sessions (user_id, token, created_at, expires_at) '
      'VALUES (@user_id, @token, @created_at, @expires_at) '
      'RETURNING id, user_id, token, created_at, expires_at',
      parameters: {
        'user_id': userId,
        'token': token,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      },
    );

    if (sessionResult == null) {
      print('Failed to create session for user: $username');
      return null;
    }

    print('User logged in: $username, session created: ${sessionResult['id']}');

    return Session.fromPostgresRow(sessionResult);
  }

  /// Récupère un utilisateur par son ID.
  Future<User?> getUserById(int userId) async {
    final result = await _db.queryOne(
      'SELECT id, username, email, role, full_name, service_id, created_at '
      'FROM users WHERE id = @user_id',
      parameters: {'user_id': userId},
    );

    if (result == null) return null;

    return User.fromPostgresRow(result);
  }

  /// Récupère un utilisateur par son jeton de session.
  Future<User?> getUserByToken(String token) async {
    final sessionResult = await _db.queryOne(
      'SELECT user_id, expires_at FROM sessions WHERE token = @token',
      parameters: {'token': token},
    );

    if (sessionResult == null) {
      print('Session not found for token');
      return null;
    }

    // Vérifier l'expiration
    final expiresAt = sessionResult['expires_at'] as DateTime?;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      print('Session expired');
      return null;
    }

    final userId = sessionResult['user_id'] as int;
    return await getUserById(userId);
  }

  /// Déconnecte une session (supprime le jeton).
  Future<bool> logout(String token) async {
    final result = await _db.execute(
      'DELETE FROM sessions WHERE token = @token',
      parameters: {'token': token},
    );

    final deleted = result.affectedRows;
    print('Logout: $deleted session(s) deleted');
    return deleted > 0;
  }

  /// Crée un nouvel utilisateur (pour l'administration).
  Future<User?> createUser({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    String? fullName,
    int? serviceId,
  }) async {
    final passwordHash = hashPassword(password);
    final now = DateTime.now();

    final result = await _db.queryOne(
      'INSERT INTO users (username, email, password_hash, role, full_name, service_id, created_at) '
      'VALUES (@username, @email, @password_hash, @role, @full_name, @service_id, @created_at) '
      'RETURNING id, username, email, role, full_name, service_id, created_at',
      parameters: {
        'username': username,
        'email': email,
        'password_hash': passwordHash,
        'role': role.value,
        'full_name': fullName,
        'service_id': serviceId,
        'created_at': now.toIso8601String(),
      },
    );

    if (result == null) {
      print('Failed to create user: $username');
      return null;
    }

    print('User created: $username');
    return User.fromPostgresRow(result);
  }
}

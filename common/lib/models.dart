/// Modèles de données partagés entre client et serveur.

/// Rôles possibles pour un utilisateur.
enum UserRole {
  student('STUDENT'),
  agent('AGENT'),
  admin('ADMIN');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Invalid role: $value'),
    );
  }
}

/// Modèle représentant un utilisateur du système.
class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.serviceId,
    this.createdAt,
  });

  /// Identifiant unique de l'utilisateur en base de données.
  final int id;

  /// Nom d'utilisateur pour la connexion.
  final String username;

  /// Adresse email de l'utilisateur.
  final String email;

  /// Rôle de l'utilisateur (STUDENT, AGENT, ADMIN).
  final UserRole role;

  /// Nom complet de l'utilisateur (optionnel).
  final String? fullName;

  /// Identifiant du service pour les agents (optionnel).
  final int? serviceId;

  /// Date de création du compte (optionnel).
  final DateTime? createdAt;

  /// Crée un User depuis une Map (typiquement depuis JSON ou PostgreSQL).
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      fullName: json['full_name'] as String?,
      serviceId: json['service_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convertit le User en Map (pour JSON ou PostgreSQL).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.value,
      'full_name': fullName,
      'service_id': serviceId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Crée un User depuis une ligne PostgreSQL.
  factory User.fromPostgresRow(Map<String, dynamic> row) {
    return User(
      id: row['id'] as int,
      username: row['username'] as String,
      email: row['email'] as String,
      role: UserRole.fromString(row['role'] as String),
      fullName: row['full_name'] as String?,
      serviceId: row['service_id'] as int?,
      createdAt: row['created_at'] as DateTime?,
    );
  }

  /// Copie le User avec certains champs modifiés.
  User copyWith({
    int? id,
    String? username,
    String? email,
    UserRole? role,
    String? fullName,
    int? serviceId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      serviceId: serviceId ?? this.serviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: ${role.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle représentant une session utilisateur.
class Session {
  Session({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
    this.expiresAt,
  });

  /// Identifiant unique de la session.
  final int id;

  /// Identifiant de l'utilisateur associé.
  final int userId;

  /// Jeton de session (token).
  final String token;

  /// Date de création de la session.
  final DateTime createdAt;

  /// Date d'expiration de la session (optionnel).
  final DateTime? expiresAt;

  /// Crée une Session depuis une Map.
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      token: json['token'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convertit la Session en Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'token': token,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Crée une Session depuis une ligne PostgreSQL.
  factory Session.fromPostgresRow(Map<String, dynamic> row) {
    return Session(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      token: row['token'] as String,
      createdAt: row['created_at'] as DateTime,
      expiresAt: row['expires_at'] as DateTime?,
    );
  }

  /// Vérifie si la session est expirée.
  bool isExpired() {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  String toString() {
    return 'Session(id: $id, userId: $userId, token: $token, expiresAt: $expiresAt)';
  }
}

/// Service de connexion à la base de données PostgreSQL.
library;

import 'package:postgres/postgres.dart';

/// Service singleton pour la connexion PostgreSQL.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get instance => _instance;

  Connection? _connection;

  /// Connexion active à la base de données.
  Connection get connection {
    if (_connection == null) {
      throw StateError('Database not connected. Call connect() first.');
    }
    return _connection!;
  }

  /// État de la connexion.
  bool get isConnected => _connection != null && _connection!.isOpen;

  /// Connecte à la base de données PostgreSQL.
  ///
  /// Les paramètres de connexion sont lus depuis les variables d'environnement
  /// ou utilisent des valeurs par défaut pour le développement.
  Future<void> connect({
    String host = 'localhost',
    int port = 5432,
    String database = 'noh_cloudmesh',
    String username = 'postgres',
    String password = 'postgres',
  }) async {
    if (isConnected) {
      return;
    }

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
    );

    print('Connected to PostgreSQL database: $database');
  }

  /// Ferme la connexion à la base de données.
  Future<void> close() async {
    if (_connection != null && _connection!.isOpen) {
      await _connection!.close();
      _connection = null;
      print('Database connection closed.');
    }
  }

  /// Exécute une requête SQL et retourne les résultats.
  Future<Result> execute(String query, {Map<String, dynamic>? parameters}) async {
    if (!isConnected) {
      throw StateError('Database not connected.');
    }

    return await connection.execute(query, parameters: parameters);
  }

  /// Exécute une requête SQL et retourne la première ligne.
  Future<Map<String, dynamic>?> queryOne(
    String query, {
    Map<String, dynamic>? parameters,
  }) async {
    final result = await execute(query, parameters: parameters);
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Exécute une requête SQL et retourne toutes les lignes.
  Future<List<Map<String, dynamic>>> queryAll(
    String query, {
    Map<String, dynamic>? parameters,
  }) async {
    final result = await execute(query, parameters: parameters);
    return result.map((row) => row.toColumnMap()).toList();
  }
}

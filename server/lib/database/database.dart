/// Service de connexion à la base de données SQLite.
library;

import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// Service singleton pour la connexion SQLite.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get instance => _instance;

  Database? _db;

  /// Base de données active.
  Database get db {
    if (_db == null) {
      throw StateError('Database not connected. Call connect() first.');
    }
    return _db!;
  }

  /// État de la connexion.
  bool get isConnected => _db != null;

  /// Connecte à la base de données SQLite.
  ///
  /// Crée le fichier de base de données s'il n'existe pas.
  Future<void> connect({String path = 'noh_cloudmesh.db'}) async {
    if (isConnected) {
      return;
    }

    _db = sqlite3.open(path);
    print('Connected to SQLite database: $path');

    // Exécuter le schéma si la base est vide
    await _initializeSchema();
  }

  /// Initialise le schéma de la base de données.
  Future<void> _initializeSchema() async {
    final schemaFile = File('../database/schema_sqlite.sql');
    if (await schemaFile.exists()) {
      final schema = await schemaFile.readAsString();
      db.execute(schema);
      print('Schema initialized');
    } else {
      print('Warning: schema_sqlite.sql not found');
    }
  }

  /// Ferme la connexion à la base de données.
  Future<void> close() async {
    if (_db != null) {
      _db!.dispose();
      _db = null;
      print('Database connection closed.');
    }
  }

  /// Exécute une requête SQL et retourne les résultats.
  Future<ResultSet> execute(String query, [List<Object?>? parameters]) async {
    if (!isConnected) {
      throw StateError('Database not connected.');
    }

    return db.select(query, parameters ?? []);
  }

  /// Exécute une requête SQL et retourne la première ligne.
  Future<Map<String, dynamic>?> queryOne(
    String query, [
    List<Object?>? parameters,
  ]) async {
    final result = await execute(query, parameters);
    if (result.isEmpty) return null;
    return result.first;
  }

  /// Exécute une requête SQL et retourne toutes les lignes.
  Future<List<Map<String, dynamic>>> queryAll(
    String query, [
    List<Object?>? parameters,
  ]) async {
    final result = await execute(query, parameters);
    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Exécute une requête INSERT et retourne l'ID inséré.
  Future<int> insert(String query, [List<Object?>? parameters]) async {
    if (!isConnected) {
      throw StateError('Database not connected.');
    }

    db.execute(query, parameters ?? []);
    return db.lastInsertRowId;
  }

  /// Exécute une requête UPDATE ou DELETE et retourne le nombre de lignes affectées.
  Future<int> executeUpdate(String query, [List<Object?>? parameters]) async {
    if (!isConnected) {
      throw StateError('Database not connected.');
    }

    db.execute(query, parameters ?? []);
    return db.updatedRows;
  }
}

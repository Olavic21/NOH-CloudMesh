/// Service d'authentification côté client.
library;

import 'dart:math';

import 'package:noh_common/models.dart';
import 'package:noh_common/protocol.dart';
import 'tcp_client.dart';

/// Service d'authentification côté client.
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final TcpClient _tcpClient = TcpClient(host: 'localhost', port: 4000);

  /// État de connexion.
  bool get isConnected => _tcpClient.isConnected;

  /// Utilisateur actuellement connecté.
  User? _currentUser;
  User? get currentUser => _currentUser;

  /// Jeton de session actuel.
  String? _token;
  String? get token => _token;

  /// Stream des événements du serveur.
  Stream<Event> get eventStream => _tcpClient.eventStream;

  /// Connecte au serveur.
  Future<void> connect() async {
    await _tcpClient.connect();
  }

  /// Déconnecte du serveur.
  void disconnect() {
    _tcpClient.disconnect();
    _currentUser = null;
    _token = null;
  }

  /// Authentifie un utilisateur avec username et mot de passe.
  ///
  /// Retourne true si l'authentification réussit, false sinon.
  Future<bool> login(String username, String password) async {
    // Générer un ID de requête unique
    final requestId = 'req-${_generateRequestId()}';

    // Créer la requête LOGIN
    final request = Request(
      requestId: requestId,
      action: RequestAction.login,
      token: null, // Pas de token pour LOGIN
      payload: {
        'username': username,
        'password': password,
      },
    );

    // Envoyer la requête et attendre la réponse
    final response = await _tcpClient.sendRequest(request);

    // Vérifier le statut de la réponse
    if (response.status != ResponseStatus.success) {
      print('Login failed: ${response.error}');
      return false;
    }

    // Extraire les données de la réponse
    final data = response.data;
    if (data == null) {
      print('Login failed: no data in response');
      return false;
    }

    // Stocker le token et l'utilisateur
    _token = data['token'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;
    if (userData != null) {
      _currentUser = User.fromJson(userData);
    }

    print('Login successful: ${_currentUser?.username}');
    return true;
  }

  /// Déconnecte l'utilisateur.
  Future<void> logout() async {
    if (_token == null) return;

    final requestId = 'req-${_generateRequestId()}';
    final request = Request(
      requestId: requestId,
      action: RequestAction.logout,
      token: _token,
    );

    try {
      await _tcpClient.sendRequest(request);
    } catch (e) {
      print('Logout error: $e');
    }

    disconnect();
  }

  /// Récupère le profil de l'utilisateur connecté.
  Future<User?> getProfile() async {
    if (_token == null) return null;

    final requestId = 'req-${_generateRequestId()}';
    final request = Request(
      requestId: requestId,
      action: RequestAction.getProfile,
      token: _token,
    );

    final response = await _tcpClient.sendRequest(request);

    if (response.status != ResponseStatus.success) {
      print('GetProfile failed: ${response.error}');
      return null;
    }

    final data = response.data;
    if (data == null) return null;

    final userData = data['user'] as Map<String, dynamic>?;
    if (userData == null) return null;

    _currentUser = User.fromJson(userData);
    return _currentUser;
  }

  /// Met à jour le profil de l'utilisateur connecté.
  Future<bool> updateProfile({
    String? fullName,
    String? email,
  }) async {
    if (_token == null) return false;

    final requestId = 'req-${_generateRequestId()}';
    final request = Request(
      requestId: requestId,
      action: RequestAction.updateProfile,
      token: _token,
      payload: {
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
      },
    );

    final response = await _tcpClient.sendRequest(request);

    if (response.status != ResponseStatus.success) {
      print('UpdateProfile failed: ${response.error}');
      return false;
    }

    final data = response.data;
    if (data == null) return false;

    final userData = data['user'] as Map<String, dynamic>?;
    if (userData != null) {
      _currentUser = User.fromJson(userData);
    }

    return true;
  }

  /// Génère un ID de requête aléatoire.
  String _generateRequestId() {
    final random = Random();
    return (random.nextInt(1000000)).toString();
  }

  /// Libère les ressources.
  void dispose() {
    _tcpClient.dispose();
  }
}

/// Écran de connexion (login).
library;

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Écran de connexion.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Service d'authentification
  final AuthService _auth = AuthService.instance;

  // Contrôleurs pour les champs de texte
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // État de chargement
  bool _isLoading = false;

  // Message d'erreur
  String? _errorMessage;

  @override
  void dispose() {
    // Libérer les contrôleurs quand l'écran est détruit
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Tente de connecter l'utilisateur.
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Validation basique
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    // Afficher l'état de chargement
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Connecter au serveur si ce n'est pas déjà fait
      if (!_auth.isConnected) {
        await _auth.connect();
      }

      // Tenter la connexion
      final success = await _auth.login(username, password);

      if (success) {
        // Connexion réussie
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // TODO: Naviguer vers l'écran principal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie !')),
          );
        }
      } else {
        // Connexion échouée
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Nom d\'utilisateur ou mot de passe incorrect';
          });
        }
      }
    } catch (e) {
      // Erreur de connexion au serveur
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur de connexion au serveur: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('N.O.H. CloudMesh - Connexion'),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou titre
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour accéder à votre espace',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Message d'erreur
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // Champ username
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    hintText: 'Entrez votre nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Champ password
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Masque le mot de passe
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                  onSubmitted: (_) => _login(), // Login avec Entrée
                ),
                const SizedBox(height: 24),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Informations de connexion de test
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compte de test :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Username: admin'),
                      const Text('Password: admin123'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

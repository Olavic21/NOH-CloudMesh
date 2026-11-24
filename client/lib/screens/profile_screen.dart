/// Écran de profil utilisateur.
library;

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Écran de profil utilisateur.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService.instance;

  // Contrôleurs pour les champs modifiables
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Charge le profil de l'utilisateur.
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _auth.getProfile();
      if (user != null) {
        _fullNameController.text = user.fullName ?? '';
        _emailController.text = user.email;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du profil: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sauvegarde les modifications du profil.
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _auth.updateProfile(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la mise à jour du profil';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Déconnecte l'utilisateur.
  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar et informations de base
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              user?.username.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.username ?? 'Utilisateur',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(user?.role.value ?? 'UNKNOWN'),
                            backgroundColor: _getRoleColor(user?.role.value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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

                  // Informations modifiables
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Informations personnelles',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                                child: Text(_isEditing ? 'Annuler' : 'Modifier'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nom complet
                          TextField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom complet',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Nom d'utilisateur (non modifiable)
                          TextField(
                            controller: TextEditingController(text: user?.username ?? ''),
                            decoration: const InputDecoration(
                              labelText: 'Nom d\'utilisateur',
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),

                          // Bouton de sauvegarde
                          if (_isEditing) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
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
                                  : const Text('Sauvegarder'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations système
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations système',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('ID', user?.id.toString() ?? 'N/A'),
                          _buildInfoRow('Rôle', user?.role.value ?? 'N/A'),
                          _buildInfoRow(
                            'Service',
                            user?.serviceId?.toString() ?? 'Aucun',
                          ),
                          _buildInfoRow(
                            'Date de création',
                            user?.createdAt?.toString() ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Construit une ligne d'information.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Retourne la couleur selon le rôle.
  Color _getRoleColor(String? role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red[100]!;
      case 'AGENT':
        return Colors.orange[100]!;
      case 'STUDENT':
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}

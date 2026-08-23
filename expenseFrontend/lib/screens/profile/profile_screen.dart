import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  // Contrôleurs de formulaire
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  // Déclaration des champs
  String _userNom = '';
  String _userPrenom = '';
  String _userSexe = 'Masculin';
  String _userPhone = '';
  String _userAvatar = '';
  String _userEmail = '';
  String _userName =
      'Victoire Hounkpatin'; // Valeur par défaut si les données ne sont pas encore chargées
  String _userId = '';
  bool _isLoading = true;

  // Options de sécurité (états réactifs)
  bool _biometricEnabled = false;
  bool _pinCodeEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  /// Charge les données locales puis effectue la requête dynamique vers l'API
  Future<void> _loadUserData() async {
    final id = await _authService.getUserId();
    setState(() => _userId = id ?? '');

    if (_userId.isNotEmpty) {
      try {
        final response = await _apiService.get('/users/$_userId');
        final data = response['data'] ?? response;

        if (data != null && mounted) {
          setState(() {
            _userNom = data['nom'] ?? '';
            _userPrenom = data['prenom'] ?? '';
            _userEmail = data['email'] ?? '';
            _userSexe = data['sexe'] ?? 'Non précisé';
            _userPhone = data['telephone'] ?? data['phone'] ?? '';
            _userAvatar = data['avatar'] ?? '';
            _userName = '$_userNom $_userPrenom'.trim();
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Erreur lors de la récupération des infos : $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// Extrait les initiales du nom pour la photo de profil (ex: Victoire Hounkpatin -> VH)
  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'VH';
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Affiche le popup des informations personnelles éditables
  void _showPersonalDetails() {
    _nomController.text = _userNom;
    _prenomController.text = _userPrenom;
    _phoneController.text = _userPhone;
    _emailController.text = _userEmail;
    _userNameController.text = _userName;

    String selectedSexe = _userSexe.isNotEmpty ? _userSexe : 'Masculin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations Personnelles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Nom
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF3B6334)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Prénoms
                  TextField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: 'Prénoms',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Color(0xFF3B6334),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sexe (Dropdown)
                  DropdownButtonFormField<String>(
                    initialValue: ['Masculin', 'Féminin'].contains(selectedSexe)
                        ? selectedSexe
                        : 'Masculin',
                    decoration: const InputDecoration(
                      labelText: 'Sexe',
                      prefixIcon: Icon(Icons.wc, color: Color(0xFF3B6334)),
                    ),
                    items: ['Masculin', 'Féminin']
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedSexe = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Adresse e-mail (Non éditable - Clé unique)
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF3B6334)),
                    ),
                  ),
                  const Divider(),

                  // Téléphone
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF3B6334)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton de sauvegarde BDD
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B6334),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          // Envoi dynamique des requêtes vers l'API Backend
                          await _apiService.put('/users/$_userId', {
                            'nom': _nomController.text.trim(),
                            'prenom': _prenomController.text.trim(),
                            'email': _emailController.text.trim(),
                            'sexe': selectedSexe,
                            'telephone': _phoneController.text.trim(),
                          });

                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            _loadUserData(); // Recharge immédiatement les données depuis l'API
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profil mis à jour avec succès !',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de la mise à jour : $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Affiche le popup dynamique de sécurité du compte
  void _showSecurityModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sécurité du compte',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(
                    Icons.lock_reset,
                    color: Color(0xFF3B6334),
                  ),
                  title: const Text('Changer le mot de passe'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _showChangePasswordDialog();
                  },
                ),
                const Divider(),

                SwitchListTile(
                  secondary: const Icon(
                    Icons.fingerprint,
                    color: Color(0xFF3B6334),
                  ),
                  title: const Text('Empreinte / Face ID'),
                  subtitle: const Text('Connexion par biométrie'),
                  value: _biometricEnabled,
                  onChanged: (val) {
                    setModalState(() => _biometricEnabled = val);
                    setState(() => _biometricEnabled = val);
                  },
                ),

                SwitchListTile(
                  secondary: const Icon(Icons.pin, color: Color(0xFF3B6334)),
                  title: const Text('Code PIN de sécurité'),
                  subtitle: const Text(
                    'Code à 4 chiffres pour valider les actions',
                  ),
                  value: _pinCodeEnabled,
                  onChanged: (val) {
                    setModalState(() => _pinCodeEnabled = val);
                    setState(() => _pinCodeEnabled = val);
                  },
                ),

                SwitchListTile(
                  secondary: const Icon(
                    Icons.security,
                    color: Color(0xFF3B6334),
                  ),
                  title: const Text('Authentification à 2 facteurs (2FA)'),
                  subtitle: const Text('Code de sécurité par SMS ou Email'),
                  value: _twoFactorEnabled,
                  onChanged: (val) {
                    setModalState(() => _twoFactorEnabled = val);
                    setState(() => _twoFactorEnabled = val);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Boîte de dialogue pour le changement de mot de passe
  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau mot de passe'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Saisissez le nouveau mot de passe',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B6334),
            ),
            onPressed: () async {
              if (passwordController.text.trim().isEmpty) return;
              try {
                await _apiService.put('/users/password/$_userId', {
                  'password': passwordController.text,
                });
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mot de passe mis à jour avec succès !'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(
                    // ignore: use_build_context_synchronously
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
                }
              }
            },
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Traitement de la déconnexion
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B6334)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Utilisateur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFF3B6334),
                backgroundImage: _userAvatar.isNotEmpty
                    ? NetworkImage(_userAvatar)
                    : null,
                child: _userAvatar.isEmpty
                    ? Text(
                        _getInitials(_userName),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userName.isNotEmpty ? _userName : 'Victoire Hounkpatin',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(_userEmail, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF3B6334),
                    ),
                    title: const Text(
                      'Informations personnelles',
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showPersonalDetails,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF3B6334),
                    ),
                    title: const Text(
                      'Sécurité & Mot de passe',
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showSecurityModal,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Déconnexion',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

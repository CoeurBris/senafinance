
import 'package:flutter/material.dart';
import 'package:senafinance/core/widgets/settings_card.dart';
import 'package:senafinance/screens/auth/login_screen.dart';
import 'package:senafinance/services/api_service.dart';
import 'package:senafinance/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAccent = Color(0xFF3B6334);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _userNom = '';
  String _userPrenom = '';
  String _userSexe = '';
  String _userPhone = '';
  String _userAvatar = '';
  String _userEmail = '';
  String _userName = '';
  String _userId = '';
  bool _isLoading = true;

  // Réglages de sécurité — persistés localement (à remplacer par un vrai
  // stockage sécurisé / appel API selon la stratégie retenue par le projet).
  bool _biometricEnabled = false;
  bool _pinCodeEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSecurityPrefs();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Charge les données utilisateur depuis l'API, puis synchronise le cache
  /// local (AuthService) pour que les autres écrans (ex: Paramètres)
  /// affichent toujours des informations à jour.
  Future<void> _loadUserData() async {
    final id = await _authService.getUserId();
    setState(() => _userId = id ?? '');

    if (_userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _apiService.get('/users/$_userId');
      final data = response['data'] ?? response;

      if (data != null && mounted) {
        final prenom = data['prenom'] ?? '';
        final nom = data['nom'] ?? '';
        final fullName = prenom.toString().isNotEmpty ? '$nom $prenom'.trim() : nom.toString();

        setState(() {
          _userNom = nom.toString();
          _userPrenom = prenom.toString();
          _userEmail = data['email'] ?? '';
          _userSexe = data['sexe'] ?? 'Non précisé';
          _userPhone = data['telephone'] ?? data['phone'] ?? '';
          _userAvatar = data['avatar'] ?? '';
          _userName = fullName;
          _isLoading = false;
        });

        // Resynchronise le cache local utilisé par l'écran Paramètres.
        await _authService.saveUserData(_userId, fullName, _userEmail);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des infos : $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSecurityPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _biometricEnabled = prefs.getBool('security_biometric') ?? false;
      _pinCodeEnabled = prefs.getBool('security_pin') ?? false;
      _twoFactorEnabled = prefs.getBool('security_2fa') ?? false;
    });
  }

  Future<void> _setSecurityPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // ── Informations personnelles ──────────────────────────────
  void _showPersonalDetails() {
    _nomController.text = _userNom;
    _prenomController.text = _userPrenom;
    _phoneController.text = _userPhone;
    _emailController.text = _userEmail;

    String selectedSexe = ['Masculin', 'Féminin'].contains(_userSexe) ? _userSexe : 'Masculin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informations personnelles',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person, color: _kAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: 'Prénoms',
                      prefixIcon: Icon(Icons.person_outline, color: _kAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSexe,
                    decoration: const InputDecoration(
                      labelText: 'Sexe',
                      prefixIcon: Icon(Icons.wc, color: _kAccent),
                    ),
                    items: ['Masculin', 'Féminin']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSexe = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      prefixIcon: Icon(Icons.email, color: _kAccent),
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone, color: _kAccent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _savePersonalDetails(context, selectedSexe),
                      child: Text('Enregistrer', style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 16)),
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

  Future<void> _savePersonalDetails(BuildContext sheetContext, String selectedSexe) async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        const SnackBar(content: Text('Identifiant utilisateur introuvable. Reconnectez-vous.')),
      );
      return;
    }
    try {
      await _apiService.put('/users/$_userId', {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'sexe': selectedSexe,
        'telephone': _phoneController.text.trim(),
      });

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pop(sheetContext);
      await _loadUserData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès !')),
      );
    } catch (e) {
      debugPrint('Erreur mise à jour profil : $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Une erreur est survenue lors de la mise à jour.")),
      );
    }
  }

  // ── Sécurité du compte ──────────────────────────────────────
  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () async {
                if (oldPasswordController.text.trim().isEmpty ||
                    newPasswordController.text.trim().isEmpty) {
                  setDialogState(() => errorText = 'Veuillez remplir les deux champs.');
                  return;
                }
                try {
                  await _apiService.put('/users/password/$_userId', {
                    'oldPassword': oldPasswordController.text,
                    'password': newPasswordController.text,
                  });
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mot de passe mis à jour avec succès !')),
                  );
                } catch (e) {
                  debugPrint('Erreur changement mot de passe : $e');
                  setDialogState(() => errorText = 'Mot de passe actuel incorrect ou erreur serveur.');
                }
              },
              child: Text('Enregistrer', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le compte', style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE24B4A)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true || _userId.isEmpty) return;

    try {
      await _apiService.delete('/users/$_userId');
      await _logout();
    } catch (e) {
      debugPrint('Erreur suppression compte : $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer le compte pour le moment.')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _kAccent)),
      );
    }

    return Scaffold(
      // backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Profil utilisateur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: _kAccent,
              backgroundImage: _userAvatar.isNotEmpty ? NetworkImage(_userAvatar) : null,
              child: _userAvatar.isEmpty
                  ? Text(
                      _getInitials(_userName),
                      style: TextStyle(fontSize: 36, color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _userName.isNotEmpty ? _userName : '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Center(
            child: Text(_userEmail, style: const TextStyle(fontSize: 13, color: Color(0xFF888780))),
          ),
          const SizedBox(height: 24),

          const SectionLabel(label: 'Informations personnelles'),
          SettingsCard(
            children: [
              NavRow(
                icon: Icons.person_outline_rounded,
                iconBg: const Color(0xFFE1F5EE),
                iconColor: _kAccent,
                title: 'Modifier mes informations',
                subtitle: _userName,
                isLast: true,
                onTap: _showPersonalDetails,
              ),
            ],
          ),
          const SizedBox(height: 20),

          const SectionLabel(label: 'Sécurité du compte'),
          SettingsCard(
            children: [
              NavRow(
                icon: Icons.lock_reset_rounded,
                iconBg: const Color(0xFFE1F5EE),
                iconColor: _kAccent,
                title: 'Changer le mot de passe',
                onTap: _showChangePasswordDialog,
              ),
              ToggleRow(
                icon: Icons.fingerprint_rounded,
                iconBg: const Color(0xFFE1F5EE),
                iconColor: _kAccent,
                title: 'Empreinte / Face ID',
                subtitle: 'Connexion par biométrie',
                value: _biometricEnabled,
                onChanged: (v) {
                  setState(() => _biometricEnabled = v);
                  _setSecurityPref('security_biometric', v);
                },
              ),
              ToggleRow(
                icon: Icons.pin_rounded,
                iconBg: const Color(0xFFE1F5EE),
                iconColor: _kAccent,
                title: 'Code PIN de sécurité',
                subtitle: 'Valide les actions sensibles',
                value: _pinCodeEnabled,
                onChanged: (v) {
                  setState(() => _pinCodeEnabled = v);
                  _setSecurityPref('security_pin', v);
                },
              ),
              ToggleRow(
                icon: Icons.shield_outlined,
                iconBg: const Color(0xFFE1F5EE),
                iconColor: _kAccent,
                title: 'Authentification à 2 facteurs',
                subtitle: 'Code de sécurité par SMS ou email',
                value: _twoFactorEnabled,
                isLast: true,
                onChanged: (v) {
                  setState(() => _twoFactorEnabled = v);
                  _setSecurityPref('security_2fa', v);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          SettingsCard(
            children: [
              NavRow(
                icon: Icons.delete_outline_rounded,
                iconBg: const Color(0xFFFCEBEB),
                iconColor: const Color(0xFFE24B4A),
                title: 'Supprimer le compte',
                titleColor: const Color(0xFFE24B4A),
                isLast: true,
                onTap: _confirmDeleteAccount,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
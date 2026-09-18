import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:senafinance/screens/auth/register_screen.dart';
import 'package:senafinance/screens/dashboard/dashboard_screen.dart';
import 'package:senafinance/services/auth_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _rememberMe = false;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Traitement de la connexion
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Appel du service d'authentification backend
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // 2. Navigation vers le tableau de bord / accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      // 3. Affichage du message d'erreur retourné par le backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On met un fond de secours (dégradé vert) au cas où l'image
      // ne se charge pas -> plus jamais d'écran noir derrière le formulaire.
      // backgroundColor: const Color(0xFF3B6334),
      body: Stack(
        children: [
          // 1. Image de fond occupant tout l'écran
          Positioned.fill(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
            ),
          ),
          // Positioned.fill(
          //   child: Container(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     decoration: const BoxDecoration(
          //       // Dégradé affiché tant que/si l'image ne s'affiche pas
          //       gradient: LinearGradient(
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         colors: [Color(0xFF6B9E5E), Color(0xFF2E5A27)],
          //       ),
          //     ),
          //     // child: Image.asset(
          //     //   'assets/images/green_flowers_bg.png',
          //     //   fit: BoxFit.cover,
          //     //   width: double.infinity,
          //     //   height: double.infinity,
          //     //   // Si l'asset est introuvable, on garde le dégradé au lieu
          //     //   // de planter / d'afficher du noir.
          //     //   errorBuilder: (context, error, stackTrace) {
          //     //     return const SizedBox.shrink();
          //     //   },
          //     // ),
          //   ),
          // ),

          // 2. Contenu centré avec effet de verre
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: ConstrainedBox(
                // Cadre agrandi : on autorise jusqu'à 480px de large
                // au lieu de suivre uniquement le contenu.
                constraints: const BoxConstraints(maxWidth: 480),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      // Padding interne augmenté (24 -> 32) pour agrandir
                      // le cadre autour de tout le contenu.
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        // Opacité augmentée (0.55 -> 0.80) pour que la carte
                        // se détache mieux du fond image maintenant qu'il
                        // s'affiche correctement.
                        color: const Color(0xFFD4E8D4).withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo SenaTrack
                            const Icon(
                              Icons.insert_chart_rounded,
                              size: 58,
                              color: Color(0xFF689F38),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'SenaTrack',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E5A27),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Titre & Description
                            const Text(
                              'Bienvenue à Bord',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Gérer vos dépenses avec Élégance\nAtteignez Vos Objectifs Budgétaires',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Champ Adresse e-mail
                            _buildInputLabel('Adresse e-mail'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || !val.contains('@')) {
                                  return 'E-mail invalide';
                                }
                                return null;
                              },
                              decoration: _inputDecoration('Adresse e-mail'),
                            ),
                            const SizedBox(height: 18),

                            // Champ Mot de passe
                            _buildInputLabel('Mot de passe'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Veuillez entrer votre mot de passe';
                                }
                                return null;
                              },
                              decoration: _inputDecoration('Mot de passe')
                                  .copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 18),

                            // Option Souvenir de moi & Mot de passe oublié
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF3B6334),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Text(
                                      'Se souvenir de moi',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),

                                GestureDetector(
                                  onTap: () {
                                    // Action pour mot de passe oublié
                                  },
                                  child: const Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Bouton Se Connecter
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B6334),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'SE CONNECTER',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Séparateur
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Colors.black26),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    'Ou connectez-vous avec',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Colors.black26),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Boutons Réseaux Sociaux (Google & Facebook)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  child: const Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF388E3C),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _buildSocialButton(
                                  child: const Text(
                                    'f',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3F51B5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Redirection vers l'inscription
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Pas encore de compte ? ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Inscription',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        // Couleur renforcée (noir plein + poids 600) pour un meilleur
        // contraste sur le fond image désormais visible.
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF436C3C), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B6334), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildSocialButton({required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:senafinance/l10n/app_localizations.dart';
import '../../services/api_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSending = false;
  String _selectedCategory = 'Général';
  String _searchQuery = '';

  // Liste des questions fréquentes (FAQ)
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Comment réinitialiser mon mot de passe ?',
      'answer':
          'Rendez-vous dans la section Profil > Sécurité & Mot de passe pour modifier vos identifiants ou cliquez sur "Mot de passe oublié" à la connexion.',
      'category': 'Compte',
    },
    {
      'question': 'Comment exporter mes rapports de dépenses ?',
      'answer':
          'Allez sur votre tableau de bord, sélectionnez la période souhaitée puis appuyez sur le bouton d\'exportation (Format CSV ou Excel).',
      'category': 'Fonctionnalités',
    },
    {
      'question': 'Mes données bancaires et personnelles sont-elles sécurisées ?',
      'answer':
          'Oui, SenaTrack utilise un chiffrement AES de niveau bancaire et des communications sécurisées via HTTPS pour protéger toutes vos données.',
      'category': 'Sécurité',
    },
    {
      'question': 'Comment changer la langue de l\'application ?',
      'answer':
          'Rendez-vous dans Paramètres > Langue pour basculer entre le Français et l\'Anglais instantanément.',
      'category': 'Général',
    },
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Envoi du ticket de support à l'API
  Future<void> _sendSupportTicket() async {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs du formulaire.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await _apiService.post('/support/tickets', {
        'categorie': _selectedCategory,
        'sujet': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
      });

      if (mounted) {
        _subjectController.clear();
        _messageController.clear();
        Navigator.pop(context); // Ferme le modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre message a été envoyé à notre équipe support !'),
            backgroundColor: Color(0xFF3B6334),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Ouvre le formulaire de contact par ticket
  void _showContactModal() {
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
                    'Contacter le Support',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Catégorie de la demande
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category, color: Color(0xFF3B6334)),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Général', 'Compte', 'Facturation', 'Bug / Incohérence']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Sujet
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Sujet',
                      prefixIcon: Icon(Icons.subject, color: Color(0xFF3B6334)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description détaillée',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.message, color: Color(0xFF3B6334)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton d'envoi
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
                      onPressed: _isSending ? null : _sendSupportTicket,
                      child: _isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Envoyer le message',
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

  @override
  Widget build(BuildContext context) {
    final filteredFaq = _faqItems.where((item) {
      final q = item['question']!.toLowerCase();
      final a = item['answer']!.toLowerCase();
      return q.contains(_searchQuery) || a.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.supportTitle ?? 'Aide & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche dans la FAQ
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une solution...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3B6334)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cartes de raccourcis d'assistance
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xFF3B6334),
                    title: 'Billet de Support',
                    subtitle: 'Écrire à l\'équipe',
                    onTap: _showContactModal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.email_outlined,
                    color: const Color(0xFF854F0B),
                    title: 'E-mail Direct',
                    subtitle: 'support@gmail.com',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section Foire Aux Questions (FAQ)
            const Text(
              'Questions Fréquentes (FAQ)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            filteredFaq.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'Aucune question ne correspond à votre recherche.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFaq.length,
                    itemBuilder: (context, index) {
                      final item = filteredFaq[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ExpansionTile(
                          iconColor: const Color(0xFF3B6334),
                          title: Text(
                            item['question']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 16.0,
                              ),
                              child: Text(
                                item['answer']!,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  /// Helper pour construire une carte d'option d'assistance
  Widget _buildOptionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 20,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
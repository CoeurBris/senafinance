import 'package:app_expenses/models/objectif_model.dart';
import 'package:app_expenses/providers/objectif_provider.dart';
import 'package:app_expenses/screens/objectifs/objectif_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ---------------------------------------------------------------------------
/// ECRAN PRINCIPAL : Liste des objectifs d'épargne (branché sur ObjectifProvider)
/// ---------------------------------------------------------------------------
class ObjectifScreen extends StatefulWidget {
  const ObjectifScreen({super.key});

  @override
  State<ObjectifScreen> createState() => _ObjectifScreenState();
}

class _ObjectifScreenState extends State<ObjectifScreen> {
  @override
  void initState() {
    super.initState();
    // On attend la fin du premier build pour éviter d'appeler
    // notifyListeners() pendant la construction du widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObjectifProvider>().loadObjectifs();
    });
  }

  String _formatMontant(num v) {
    final s = v
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s FCFA';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Sans échéance';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // Icône/couleur déterministes à partir du titre, puisque le modèle
  // ne stocke pas ces attributs côté backend.
  static const _couleurs = [
    Colors.teal,
    Colors.blueAccent,
    Colors.deepOrange,
    Colors.purple,
    Colors.indigo,
    Colors.green,
  ];
  static const _icones = [
    Icons.savings,
    Icons.flight_takeoff,
    Icons.home,
    Icons.school,
    Icons.health_and_safety,
    Icons.directions_car,
  ];
  Color _couleurPour(String titre) =>
      _couleurs[titre.hashCode.abs() % _couleurs.length];
  IconData _iconePour(String titre) =>
      _icones[titre.hashCode.abs() % _icones.length];

  void _afficherErreurSiPresente(BuildContext context) {
    final provider = context.read<ObjectifProvider>();
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  void _ouvrirFormulaire({ObjectifModel? objectif}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormulaireObjectif(
        objectif: objectif,
        onValider: (modele) async {
          final provider = context.read<ObjectifProvider>();
          final ok = objectif == null
              ? await provider.createObjectif(modele)
              : await provider.updateObjectif(modele);

          if (!mounted) return;
          Navigator.pop(context);
          if (!ok) _afficherErreurSiPresente(context);
        },
      ),
    );
  }

  void _ajouterFonds(ObjectifModel objectif) {
    final controleur = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Ajouter à "${objectif.title}"'),
        content: TextField(
          controller: controleur,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Montant à ajouter',
            suffixText: 'FCFA',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final montant = double.tryParse(controleur.text) ?? 0;
              Navigator.pop(dialogContext);
              if (montant > 0 && objectif.id != null) {
                final ok = await context.read<ObjectifProvider>().addMontant(
                  objectif.id!,
                  montant,
                );
                if (!mounted) return;
                if (!ok) _afficherErreurSiPresente(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _confirmerSuppression(ObjectifModel objectif) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cet objectif ?'),
        content: Text(
          'L\'objectif "${objectif.title}" sera définitivement supprimé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (objectif.id != null) {
                final ok = await context
                    .read<ObjectifProvider>()
                    .deleteObjectif(objectif.id!);
                if (!mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Objectif "${objectif.title}" supprimé'),
                    ),
                  );
                } else {
                  _afficherErreurSiPresente(context);
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objectifs d\'épargne')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel objectif'),
      ),
      body: Consumer<ObjectifProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.objectifs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.objectifs.isEmpty) {
            return _EtatErreur(
              message: provider.error!,
              onReessayer: () => provider.loadObjectifs(),
            );
          }

          if (provider.objectifs.isEmpty) {
            return _EtatVide(onCreer: () => _ouvrirFormulaire());
          }

          final totalActuel = provider.objectifs.fold<double>(
            0,
            (s, o) => s + o.currentAmount,
          );
          final totalCible = provider.objectifs.fold<double>(
            0,
            (s, o) => s + o.targetAmount,
          );

          return RefreshIndicator(
            onRefresh: provider.loadObjectifs,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CarteResume(
                  totalEpargne: totalActuel,
                  totalCible: totalCible,
                  formatter: _formatMontant,
                ),
                const SizedBox(height: 20),
                Text(
                  'Mes objectifs (${provider.objectifs.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.objectifs.map(
                  (o) => _CarteObjectif(
                    objectif: o,
                    couleur: _couleurPour(o.title),
                    icone: _iconePour(o.title),
                    formatMontant: _formatMontant,
                    formatDate: _formatDate,
                    onAjouterFonds: () => _ajouterFonds(o),
                    onModifier: () => _ouvrirFormulaire(objectif: o),
                    onSupprimer: () => _confirmerSuppression(o),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARTE : Résumé global
/// ---------------------------------------------------------------------------
class _CarteResume extends StatelessWidget {
  final double totalEpargne;
  final double totalCible;
  final String Function(num) formatter;

  const _CarteResume({
    required this.totalEpargne,
    required this.totalCible,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final progression = totalCible <= 0
        ? 0.0
        : (totalEpargne / totalCible).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F9D8A), Color(0xFF0B6E62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total épargné',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            formatter(totalEpargne),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progression,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sur un objectif total de ${formatter(totalCible)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// CARTE : Un objectif individuel
/// ---------------------------------------------------------------------------
class _CarteObjectif extends StatelessWidget {
  final ObjectifModel objectif;
  final Color couleur;
  final IconData icone;
  final String Function(num) formatMontant;
  final String Function(DateTime?) formatDate;
  final VoidCallback onAjouterFonds;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;

  const _CarteObjectif({
    required this.objectif,
    required this.couleur,
    required this.icone,
    required this.formatMontant,
    required this.formatDate,
    required this.onAjouterFonds,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final progression = objectif.pourcentage / 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ObjectifDetailScreen(
                objectifId: objectif.id!,
                couleur: couleur,
                icone: icone,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: couleur.withValues(alpha: 0.15),
                    child: Icon(icone, color: couleur),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          objectif.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          objectif.estAtteint
                              ? 'Objectif atteint 🎉'
                              : 'Échéance : ${formatDate(objectif.targetDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: objectif.estAtteint
                                ? Colors.green
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (valeur) {
                      if (valeur == 'modifier') onModifier();
                      if (valeur == 'supprimer') onSupprimer();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'modifier',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 10),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'supprimer',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (objectif.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  objectif.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progression.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(couleur),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatMontant(objectif.currentAmount)} / ${formatMontant(objectif.targetAmount)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${objectif.pourcentage.toStringAsFixed(0)} %',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: couleur,
                    ),
                  ),
                ],
              ),
              if (!objectif.estAtteint) ...[
                const SizedBox(height: 4),
                Text(
                  'Reste ${formatMontant(objectif.montantRestant)} à épargner',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAjouterFonds,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Ajouter des fonds'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: couleur,
                    side: BorderSide(color: couleur),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// FORMULAIRE : Création / modification d'un objectif
/// ---------------------------------------------------------------------------
class _FormulaireObjectif extends StatefulWidget {
  final ObjectifModel? objectif;
  final void Function(ObjectifModel) onValider;

  const _FormulaireObjectif({this.objectif, required this.onValider});

  @override
  State<_FormulaireObjectif> createState() => _FormulaireObjectifState();
}

class _FormulaireObjectifState extends State<_FormulaireObjectif> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreCtrl;
  late TextEditingController _cibleCtrl;
  late TextEditingController _actuelCtrl;
  late TextEditingController _descriptionCtrl;
  DateTime? _dateLimite;
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    final o = widget.objectif;
    _titreCtrl = TextEditingController(text: o?.title ?? '');
    _cibleCtrl = TextEditingController(
      text: o != null ? o.targetAmount.toStringAsFixed(0) : '',
    );
    _actuelCtrl = TextEditingController(
      text: o != null ? o.currentAmount.toStringAsFixed(0) : '0',
    );
    _descriptionCtrl = TextEditingController(text: o?.description ?? '');
    _dateLimite = o?.targetDate;
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _cibleCtrl.dispose();
    _actuelCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateLimite ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _dateLimite = date);
  }

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _envoiEnCours = true);

    final base = widget.objectif;
    final modele = base != null
        ? base.copyWith(
            title: _titreCtrl.text.trim(),
            targetAmount: double.parse(_cibleCtrl.text),
            currentAmount: double.tryParse(_actuelCtrl.text) ?? 0,
            targetDate: _dateLimite,
            description: _descriptionCtrl.text.trim(),
          )
        : ObjectifModel(
            title: _titreCtrl.text.trim(),
            targetAmount: double.parse(_cibleCtrl.text),
            currentAmount: double.tryParse(_actuelCtrl.text) ?? 0,
            targetDate: _dateLimite,
            description: _descriptionCtrl.text.trim(),
          );

    widget.onValider(modele);
    // Le parent ferme le bottom sheet une fois l'appel réseau terminé ;
    // si le widget est toujours monté (ex: erreur réseau), on réactive le bouton.
    if (mounted) setState(() => _envoiEnCours = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.objectif == null
                  ? 'Nouvel objectif'
                  : 'Modifier l\'objectif',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'objectif',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cibleCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Montant cible (FCFA)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actuelCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Montant déjà épargné (FCFA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _choisirDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date limite (optionnel)',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dateLimite == null
                      ? 'Aucune échéance'
                      : '${_dateLimite!.day.toString().padLeft(2, '0')}/'
                            '${_dateLimite!.month.toString().padLeft(2, '0')}/'
                            '${_dateLimite!.year}',
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _envoiEnCours ? null : _valider,
                child: _envoiEnCours
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.objectif == null ? 'Créer' : 'Enregistrer'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ETAT VIDE : Aucun objectif
/// ---------------------------------------------------------------------------
class _EtatVide extends StatelessWidget {
  final VoidCallback onCreer;
  const _EtatVide({required this.onCreer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun objectif d\'épargne',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier objectif pour commencer à épargner',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreer,
            icon: const Icon(Icons.add),
            label: const Text('Créer un objectif'),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ETAT ERREUR : Échec du chargement initial
/// ---------------------------------------------------------------------------
class _EtatErreur extends StatelessWidget {
  final String message;
  final VoidCallback onReessayer;
  const _EtatErreur({required this.message, required this.onReessayer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onReessayer,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

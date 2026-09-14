import 'package:app_expenses/models/objectif_model.dart';
import 'package:app_expenses/providers/objectif_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_expenses/core/widgets/app_snackbar.dart';

class ObjectifScreen extends StatefulWidget {
  const ObjectifScreen({super.key});

  @override
  State<ObjectifScreen> createState() => _ObjectifScreenState();
}

class _ObjectifScreenState extends State<ObjectifScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObjectifProvider>().loadObjectifs();
    });
  }

  void _showAddGoalModal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? selectedDate;
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nouvel Objectif d\'Épargne',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'objectif',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant Cible (FCFA)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date limite (optionnelle)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Non définie'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          final target = double.tryParse(targetController.text);
                          if (titleController.text.trim().isEmpty ||
                              target == null) {
                            AppSnackbar.error(
                              context,
                              'Veuillez remplir tous les champs.',
                            );
                            return;
                          }

                          setModalState(() => submitting = true);

                          final ok = await context
                              .read<ObjectifProvider>()
                              .createObjectif(
                                ObjectifModel(
                                  title: titleController.text.trim(),
                                  targetAmount: target,
                                  targetDate: selectedDate,
                                ),
                              );

                          if (!mounted) return;

                          if (ok) {
                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Objectif créé avec succès 🎉',
                            );
                          } else {
                            setModalState(() => submitting = false);
                            final error = context.read<ObjectifProvider>().error;
                            AppSnackbar.error(
                              context,
                              error ?? "L'objectif n'a pas pu être créé.",
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Créer l\'objectif',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFundsModal(ObjectifModel goal) {
    final amountController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter au fonds — ${goal.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Montant à ajouter (FCFA)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            AppSnackbar.error(context, 'Montant invalide.');
                            return;
                          }

                          setModalState(() => submitting = true);

                          final ok = await context
                              .read<ObjectifProvider>()
                              .addMontant(goal.id!, amount);

                          if (!mounted) return;

                          if (ok) {
                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Montant ajouté avec succès 🎉',
                            );
                          } else {
                            setModalState(() => submitting = false);
                            final error = context.read<ObjectifProvider>().error;
                            AppSnackbar.error(
                              context,
                              error ?? "Le montant n'a pas pu être ajouté.",
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Ajouter',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGoalModal(ObjectifModel goal) {
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(
      text: goal.targetAmount.toInt().toString(),
    );
    DateTime? selectedDate = goal.targetDate;
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modifier l\'objectif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'objectif',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant Cible (FCFA)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate:
                        selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date limite',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Non définie'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          final target = double.tryParse(targetController.text);
                          if (titleController.text.trim().isEmpty ||
                              target == null) {
                            AppSnackbar.error(
                              context,
                              'Veuillez remplir tous les champs.',
                            );
                            return;
                          }
                          setModalState(() => submitting = true);

                          final ok = await context
                              .read<ObjectifProvider>()
                              .updateObjectif(
                                goal.copyWith(
                                  title: titleController.text.trim(),
                                  targetAmount: target,
                                  targetDate: selectedDate,
                                ),
                              );

                          if (!mounted) return;
                          if (ok) {
                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Objectif modifié avec succès',
                            );
                          } else {
                            setModalState(() => submitting = false);
                            final error = context.read<ObjectifProvider>().error;
                            AppSnackbar.error(
                              context,
                              error ?? "La modification a échoué.",
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(ObjectifModel goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'objectif ?'),
        content: Text('"${goal.title}" sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await context.read<ObjectifProvider>().deleteObjectif(goal.id!);
              if (!mounted) return;
              if (ok) {
                AppSnackbar.success(context, 'Objectif supprimé.');
              } else {
                final error = context.read<ObjectifProvider>().error;
                AppSnackbar.error(context, error ?? "La suppression a échoué.");
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGoalDetails(ObjectifModel goal) {
    context.read<ObjectifProvider>().loadVersements(goal.id!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer<ObjectifProvider>(
        builder: (ctx, provider, _) {
          final versements = provider.versementsOf(goal.id!);
          final projection = provider.dateProjetee(goal);
          final necessaire = provider.rythmeNecessaire(goal);
          final enRetard = provider.estEnRetard(goal);

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (projection != null)
                  Text(
                    'À ce rythme, objectif atteint le ${projection.day}/${projection.month}/${projection.year}',
                    style: const TextStyle(fontSize: 14),
                  ),
                if (enRetard && necessaire != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Il te faut épargner ~${necessaire.toInt()} FCFA/mois pour tenir la deadline.',
                        style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Historique des versements',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (versements.isEmpty)
                  const Text('Aucun versement pour le moment.')
                else
                  ...versements.reversed.map(
                    (v) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.arrow_upward,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                      title: Text('${v.montant.toInt()} FCFA'),
                      subtitle: v.createdAt != null
                          ? Text(
                              '${v.createdAt!.day}/${v.createdAt!.month}/${v.createdAt!.year}',
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construit la carte d'un objectif. `featured` ajoute une bordure verte
  /// distinctive pour l'objectif vedette.
  Widget _buildGoalCard(ObjectifModel goal, {bool featured = false}) {
    final percentage = goal.pourcentage.toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: featured
            ? const BorderSide(color: Color(0xFF10B981), width: 1.5)
            : BorderSide.none,
      ),
      elevation: featured ? 2 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showGoalDetails(goal),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') _showEditGoalModal(goal);
                      if (value == 'delete') _confirmDelete(goal);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: goal.pourcentage / 100,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF10B981),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Épargné: ${goal.currentAmount.toInt()} FCFA',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Objectif: ${goal.targetAmount.toInt()} FCFA',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Restant: ${goal.montantRestant.clamp(0, double.infinity).toInt()} FCFA',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                  if (goal.targetDate != null)
                    Flexible(
                      child: Text(
                        'Échéance: ${goal.targetDate!.day}/${goal.targetDate!.month}/${goal.targetDate!.year}',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: goal.estAtteint ? null : () => _showAddFundsModal(goal),
                  icon: const Icon(Icons.savings_outlined, size: 18),
                  label: Text(
                    goal.estAtteint ? 'Objectif atteint 🎉' : 'Ajouter au fonds',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectifProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Objectifs d\'Épargne')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        onPressed: _showAddGoalModal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Builder(
        builder: (_) {
          if (provider.isLoading && provider.objectifs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          if (provider.error != null && provider.objectifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ObjectifProvider>().loadObjectifs(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.objectifs.isEmpty) {
            return const Center(child: Text('Aucun objectif pour le moment.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ObjectifProvider>().loadObjectifs(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.objectifVedette != null) ...[
                  Row(
                    children: const [
                      Icon(Icons.star, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Objectif du moment',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildGoalCard(provider.objectifVedette!, featured: true),
                  const SizedBox(height: 24),
                ],
                if (provider.objectifsActifs.isNotEmpty) ...[
                  const Text(
                    'En cours',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ...provider.objectifsActifs
                      .where((o) => o.id != provider.objectifVedette?.id)
                      .map((g) => _buildGoalCard(g)),
                  const SizedBox(height: 24),
                ],
                if (provider.objectifsAtteints.isNotEmpty) ...[
                  Row(
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Atteints',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...provider.objectifsAtteints.map((g) => _buildGoalCard(g)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senafinance/models/objectif_model.dart';
import 'package:senafinance/models/versement_model.dart';
import 'package:senafinance/providers/objectif_provider.dart';

class ObjectifDetailScreen extends StatefulWidget {
  final int objectifId;
  final Color couleur;
  final IconData icone;

  const ObjectifDetailScreen({
    super.key,
    required this.objectifId,
    required this.couleur,
    required this.icone,
  });

  @override
  State<ObjectifDetailScreen> createState() => _ObjectifDetailScreenState();
}

class _ObjectifDetailScreenState extends State<ObjectifDetailScreen> {
  bool _loadingVersements = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ObjectifProvider>().loadVersements(widget.objectifId);
      if (mounted) setState(() => _loadingVersements = false);
    });
  }

  String _formatMontant(num v) {
    final s = v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$s FCFA';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _ajouterFonds(BuildContext context, ObjectifModel goal) {
    final controleur = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Ajouter à "${goal.title}"'),
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
              if (montant > 0) {
                final provider = context.read<ObjectifProvider>();
                final ok = await provider.addMontant(goal.id!, montant);
                if (ok) {
                  await provider.loadVersements(goal.id!);
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectifProvider>();
    final goal = provider.objectifs.firstWhere(
      (o) => o.id == widget.objectifId,
      orElse: () => ObjectifModel(title: '...', targetAmount: 0),
    );
    final versements = provider.versementsOf(widget.objectifId);

    final rythme = goal.id != null ? provider.rythmeMensuel(goal.id!) : 0.0;
    final dateProjetee = provider.dateProjetee(goal);
    final rythmeNecessaire = provider.rythmeNecessaire(goal);
    final enRetard = provider.estEnRetard(goal);

    return Scaffold(
      appBar: AppBar(title: Text(goal.title)),
      floatingActionButton: goal.estAtteint
          ? null
          : FloatingActionButton.extended(
              backgroundColor: widget.couleur,
              onPressed: () => _ajouterFonds(context, goal),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter des fonds'),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(goal),
          const SizedBox(height: 20),
          _buildRythmeCard(goal, rythme, dateProjetee, rythmeNecessaire, enRetard),
          const SizedBox(height: 20),
          _buildHistorique(versements),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(ObjectifModel goal) {
    final progression = goal.pourcentage / 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.couleur.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: widget.couleur.withValues(alpha: 0.15),
                child: Icon(widget.icone, color: widget.couleur),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (goal.description.isNotEmpty)
                      Text(goal.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
              if (goal.estAtteint)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Atteint 🎉',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progression.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: widget.couleur.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(widget.couleur),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${goal.pourcentage.toStringAsFixed(0)} %',
                style: TextStyle(fontWeight: FontWeight.bold, color: widget.couleur)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statBloc('Épargné', _formatMontant(goal.currentAmount))),
              Expanded(child: _statBloc('Cible', _formatMontant(goal.targetAmount))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statBloc(
                  'Reste',
                  _formatMontant(goal.montantRestant.clamp(0, goal.targetAmount)),
                ),
              ),
              Expanded(
                child: _statBloc(
                  'Échéance',
                  goal.targetDate != null ? _formatDate(goal.targetDate) : 'Aucune',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBloc(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildRythmeCard(
    ObjectifModel goal,
    double rythme,
    DateTime? dateProjetee,
    double? rythmeNecessaire,
    bool enRetard,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed_outlined, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text('Rythme & Projection',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          if (goal.estAtteint)
            Text('Objectif déjà atteint 🎉',
                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600))
          else if (rythme <= 0)
            Text(
              'Pas encore assez de versements pour calculer un rythme fiable.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            )
          else ...[
            _ligneInfo('Rythme actuel', '${_formatMontant(rythme)} / mois'),
            if (dateProjetee != null)
              _ligneInfo("Date d'atteinte estimée", _formatDate(dateProjetee)),
            if (rythmeNecessaire != null)
              _ligneInfo('Rythme requis pour la deadline',
                  '${_formatMontant(rythmeNecessaire)} / mois'),
          ],
          if (enRetard) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rythmeNecessaire != null
                          ? 'À ce rythme, tu risques de manquer ta deadline. Il te faut épargner ${_formatMontant(rythmeNecessaire)}/mois pour y arriver à temps.'
                          : 'À ce rythme, tu risques de manquer ta deadline.',
                      style: TextStyle(fontSize: 12.5, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ligneInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildHistorique(List<VersementModel> versements) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text('Historique des versements',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          if (_loadingVersements)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (versements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Aucun versement pour le moment.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            )
          else
            ...versements.reversed.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.couleur.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_downward, size: 15, color: widget.couleur),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_formatDate(v.createdAt),
                            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ),
                      Text('+${_formatMontant(v.montant)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.couleur)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
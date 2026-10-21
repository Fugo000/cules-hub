import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SquadScreen extends StatefulWidget {
  const SquadScreen({super.key});

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  late Future<Map<String, dynamic>> _squadFuture;

  @override
  void initState() {
    super.initState();
    _squadFuture = ApiService.fetchSquad2026();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      appBar: AppBar(
        title: const Text('Состав & Расстановка 26/27 (28 игроков)'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _squadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final data = snapshot.data ?? {};
          final squad = data['squad'] ?? {};
          final allPlayers = [
            ...(squad['goalkeepers'] ?? []),
            ...(squad['defenders'] ?? []),
            ...(squad['midfielders'] ?? []),
            ...(squad['forwards'] ?? []),
          ];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Text(
                  '⚽ Стартовый состав Ханси Флика (4-2-3-1) — Нажмите на игрока',
                  style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildPitch(context, allPlayers),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Text(
                  '📋 Полная заявка: Основа и Резерв сезона 2026/2027',
                  style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildCategory('Вратари', squad['goalkeepers'] ?? []),
              _buildCategory('Защитники', squad['defenders'] ?? []),
              _buildCategory('Полузащитники', squad['midfielders'] ?? []),
              _buildCategory('Нападающие', squad['forwards'] ?? []),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPitch(BuildContext context, List<dynamic> allPlayers) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF144517)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: Stack(
        children: [
          Center(child: Container(height: 1.5, color: Colors.white30)),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white30, width: 1.5)),
            ),
          ),
          _buildFieldPlayer(context, allPlayers, 'Габриэль Жезус', '9', 0.10, 0.50),
          _buildFieldPlayer(context, allPlayers, 'Рафинья', '11', 0.28, 0.16),
          _buildFieldPlayer(context, allPlayers, 'Дани Ольмо', '20', 0.26, 0.50),
          _buildFieldPlayer(context, allPlayers, 'Ламин Ямаль', '10', 0.28, 0.84),
          _buildFieldPlayer(context, allPlayers, 'Педри', '8', 0.49, 0.32),
          _buildFieldPlayer(context, allPlayers, 'Френки де Йонг', '21', 0.49, 0.68),
          _buildFieldPlayer(context, allPlayers, 'Алехандро Бальде', '3', 0.70, 0.12),
          _buildFieldPlayer(context, allPlayers, 'Пау Кубарси', '5', 0.72, 0.37),
          _buildFieldPlayer(context, allPlayers, 'Эрик Гарсия', '24', 0.72, 0.63),
          _buildFieldPlayer(context, allPlayers, 'Жюль Кунде', '23', 0.70, 0.88),
          _buildFieldPlayer(context, allPlayers, 'Жоан Гарсия', '1', 0.90, 0.50),
        ],
      ),
    );
  }

  Widget _buildFieldPlayer(BuildContext context, List<dynamic> allPlayers, String name, String number, double topAlign, double leftAlign) {
    final playerObj = allPlayers.firstWhere(
      (p) => (p['number']?.toString() ?? '') == number,
      orElse: () => {'name': name, 'number': number, 'pos': 'Starter', 'marketValue': '—'},
    );

    return Align(
      alignment: FractionalOffset(leftAlign, topAlign),
      child: GestureDetector(
        onTap: () => _showPlayerModal(context, playerObj),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFA50044),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerModal(BuildContext context, Map<String, dynamic> p) {
    final stats = p['stats2627'] as Map<String, dynamic>? ?? {};
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161822),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${p['number']} ${p['name']}', style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text('${p['pos']} • ${p['age']} лет • ${p['nationality']} • Роль: ${p['role'] ?? 'Состав'}', style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white24, height: 20),
            Text('Биометрия: ${p['height'] ?? '—'}, ${p['weight'] ?? '—'} • Нога: ${p['foot'] ?? '—'}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text('Контракт до: ${p['contractEnd'] ?? '—'} • Клаусула: ${p['clause'] ?? '—'}', style: const TextStyle(color: Colors.amber)),
            const SizedBox(height: 8),
            if (p['traits'] != null) Text('Навыки: ${p['traits']}', style: const TextStyle(color: Colors.lightBlueAccent)),
            const SizedBox(height: 8),
            if (stats.isNotEmpty)
              Text(
                'Статистика 26/27: Матчи: ${stats['matches'] ?? 0} | Голы: ${stats['goals'] ?? 0} | Ассисты: ${stats['assists'] ?? 0} | Точность пасов: ${stats['passAcc'] ?? '—'}',
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<dynamic> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('$title (${players.length})', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...players.map((p) {
          final stats = p['stats2627'] as Map<String, dynamic>? ?? {};
          final isStarter = p['role'] == 'Starter';
          return Card(
            color: const Color(0xFF1B1E2E),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: isStarter ? Colors.amber.withOpacity(0.4) : Colors.white10),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: isStarter ? const Color(0xFFA50044) : const Color(0xFF004D98),
                child: Text('#${p['number'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isStarter ? Colors.amber.withOpacity(0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(isStarter ? 'Старт' : 'Резерв', style: TextStyle(color: isStarter ? Colors.amber : Colors.white70, fontSize: 10)),
                  ),
                ],
              ),
              subtitle: Text('${p['pos']} • ${p['age']} лет • ${p['nationality'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Рост/Вес: ${p['height'] ?? '—'} / ${p['weight'] ?? '—'} • Рабочая нога: ${p['foot'] ?? '—'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Контракт до: ${p['contractEnd'] ?? '—'} • Отступные: ${p['clause'] ?? '—'}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                      if (p['traits'] != null) ...[
                        const SizedBox(height: 4),
                        Text('Сильные стороны: ${p['traits']}', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
                      ],
                      if (stats.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Сезон 26/27: Игр: ${stats['matches'] ?? 0} • Голов: ${stats['goals'] ?? 0} • Ассистов: ${stats['assists'] ?? 0} • Пасы: ${stats['passAcc'] ?? '—'}',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
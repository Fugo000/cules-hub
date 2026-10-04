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
        title: const Text('Состав & Расстановка 26/27'),
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

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('⚽ Расстановка (4-2-3-1)', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildPitch(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('📋 Заявка команды 2026/2027', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildPitch() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF1E4620),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white38, width: 2),
      ),
      child: Stack(
        children: [
          Center(child: Container(height: 1, color: Colors.white30)),
          Center(child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white30, width: 1.5)))),
          _buildFieldPlayer('Габриэль Жезус', '9', 0.12, 0.5),
          _buildFieldPlayer('Рафинья', '11', 0.30, 0.18),
          _buildFieldPlayer('Дани Ольмо', '20', 0.28, 0.5),
          _buildFieldPlayer('Ламин Ямаль', '10', 0.30, 0.82),
          _buildFieldPlayer('Педри', '8', 0.50, 0.33),
          _buildFieldPlayer('Френки де Йонг', '21', 0.50, 0.67),
          _buildFieldPlayer('Алехандро Бальде', '3', 0.70, 0.12),
          _buildFieldPlayer('Пау Кубарси', '5', 0.72, 0.37),
          _buildFieldPlayer('Эрик Гарсия', '24', 0.72, 0.63),
          _buildFieldPlayer('Жюль Кунде', '23', 0.70, 0.88),
          _buildFieldPlayer('Жоан Гарсия', '1', 0.88, 0.5),
        ],
      ),
    );
  }

  Widget _buildFieldPlayer(String name, String number, double topAlign, double leftAlign) {
    return Align(
      alignment: FractionalOffset(leftAlign, topAlign),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFA50044), shape: BoxShape.circle),
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
          ),
        ],
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
          child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        ...players.map((p) {
          final stats = p['stats2627'] as Map<String, dynamic>? ?? {};
          return Card(
            color: const Color(0xFF1B1E2E),
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFA50044),
                child: Text('#${p['number'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('${p['pos']} • ${p['age']} лет • ${p['nationality'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Рост/Вес: ${p['height'] ?? '—'} / ${p['weight'] ?? '—'} • Нога: ${p['foot'] ?? '—'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Контракт до: ${p['contractEnd'] ?? '—'} • Клаусула: ${p['clause'] ?? '—'}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                      if (p['traits'] != null) Text('Навыки: ${p['traits']}', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
                      if (stats.isNotEmpty) Text('Статистика 26/27: Матчи: ${stats['matches'] ?? 0}, Голы: ${stats['goals'] ?? 0}, Ассисты: ${stats['assists'] ?? 0}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
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
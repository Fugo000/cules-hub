import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MasiaScreen extends StatefulWidget {
  const MasiaScreen({super.key});

  @override
  State<MasiaScreen> createState() => _MasiaScreenState();
}

class _MasiaScreenState extends State<MasiaScreen> {
  late Future<Map<String, dynamic>> _masiaFuture;

  @override
  void initState() {
    super.initState();
    _masiaFuture = ApiService.fetchMasiaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      appBar: AppBar(
        title: const Text('La Masia & Barça Atlètic (Скаутинг)'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _masiaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final data = snapshot.data ?? {};
          final teamInfo = data['teamInfo'] ?? {};
          final players = data['players'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: const Color(0xFF161822),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA50044), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teamInfo['name'] ?? 'Barça Atlètic', style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Турнир: ${teamInfo['league'] ?? '—'}', style: const TextStyle(color: Colors.white70)),
                      Text('Стадион: ${teamInfo['stadium'] ?? '—'}', style: const TextStyle(color: Colors.white70)),
                      Text('Главный тренер: ${teamInfo['headCoach'] ?? '—'}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('Философия: ${teamInfo['tacticalSystem'] ?? '4-3-3'}', style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('⭐ Все таланты академии (${players.length})', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...players.map((p) {
                final pot = int.tryParse(p['potential']?.toString().split('/').first.trim() ?? '85') ?? 85;
                return Card(
                  color: const Color(0xFF1B1E2E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFA50044),
                                  radius: 17,
                                  child: Text('#${p['number'] ?? '—'}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('${p['pos']} • ${p['age']} лет • Рост: ${p['height'] ?? '—'} • Нога: ${p['foot'] ?? '—'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.greenAccent)),
                              child: Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        if (p['stats'] != null) Text('📊 Статистика: ${p['stats']}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 6),
                        if (p['traits'] != null) Text('⚡ Характеристики: ${p['traits']}', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 13)),
                        if (p['scoutingReport'] != null) ...[
                          const SizedBox(height: 6),
                          Text('🔍 Отчет скаута: ${p['scoutingReport']}', style: const TextStyle(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Потенциал развития:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('$pot / 99', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: pot / 99.0,
                          backgroundColor: Colors.white10,
                          color: Colors.purpleAccent,
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
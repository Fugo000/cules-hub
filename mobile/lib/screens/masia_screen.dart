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
        title: const Text('La Masia & Barça Atlètic'),
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
                      Text(
                        teamInfo['name'] ?? 'Barça Atlètic',
                        style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('Лига: ${teamInfo['league'] ?? '—'}', style: const TextStyle(color: Colors.white70)),
                      Text('Стадион: ${teamInfo['stadium'] ?? '—'}', style: const TextStyle(color: Colors.white70)),
                      Text('Главный тренер: ${teamInfo['headCoach'] ?? '—'}', style: const TextStyle(color: Colors.white70)),
                      Text('Тактическая система: ${teamInfo['tacticalSystem'] ?? '—'}', style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '⭐ Скаутинг-реестр воспитанников',
                style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...players.map((player) {
                return Card(
                  color: const Color(0xFF1B1E2E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(player['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text(player['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${player['pos']} • ${player['age']} лет • Потенциал: ${player['potential']}', style: const TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.white12, height: 16),
                        if (player['traits'] != null) Text('Навыки: ${player['traits']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        if (player['scoutingReport'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Скаутинг: ${player['scoutingReport']}', style: const TextStyle(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic)),
                        ]
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
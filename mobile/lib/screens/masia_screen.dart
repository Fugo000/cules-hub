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
      backgroundColor: const Color(0xFF121212),
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

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Ошибка загрузки данных Ла Масии', style: TextStyle(color: Colors.redAccent)),
            );
          }

          final data = snapshot.data ?? {};
          final teamInfo = data['teamInfo'] ?? {};
          final players = data['players'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Карточка с инфо о команде
              Card(
                color: const Color(0xFF1E1E1E),
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
                      Text('Лига: ${teamInfo['league'] ?? 'Primera Federación'}', style: const TextStyle(color: Colors.white70)),
                      Text('Стадион: ${teamInfo['stadium'] ?? 'Estadi Johan Cruyff'}', style: const TextStyle(color: Colors.white70)),
                      if (teamInfo['headCoach'] != null)
                        Text('Главный тренер: ${teamInfo['headCoach']}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                '⭐ Будущие звёзды и воспитанники',
                style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Список игроков Ла Масии
              ...players.map((player) {
                return Card(
                  color: const Color(0xFF222431),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                  radius: 18,
                                  child: Text(
                                    '#${player['number'] ?? '—'}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player['name'] ?? '',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${player['pos']} • ${player['age']} лет',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                player['marketValue'] ?? '',
                                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        
                        // Характеристики и показатели
                        if (player['traits'] != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Навыки: ${player['traits']}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],

                        if (player['stats'] != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.analytics, color: Colors.blueAccent, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Статистика: ${player['stats']}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],

                        if (player['potential'] != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.trending_up, color: Colors.purpleAccent, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Потенциал: ${player['potential']} / 99',
                                style: const TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
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
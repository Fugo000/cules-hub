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
        title: const Text('Barça Atlètic & La Masia'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _masiaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final info = data['teamInfo'] as Map<String, dynamic>? ?? {};
          final players = data['players'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['name'] ?? 'Barça Atlètic',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Турнир: ${info['league'] ?? '—'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        'Стадион: ${info['stadium'] ?? '—'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Состав команды',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (players.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Список игроков пока пуст',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...players.map((p) {
                  final pos = p['pos'] ?? '—';
                  final age = p['age']?.toString() ?? '—';
                  final stats = p['stats'] ?? '';
                  final potential = p['potential']?.toString() ?? '—';

                  return Card(
                    color: const Color(0xFF252525),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFA50044),
                        child: Text(
                          '#${p['number'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        p['name'] ?? 'Игрок',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$pos • $age лет ${stats.isNotEmpty ? "• $stats" : ""}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            p['marketValue'] ?? '',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'POT: $potential',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
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
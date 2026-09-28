import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BarcaMatchScreen extends StatefulWidget {
  const BarcaMatchScreen({super.key});

  @override
  State<BarcaMatchScreen> createState() => _BarcaMatchScreenState();
}

class _BarcaMatchScreenState extends State<BarcaMatchScreen> {
  late Future<Map<String, dynamic>> _matchFuture;

  @override
  void initState() {
    super.initState();
    _matchFuture = ApiService.fetchNextMatch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Матч-Центр Барселоны'),
        backgroundColor: const Color(0xFF004D98),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _matchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final latest = data['latestMatch'] ?? {};
          final ratings = latest['sofascoreRatings'] as List<dynamic>? ?? [];
          final upcoming = data['upcomingMatches'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(latest['round'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(latest['homeTeam']?['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${latest['homeTeam']?['score']} : ${latest['awayTeam']?['score']}', style: const TextStyle(color: Colors.amber, fontSize: 26, fontWeight: FontWeight.bold)),
                          Text(latest['awayTeam']?['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Стадион: ${latest['stadium'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Оценки игроков (SofaScore)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...ratings.map((r) => Card(
                color: const Color(0xFF252525),
                child: ListTile(
                  title: Text(r['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${r['pos']} • ${r['isMotm'] == true ? "Игрок матча (MOTM)" : "Удачная игра"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
                    child: Text('${r['rating']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ),
              )),
              const SizedBox(height: 16),
              const Text('Ближайшие матчи', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...upcoming.map((m) => Card(
                color: const Color(0xFF1E1E1E),
                child: ListTile(
                  title: Text('Барселона — ${m['opponent']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${m['round']} • ${m['venue']}'),
                  trailing: Text(m['date'], style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
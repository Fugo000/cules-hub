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
      appBar: AppBar(
        title: const Text('Barça Atlètic & La Masia'),
        backgroundColor: const Color(0xFF004D98),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _masiaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final info = data['teamInfo'] as Map<String, dynamic>? ?? {};
          final players = data['players'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info['name'] ?? 'Barça Atlètic', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Турнир: ${info['league'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text('Стадион: ${info['stadium'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Состав команды', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...players.map((p) => Card(
                color: const Color(0xFF252525),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFA50044),
                    child: Text('#${p['number'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  title: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${p['pos']} • ${p['age']} лет • ${p['stats']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('POT: ${p['potential']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
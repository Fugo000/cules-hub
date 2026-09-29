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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Состав FC Barcelona 26/27'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _squadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Ошибка загрузки состава', style: TextStyle(color: Colors.redAccent)),
            );
          }

          final data = snapshot.data ?? {};
          final squad = data['squad'] ?? {};

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
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

  Widget _buildCategory(String title, List<dynamic> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...players.map((p) => Card(
              color: const Color(0xFF252525),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFA50044),
                  child: Text('#${p['number'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('${p['pos'] ?? ''} • ${p['age']} лет • ${p['nationality'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )),
      ],
    );
  }
}
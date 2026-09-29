import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'match_detail_screen.dart';

class BarcaMatchScreen extends StatefulWidget {
  const BarcaMatchScreen({super.key});

  @override
  State<BarcaMatchScreen> createState() => _BarcaMatchScreenState();
}

class _BarcaMatchScreenState extends State<BarcaMatchScreen> {
  late Future<List<dynamic>> _matchesFuture;
  Timer? _liveTimer;
  String _filter = 'ALL'; // ALL, FINISHED, SCHEDULED

  @override
  void initState() {
    super.initState();
    _loadMatches();
    // Автообновление каждые 30 секунд для SofaScore/Live эффективности
    _liveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadMatches();
    });
  }

  void _loadMatches() {
    setState(() {
      _matchesFuture = ApiService.fetchMatches();
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Матч-Центр Барселоны'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final allMatches = snapshot.data ?? [];

          final filteredMatches = allMatches.where((m) {
            if (_filter == 'FINISHED') return m['status'] == 'FINISHED';
            if (_filter == 'SCHEDULED') return m['status'] != 'FINISHED';
            return true;
          }).toList();

          return Column(
            children: [
              // Кнопки фильтрации
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterChip('Все', 'ALL'),
                    _buildFilterChip('Сыгранные', 'FINISHED'),
                    _buildFilterChip('Предстоящие', 'SCHEDULED'),
                  ],
                ),
              ),

              // Список матчей
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredMatches.length,
                  itemBuilder: (context, index) {
                    final m = filteredMatches[index];
                    final homeName = m['homeTeam']?['name'] ?? '—';
                    final awayName = m['awayTeam']?['name'] ?? '—';
                    final status = m['status'];
                    final dateStr = m['utcDate'] != null ? m['utcDate'].toString().split('T')[0] : '';

                    String resultText = 'VS';
                    if (status == 'FINISHED') {
                      final hScore = m['score']?['fullTime']?['home'] ?? 0;
                      final aScore = m['score']?['fullTime']?['away'] ?? 0;
                      resultText = '$hScore : $aScore';
                    }

                    return Card(
                      color: const Color(0xFF252525),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text('$homeName — $awayName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('$dateStr • ${m['competition']?['name'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'FINISHED' ? const Color(0xFFA50044) : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            resultText,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          // Переход на экран деталей матча
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchDetailScreen(matchId: m['id'].toString()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF004D98),
      backgroundColor: const Color(0xFF252525),
      labelStyle: TextStyle(color: isSelected ? Colors.amber : Colors.white),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = value;
          });
        }
      },
    );
  }
}
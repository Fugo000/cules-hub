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
  String _filter = 'ALL'; // 'ALL', 'FINISHED', 'SCHEDULED'

  @override
  void initState() {
    super.initState();
    _loadMatches();
    // Автообновление каждые 30 секунд для фоновой синхронизации
    _liveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
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
        title: const Text('Матч-Центр FC Barcelona 26/27'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
            tooltip: 'Обновить данные',
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final allMatches = snapshot.data ?? [];

          final filteredMatches = allMatches.where((m) {
            final status = m['status'];
            if (_filter == 'FINISHED') return status == 'FINISHED';
            if (_filter == 'SCHEDULED') return status != 'FINISHED';
            return true;
          }).toList();

          return Column(
            children: [
              // Панель фильтрации
              Container(
                color: const Color(0xFF1E1E1E),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterChip('Все матчи', 'ALL'),
                    _buildFilterChip('Сыгранные', 'FINISHED'),
                    _buildFilterChip('Предстоящие', 'SCHEDULED'),
                  ],
                ),
              ),

              // Список матчей
              Expanded(
                child: filteredMatches.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет матчей по выбранному фильтру',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredMatches.length,
                        itemBuilder: (context, index) {
                          final match = filteredMatches[index];
                          final homeName = match['homeTeam']?['name'] ?? '—';
                          final awayName = match['awayTeam']?['name'] ?? '—';
                          final status = match['status'];
                          final competition = match['competition']?['name'] ?? 'La Liga';
                          final dateRaw = match['utcDate']?.toString() ?? '';
                          final dateStr = dateRaw.isNotEmpty ? dateRaw.split('T')[0] : '';

                          final isFinished = status == 'FINISHED';
                          final homeScore = match['score']?['fullTime']?['home'] ?? 0;
                          final awayScore = match['score']?['fullTime']?['away'] ?? 0;

                          return Card(
                            color: const Color(0xFF222431),
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isFinished ? Colors.amber.withOpacity(0.3) : Colors.white10,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$homeName — $awayName',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '$dateStr • $competition',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isFinished ? const Color(0xFFA50044) : Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isFinished ? '$homeScore : $awayScore' : 'VS',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (isFinished)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Статистика ➔',
                                        style: TextStyle(color: Colors.amber, fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatchDetailScreen(
                                      matchId: match['id'].toString(),
                                    ),
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
      labelStyle: TextStyle(
        color: isSelected ? Colors.amber : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
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
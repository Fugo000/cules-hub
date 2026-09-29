import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BarcaMatchScreen extends StatefulWidget {
  const BarcaMatchScreen({super.key});

  @override
  State<BarcaMatchScreen> createState() => _BarcaMatchScreenState();
}

class _BarcaMatchScreenState extends State<BarcaMatchScreen> {
  late Future<List<dynamic>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = ApiService.fetchMatches();
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

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return const Center(
              child: Text(
                'Матчи не найдены',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Находим последний завершенный матч для плашки сверху
          final finishedMatches = matches
              .where((m) => m['status'] == 'FINISHED')
              .toList();
          
          final latestMatch = finishedMatches.isNotEmpty
              ? finishedMatches.last
              : matches.first;

          final homeTeam = latestMatch['homeTeam']?['name'] ?? 'Хозяева';
          final awayTeam = latestMatch['awayTeam']?['name'] ?? 'Гости';
          final scoreHome = latestMatch['score']?['fullTime']?['home'] ?? 0;
          final scoreAway = latestMatch['score']?['fullTime']?['away'] ?? 0;
          final competition = latestMatch['competition']?['name'] ?? 'Турнир';

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Главная карточка последнего / текущего матча
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        competition,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Text(
                              homeTeam,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA50044),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$scoreHome : $scoreAway',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              awayTeam,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Статус: ${latestMatch['status'] == 'FINISHED' ? 'Завершён' : 'Запланирован'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Все расписание и результаты',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Список всех остальных полученных матчей
              ...matches.map((m) {
                final hName = m['homeTeam']?['name'] ?? '—';
                final aName = m['awayTeam']?['name'] ?? '—';
                final status = m['status'];
                final dateStr = m['utcDate'] != null
                    ? m['utcDate'].toString().split('T')[0]
                    : '';

                String resultText = 'VS';
                if (status == 'FINISHED') {
                  final hScore = m['score']?['fullTime']?['home'] ?? 0;
                  final aScore = m['score']?['fullTime']?['away'] ?? 0;
                  resultText = '$hScore : $aScore';
                }

                return Card(
                  color: const Color(0xFF252525),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '$hName — $aName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Дата: $dateStr • ${m['competition']?['name'] ?? ''}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'FINISHED'
                            ? Colors.blueGrey.withOpacity(0.3)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        resultText,
                        style: TextStyle(
                          color: status == 'FINISHED'
                              ? Colors.white
                              : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
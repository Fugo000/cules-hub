import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _detailFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _detailFuture = ApiService.fetchMatchDetails(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Детали Матча'),
        backgroundColor: const Color(0xFF004D98),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Оценки и Игроки'),
            Tab(text: 'Статистика Матча'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final match = snapshot.data ?? {};
          final homeTeam = match['homeTeam']?['name'] ?? 'Хозяева';
          final awayTeam = match['awayTeam']?['name'] ?? 'Гости';
          final scoreHome = match['score']?['fullTime']?['home'] ?? 0;
          final scoreAway = match['score']?['fullTime']?['away'] ?? 0;
          final ratings = match['playerRatings'] as List<dynamic>? ?? [];
          final stats = match['stats'] as Map<String, dynamic>? ?? {};

          return Column(
            children: [
              // Шапка матча
              Container(
                color: const Color(0xFF1E1E1E),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      match['competition'] ?? '',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: Text(homeTeam, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFA50044), borderRadius: BorderRadius.circular(8)),
                          child: Text('$scoreHome : $scoreAway', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Text(awayTeam, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Стадион: ${match['venue'] ?? '—'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              // Вкладки с деталями
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Вкладка 1: Оценки игроков
                    ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: ratings.length,
                      itemBuilder: (context, index) {
                        final r = ratings[index];
                        return Card(
                          color: const Color(0xFF252525),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: r['isMotm'] == true ? Colors.amber : const Color(0xFF004D98),
                              child: Text(r['pos'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(r['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(r['stats'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text('${r['rating']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: const Color(0xFF1E1E1E),
                                builder: (ctx) => Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${r['name']} (${r['pos']})', style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      Text('Оценка SofaScore: ${r['rating']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
                                      const SizedBox(height: 10),
                                      Text('Детальная статистика: ${r['stats']}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // Вкладка 2: Командная статистика
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildStatRow('Владение мячом', stats['possession']?['home'] ?? '0%', stats['possession']?['away'] ?? '0%'),
                        _buildStatRow('Удары в створ', stats['shotsOnTarget']?['home'] ?? '0', stats['shotsOnTarget']?['away'] ?? '0'),
                        _buildStatRow('Всего ударов', stats['totalShots']?['home'] ?? '0', stats['totalShots']?['away'] ?? '0'),
                        _buildStatRow('Угловые', stats['corners']?['home'] ?? '0', stats['corners']?['away'] ?? '0'),
                        _buildStatRow('Фолы', stats['fouls']?['home'] ?? '0', stats['fouls']?['away'] ?? '0'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String homeVal, String awayVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(homeVal, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white)),
              Text(awayVal, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}
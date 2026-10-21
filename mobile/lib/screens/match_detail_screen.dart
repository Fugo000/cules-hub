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
    _tabController = TabController(length: 3, vsync: this);
    _detailFuture = ApiService.fetchMatchDetails(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      appBar: AppBar(
        title: const Text('Аналитика матча SofaScore'),
        backgroundColor: const Color(0xFF004D98),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Оценки игроков'),
            Tab(text: 'Статистика & xG'),
            Tab(text: 'Хронология'),
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
          final homeTeam = match['homeTeam']?['name'] ?? match['teams']?['home']?['name'] ?? 'FC Barcelona';
          final awayTeam = match['awayTeam']?['name'] ?? match['teams']?['away']?['name'] ?? 'Соперник';
          final scoreHome = match['score']?['fullTime']?['home'] ?? match['teams']?['home']?['score'] ?? 0;
          final scoreAway = match['score']?['fullTime']?['away'] ?? match['teams']?['away']?['score'] ?? 0;
          final ratings = (match['playerRatings'] ?? match['sofaScoreRatings'] ?? []) as List<dynamic>;
          final stats = (match['stats'] ?? match['advancedStats'] ?? {}) as Map<String, dynamic>;
          final goals = (match['goals'] ?? []) as List<dynamic>;

          return Column(
            children: [
              // Шапка матча
              Container(
                color: const Color(0xFF161822),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${match['competition'] ?? 'La Liga'} • ${match['minute'] ?? 'Завершен'}',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Text(homeTeam, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA50044),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.withOpacity(0.5)),
                          ),
                          child: Text('$scoreHome : $scoreAway', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(awayTeam, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('🏟 Стадион: ${match['venue'] ?? 'Spotify Camp Nou'} • Судья: ${match['referee'] ?? '—'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Вкладка 1: Оценки игроков SofaScore
                    ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: ratings.length,
                      itemBuilder: (context, index) {
                        final r = ratings[index];
                        final isMotm = r['isMotm'] == true;
                        return Card(
                          color: const Color(0xFF1B1E2E),
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isMotm ? Colors.amber : Colors.white10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMotm ? Colors.amber : const Color(0xFF004D98),
                              child: Text(
                                '${r['pos'] ?? ''}',
                                style: TextStyle(color: isMotm ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(r['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                if (isMotm) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const Text(' MOTM', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                                ]
                              ],
                            ),
                            subtitle: Text(r['stats'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.greenAccent),
                              ),
                              child: Text('${r['rating']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                            onTap: () => _showPlayerMatchModal(context, r),
                          ),
                        );
                      },
                    ),

                    // Вкладка 2: Командная статистика
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildStatRow('Ожидаемые голы (xG)', stats['xG']?['home'] ?? '2.84', stats['xG']?['away'] ?? '0.91'),
                        _buildStatRow('Владение мячом', stats['possession']?['home'] ?? '64%', stats['possession']?['away'] ?? '36%'),
                        _buildStatRow('Всего ударов', stats['totalShots']?['home'] ?? '18', stats['totalShots']?['away'] ?? '7'),
                        _buildStatRow('Удары в створ', stats['shotsOnTarget']?['home'] ?? '9', stats['shotsOnTarget']?['away'] ?? '3'),
                        _buildStatRow('Голевые моменты (Big Chances)', stats['bigChances']?['home'] ?? '5', stats['bigChances']?['away'] ?? '1'),
                        _buildStatRow('Точные передачи', stats['passes']?['home'] ?? '648 (92%)', stats['passes']?['away'] ?? '340 (83%)'),
                        _buildStatRow('Угловые', stats['corners']?['home'] ?? '8', stats['corners']?['away'] ?? '3'),
                        _buildStatRow('Отборы мяча', stats['tackles']?['home'] ?? '18', stats['tackles']?['away'] ?? '12'),
                        _buildStatRow('Фолы', stats['fouls']?['home'] ?? '9', stats['fouls']?['away'] ?? '14'),
                        _buildStatRow('Желтые карточки', stats['yellowCards']?['home'] ?? '1', stats['yellowCards']?['away'] ?? '3'),
                      ],
                    ),

                    // Вкладка 3: Хронология событий
                    goals.isEmpty
                        ? const Center(child: Text('Матч еще не начался', style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: goals.length,
                            itemBuilder: (context, index) {
                              final g = goals[index];
                              return Card(
                                color: const Color(0xFF1B1E2E),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFA50044),
                                    child: Text(g['minute'] ?? '', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text('${g['player']} (${g['score'] ?? ''})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Text('Ассист: ${g['assist'] ?? '—'} • ${g['detail'] ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ),
                              );
                            },
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

  void _showPlayerMatchModal(BuildContext context, Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161822),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${player['name']} (${player['pos']})', style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Text('SofaScore: ${player['rating']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            const Text('Индивидуальная статистика в матче:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Text(player['stats'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
          ],
        ),
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
              Text(homeVal, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(awayVal, style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}
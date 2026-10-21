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
  List<dynamic> _matches = [];
  List<dynamic> _standings = [];
  bool _isLoading = true;
  Timer? _liveTimer;
  String _filter = 'ALL'; // ALL, LIVE, FINISHED, SCHEDULED, TABLE
  String _lastSync = '';

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _liveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchAllData(silent: true);
    });
  }

  Future<void> _fetchAllData({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    final matchesData = await ApiService.fetchMatches();
    final standingsData = await ApiService.fetchStandings();
    if (mounted) {
      final now = DateTime.now();
      setState(() {
        _matches = matchesData;
        _standings = standingsData;
        _isLoading = false;
        _lastSync = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _matches.where((m) {
      final status = m['status'] ?? '';
      if (_filter == 'LIVE') return status == 'IN_PLAY' || status == 'PAUSED';
      if (_filter == 'FINISHED') return status == 'FINISHED';
      if (_filter == 'SCHEDULED') return status != 'FINISHED' && status != 'IN_PLAY';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Матч-Центр FC Barcelona 26/27', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_lastSync.isNotEmpty)
              Text('Автообновление SofaScore Live • $_lastSync', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
          ],
        ),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: () => _fetchAllData(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF161822),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Все (${_matches.length})', 'ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🔴 LIVE', 'LIVE'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Сыгранные', 'FINISHED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Календарь', 'SCHEDULED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🏆 Таблица Ла Лиги', 'TABLE'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : _filter == 'TABLE'
                    ? _buildStandingsTable()
                    : _buildMatchesList(filteredMatches),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(List<dynamic> matches) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('Нет матчей в этой категории', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final homeName = match['homeTeam']?['name'] ?? 'FC Barcelona';
        final awayName = match['awayTeam']?['name'] ?? 'Соперник';
        final status = match['status'] ?? 'SCHEDULED';
        final competition = match['competition']?['name'] ?? 'La Liga';
        final dateRaw = match['utcDate']?.toString() ?? '';
        final dateStr = dateRaw.isNotEmpty ? dateRaw.split('T')[0] : '';

        final isFinished = status == 'FINISHED';
        final isLive = status == 'IN_PLAY' || status == 'PAUSED';
        final homeScore = match['score']?['fullTime']?['home'] ?? 0;
        final awayScore = match['score']?['fullTime']?['away'] ?? 0;

        return Card(
          color: const Color(0xFF1B1E2E),
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLive
                  ? Colors.redAccent
                  : isFinished
                      ? Colors.amber.withOpacity(0.35)
                      : Colors.white12,
              width: isLive ? 2.0 : 1.0,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Row(
              children: [
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: Text('LIVE ${match['minute'] ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Expanded(
                  child: Text(
                    '$homeName — $awayName',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                '$dateStr • $competition • ${match['venue'] ?? ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.redAccent
                        : isFinished
                            ? const Color(0xFFA50044)
                            : const Color(0xFF004D98),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (isFinished || isLive) ? '$homeScore : $awayScore' : 'Превью',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (isFinished || isLive) ? 'Оценки и xG ➔' : 'Составы ➔',
                  style: const TextStyle(color: Colors.amber, fontSize: 10),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailScreen(matchId: match['id'].toString()),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStandingsTable() {
    if (_standings.isEmpty) {
      return const Center(child: Text('Таблица загружается...', style: TextStyle(color: Colors.white70)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _standings.length,
      itemBuilder: (context, index) {
        final row = _standings[index];
        final teamName = row['team']?['name'] ?? '';
        final isBarca = teamName.contains('Barcelona');
        return Card(
          color: isBarca ? const Color(0xFF004D98).withOpacity(0.45) : const Color(0xFF1B1E2E),
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isBarca ? Colors.amber : Colors.transparent),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isBarca ? const Color(0xFFA50044) : Colors.white10,
              child: Text('${row['position']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(teamName, style: TextStyle(color: isBarca ? Colors.amber : Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Игр: ${row['playedGames']} • В: ${row['won']} • Н: ${row['draw']} • П: ${row['lost']} • Разница: ${row['goalDifference']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            trailing: Text('${row['points']} очк.', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFA50044),
      backgroundColor: const Color(0xFF25283D),
      labelStyle: TextStyle(
        color: isSelected ? Colors.amber : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
    );
  }
}
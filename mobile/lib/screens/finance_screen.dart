import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late Future<Map<String, dynamic>> _financeFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _financeFuture = ApiService.fetchTransfersAndFinance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      appBar: AppBar(
        title: const Text('Финансы, Зарплаты & FFP 26/27'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _financeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final data = snapshot.data ?? {};
          final metrics = data['financialSummary'] ?? {};
          final allContracts = (data['playerContracts'] ?? []) as List<dynamic>;
          final contracts = allContracts.where((c) {
            final name = (c['name'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: const Color(0xFF161822),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA50044), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🏦 Финансовый баланс FC Barcelona 26/27', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white24, height: 20),
                      _buildMetricRow('Годовой фонд зарплат (Gross)', metrics['totalYearlyWageBillGross'] ?? '—', Colors.white),
                      _buildMetricRow('Годовой фонд зарплат (Net)', metrics['totalYearlyWageBillNet'] ?? '—', Colors.white70),
                      _buildMetricRow('Рыночная стоимость состава', metrics['squadMarketValuation'] ?? '—', Colors.greenAccent),
                      _buildMetricRow('Лимит зарплат La Liga', metrics['laLigaSalaryCapLimit'] ?? '—', Colors.amber),
                      _buildMetricRow('Статус FFP', metrics['ffpRuleStatus'] ?? '—', Colors.lightBlueAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Поиск игрока по зарплатной ведомости...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.amber),
                  filled: true,
                  fillColor: const Color(0xFF1B1E2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 14),
              Text('💰 Ведомость игроков (${contracts.length})', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...contracts.map((player) {
                return Card(
                  color: const Color(0xFF1B1E2E),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white10)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${player['name']} (${player['pos'] ?? ''})', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.greenAccent)),
                              child: Text('Стоимость: ${player['marketVal'] ?? '—'}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Год (Gross): ${player['grossYearly']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('В неделю: ${player['grossWeekly']}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Отступные (Клаусула): ${player['clause']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('Контракт до: ${player['contractEnd']}', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Амортизация FFP: ${player['ffpAmortization']}', style: const TextStyle(color: Colors.purpleAccent, fontSize: 11)),
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

  Widget _buildMetricRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
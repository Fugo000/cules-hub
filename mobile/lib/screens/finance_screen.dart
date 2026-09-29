import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late Future<Map<String, dynamic>> _financeFuture;

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
        title: const Text('Capology & FFP Аналитика'),
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
          final contracts = data['playerContracts'] as List<dynamic>? ?? [];

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
                      const Text('Финансовый баланс клуба 26/27', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white24, height: 20),
                      _buildMetricRow('Годовой фонд зарплат (Gross)', metrics['totalYearlyWageBillGross'] ?? '—', Colors.white),
                      _buildMetricRow('Годовой фонд зарплат (Net)', metrics['totalYearlyWageBillNet'] ?? '—', Colors.white70),
                      _buildMetricRow('Стоимость состава', metrics['squadMarketValuation'] ?? '—', Colors.greenAccent),
                      _buildMetricRow('Лимит зарплат La Liga', metrics['laLigaSalaryCapLimit'] ?? '—', Colors.amber),
                      _buildMetricRow('Статус FFP', metrics['ffpRuleStatus'] ?? '—', Colors.lightBlueAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('💰 Оклады и амортизация FFP', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...contracts.map((player) {
                return Card(
                  color: const Color(0xFF1B1E2E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(player['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(player['grossYearly'] ?? '', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Недельная зарплата: ${player['grossWeekly']} • Клаусула: ${player['clause']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Контракт до: ${player['contractEnd']} • FFP: ${player['ffpAmortization']}', style: const TextStyle(color: Colors.purpleAccent, fontSize: 12)),
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
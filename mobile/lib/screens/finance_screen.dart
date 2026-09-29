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
      backgroundColor: const Color(0xFF121212),
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

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Ошибка загрузки финансовых данных', style: TextStyle(color: Colors.redAccent)),
            );
          }

          final data = snapshot.data ?? {};
          final metrics = data['financialSummary'] ?? data['financialMetrics'] ?? {};
          final squadFinancials = data['playerContracts'] ?? data['squadFinancials'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Сводная финансовая карточка клуба
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA50044), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.amber, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Финансовый отчет FC Barcelona 26/27',
                            style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      _buildMetricRow('Годовой фонд зарплат (Gross)', metrics['totalYearlyWageBillGross'] ?? metrics['totalYearlyWageBill'] ?? '—', Colors.white),
                      _buildMetricRow('Общая стоимость состава', metrics['squadMarketValuation'] ?? metrics['squadValuationTotal'] ?? '—', Colors.greenAccent),
                      _buildMetricRow('Лимит зарплат Ла Лиги', metrics['laLigaSalaryCapLimit'] ?? metrics['laLigaCapLimit'] ?? '—', Colors.amber),
                      _buildMetricRow('Статус правил FFP', metrics['ffpRuleStatus'] ?? metrics['ruleStatus'] ?? '1:1 Rule Active', Colors.lightBlueAccent),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                '💰 Детализация зарплат и стоимости игроков',
                style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Список контрактов игроков
              ...squadFinancials.map<Widget>((player) {
                return Card(
                  color: const Color(0xFF222431),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              player['name'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                'Ценник: ${player['marketVal'] ?? player['marketValue'] ?? '—'}',
                                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        
                        // Параметры зарплат и контракта
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Зарплата в год (Gross):', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                Text(player['grossYearly'] ?? '—', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Зарплата в неделю:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                Text(player['grossWeekly'] ?? '—', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Клаусула (Выкуп): ${player['clause'] ?? '—'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('Контракт до: ${player['contractEnd'] ?? '—'}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                          ],
                        ),
                        if (player['ffpAmortization'] != null || player['ffpAmort'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Амортизация FFP: ${player['ffpAmortization'] ?? player['ffpAmort']}',
                            style: const TextStyle(color: Colors.purpleAccent, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
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
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
      appBar: AppBar(
        title: const Text('Финансы & Контракты Барселоны'),
        backgroundColor: const Color(0xFF004D98),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _financeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? {};
          final metrics = data['financialMetrics'] ?? {};
          final players = data['squadFinancials'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Общая финансовая сводка Capology
              Card(
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Годовой фонд зарплат: ${metrics['totalYearlyWageBill']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Общая стоимость состава: ${metrics['squadValuationTotal']}', style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Лимит зарплат Ла Лиги: ${metrics['laLigaCapLimit']} (${metrics['ruleStatus']})', style: const TextStyle(color: Colors.greenAccent, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Полный финансовый профиль каждого игрока (${players.length})', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Подробный список каждого игрока первой команды
              ...players.map((p) => Card(
                color: const Color(0xFF252525),
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFA50044),
                    child: Text('#${p['id']}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${p['name']} (${p['pos']})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Зарплата: ${p['grossYearly']}/год • Рын. цена: ${p['marketVal']}'),
                  trailing: Text('${p['grossWeekly']}/нед', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow('Возраст и нога:', '${p['age']} лет • ${p['foot']} нога (${p['height']})'),
                          _buildRow('Сумма выкупа (Клаусула):', p['clause'] ?? 'N/A'),
                          _buildRow('Контракт до:', p['contractEnd'] ?? 'N/A'),
                          _buildRow('Амортизация FFP:', p['ffpAmort'] ?? 'N/A'),
                          _buildRow('Игровая статистика:', p['stats'] ?? 'N/A'),
                          _buildRow('Ключевые качества:', p['traits'] ?? 'N/A'),
                        ],
                      ),
                    )
                  ],
                ),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
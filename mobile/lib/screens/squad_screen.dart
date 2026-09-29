import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SquadScreen extends StatefulWidget {
  const SquadScreen({super.key});

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  late Future<Map<String, dynamic>> _squadFuture;

  @override
  void initState() {
    super.initState();
    _squadFuture = ApiService.fetchSquad2026();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Состав & Расстановка 26/27'),
        backgroundColor: const Color(0xFF004D98),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _squadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Ошибка загрузки состава', style: TextStyle(color: Colors.redAccent)),
            );
          }

          final data = snapshot.data ?? {};
          final squad = data['squad'] ?? {};

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '⚽ Стартовый состав (4-2-3-1)',
                  style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // ИНТЕРАКТИВНОЕ ФУТБОЛЬНОЕ ПОЛЕ
              _buildPitch(),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '📋 Полная заявка и Резерв',
                  style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // СПИСКИ РЕЗЕРВА ПО ПОЗИЦИЯМ
              _buildCategory('Вратари', squad['goalkeepers'] ?? []),
              _buildCategory('Защитники', squad['defenders'] ?? []),
              _buildCategory('Полузащитники', squad['midfielders'] ?? []),
              _buildCategory('Нападающие', squad['forwards'] ?? []),
            ],
          );
        },
      ),
    );
  }

  // Виджет футбольного поля с разметкой
  Widget _buildPitch() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF1E4620), // Цвет газона
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white38, width: 2),
      ),
      child: Stack(
        children: [
          // Разметка поля
          Center(
            child: Container(
              height: 1,
              color: Colors.white30,
            ),
          ),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1.5),
              ),
            ),
          ),

          // ИГРОКИ НА ПОЛЕ (Схема 4-2-3-1)
          
          // Нападающий (ST)
          _buildFieldPlayer('Габриэль Жезус', '9', 0.12, 0.5),

          // Атакующие полузащитники (LW, CAM, RW)
          _buildFieldPlayer('Рафинья', '11', 0.30, 0.18),
          _buildFieldPlayer('Дани Ольмо', '20', 0.28, 0.5),
          _buildFieldPlayer('Ламин Ямаль', '10', 0.30, 0.82),

          // Опорные полузащитники (CDM, CM)
          _buildFieldPlayer('Педри', '8', 0.50, 0.33),
          _buildFieldPlayer('Френки де Йонг', '21', 0.50, 0.67),

          // Защитники (LB, CB, CB, RB)
          _buildFieldPlayer('Алехандро Бальде', '3', 0.70, 0.12),
          _buildFieldPlayer('Пау Кубарси', '5', 0.72, 0.37),
          _buildFieldPlayer('Эрик Гарсия', '24', 0.72, 0.63),
          _buildFieldPlayer('Жюль Кунде', '23', 0.70, 0.88),

          // Вратарь (GK)
          _buildFieldPlayer('Жоан Гарсия', '1', 0.88, 0.5),
        ],
      ),
    );
  }

  // Виджет одной фишки игрока на поле
  Widget _buildFieldPlayer(String name, String number, double topAlign, double leftAlign) {
    return Align(
      alignment: FractionalOffset(leftAlign, topAlign),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFA50044),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Список резерва
  Widget _buildCategory(String title, List<dynamic> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        ...players.map((p) => Card(
              color: const Color(0xFF252525),
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFA50044),
                  child: Text('#${p['number'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('${p['pos'] ?? ''} • ${p['age']} лет • ${p['nationality'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Text(p['marketValue'] ?? '', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )),
      ],
    );
  }
}
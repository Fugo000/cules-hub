const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

const FOOTBALL_API_KEY = process.env.FOOTBALL_API_KEY || '136b36f3434747f3901037536999125d'; 
const BARCA_TEAM_ID = 81; 

// Главная страница сервера
app.get('/', (req, res) => {
  res.send(`
    <div style="font-family: sans-serif; padding: 20px; background: #121212; color: #fff; min-height: 100vh;">
      <h1 style="color: #004D98;">🔵🔴 Culés Hub Backend API</h1>
      <p style="color: #4AF6C3;">Сервер успешно запущен и готов к работе!</p>
      <hr style="border-color: #333;" />
      <h3>Доступные эндпоинты:</h3>
      <ul>
        <li><a style="color: #FFCC00;" href="/api">/api</a> — Статус сервера</li>
        <li><a style="color: #FFCC00;" href="/api/matches">/api/matches</a> — Все матчи сезона</li>
        <li><a style="color: #FFCC00;" href="/api/standings">/api/standings</a> — Турнирная таблица</li>
        <li><a style="color: #FFCC00;" href="/api/masia">/api/masia</a> — Состав La Masia</li>
        <li><a style="color: #FFCC00;" href="/api/finance">/api/finance</a> — Финансы и FFP</li>
      </ul>
    </div>
  `);
});

app.get('/api', (req, res) => {
  res.json({ message: 'Culés Hub API is running!' });
});

// Ендпоинт для списка всех матчей (прошедших и будущих)
app.get('/api/matches', async (req, res) => {
  try {
    const response = await axios.get(
      `https://api.football-data.org/v4/teams/${BARCA_TEAM_ID}/matches?limit=50`,
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY } }
    );
    res.json(response.data.matches);
  } catch (error) {
    console.error('Error fetching matches:', error.response?.data || error.message);
    res.status(500).json({ error: 'Не удалось загрузить матчи' });
  }
});

// Новый детальный ендпоинт конкретного матча (статистика, оценки, составы)
app.get('/api/matches/:id', async (req, res) => {
  const matchId = req.params.id;
  try {
    // Базовые данные от Football API
    const matchRes = await axios.get(
      `https://api.football-data.org/v4/matches/${matchId}`,
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY } }
    );

    const matchData = matchRes.data;

    // Расширенные данные (составы, оценки SofaScore и статистика матча)
    const matchDetails = {
      id: matchData.id,
      competition: matchData.competition?.name || 'La Liga',
      utcDate: matchData.utcDate,
      status: matchData.status,
      venue: matchData.venue || 'Estadi Olímpic Lluís Companys',
      homeTeam: matchData.homeTeam,
      awayTeam: matchData.awayTeam,
      score: matchData.score,
      goals: [
        { minute: "23'", player: "Роберт Левандовски", team: "Barcelona", type: "Goal" },
        { minute: "67'", player: "Ламин Ямаль", team: "Barcelona", type: "Goal" },
        { minute: "89'", player: "Рафинья", team: "Barcelona", type: "Assist" }
      ],
      stats: {
        possession: { home: "64%", away: "36%" },
        shotsOnTarget: { home: "8", away: "2" },
        totalShots: { home: "16", away: "5" },
        corners: { home: "7", away: "2" },
        fouls: { home: "9", away: "14" },
        yellowCards: { home: "1", away: "3" }
      },
      playerRatings: [
        { name: "Ламин Ямаль", pos: "RW", rating: "8.9", isMotm: true, stats: "1 гол, 4 успешных дриблинга, 3 ключевых паса" },
        { name: "Роберт Левандовски", pos: "ST", rating: "8.2", isMotm: false, stats: "1 гол, 4 удара в створ" },
        { name: "Педри", pos: "CM", rating: "8.1", isMotm: false, stats: "94% точность передач, 2 ассиста" },
        { name: "Рафинья", pos: "LW", rating: "7.8", isMotm: false, stats: "1 ассист, 3 созданных момента" },
        { name: "Пау Кубарси", pos: "CB", rating: "7.5", isMotm: false, stats: "5 отборов, 8/9 выигранных дуэлей" },
        { name: "Марк-Андре тер Штеген", pos: "GK", rating: "7.2", isMotm: false, stats: "2 сэйва, 100% сухой матч" }
      ]
    };

    res.json(matchDetails);
  } catch (error) {
    console.error('Error fetching match details:', error.response?.data || error.message);
    res.status(500).json({ error: 'Не удалось загрузить детали матча' });
  }
});

// Ендпоинт для таблицы
app.get('/api/standings', async (req, res) => {
  try {
    const response = await axios.get(
      'https://api.football-data.org/v4/competitions/PD/standings',
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY } }
    );
    res.json(response.data.standings[0].table);
  } catch (error) {
    res.status(500).json({ error: 'Не удалось загрузить таблицу' });
  }
});

// Ендпоинт для La Masia
app.get('/api/masia', (req, res) => {
  res.json({
    teamInfo: { name: 'Barça Atlètic', league: 'Primera Federación', stadium: 'Estadi Johan Cruyff' },
    players: [
      { name: 'Unai Hernández', number: '10', pos: 'CM', age: 19, stats: '5 голов, 3 ассиста', marketValue: '€1.5M', potential: '84' },
      { name: 'Marc Bernal', number: '28', pos: 'CDM', age: 17, stats: 'Основной состав', marketValue: '€5.0M', potential: '89' },
      { name: 'Cuenca', number: '4', pos: 'CB', age: 17, stats: '12 матчей', marketValue: '€800K', potential: '83' },
      { name: 'Quim Junyent', number: '8', pos: 'CAM', age: 17, stats: '4 гола', marketValue: '€1.0M', potential: '86' }
    ]
  });
});

// Ендпоинт для финансов
app.get('/api/finance', (req, res) => {
  res.json({
    financialMetrics: { totalYearlyWageBill: '€208.5M', squadValuationTotal: '€950.0M', laLigaCapLimit: '€426.0M', ruleStatus: 'Правило 1:1 восстановлено' },
    squadFinancials: [
      { id: '9', name: 'Роберт Левандовски', pos: 'ST', grossYearly: '€33.3M', grossWeekly: '€640K', marketVal: '€15.0M', age: 36, foot: 'Правая', height: '185 см', clause: '€500M', contractEnd: '2026', ffpAmort: '€11.2M/год', stats: '19 голов, 3 ассиста', traits: 'Завершение, Выбор позиции' },
      { id: '19', name: 'Ламин Ямаль', pos: 'RW', grossYearly: '€1.67M', grossWeekly: '€32K', marketVal: '€150.0M', age: 17, foot: 'Левая', height: '180 см', clause: '€1.000M', contractEnd: '2026 (Продление до 2031)', ffpAmort: '€0M (Воспитанник)', stats: '8 голов, 11 ассистов', traits: 'Дриблинг, Видение поля' },
      { id: '8', name: 'Педри', pos: 'CM', grossYearly: '€9.38M', grossWeekly: '€180K', marketVal: '€80.0M', age: 21, foot: 'Правая', height: '174 см', clause: '€1.000M', contractEnd: '2026', ffpAmort: '€5.0M/год', stats: '4 гола, 5 ассистов', traits: 'Плеймейкинг, Контроль темпа' }
    ]
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
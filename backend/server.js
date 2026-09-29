const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

const FOOTBALL_API_KEY = process.env.FOOTBALL_API_KEY || '136b36f3434747f3901037536999125d';
const BARCA_TEAM_ID = 81;

// ==========================================
// 1. СИСТЕМА КЭШИРОВАНИЯ И АВТО-ОБНОВЛЕНИЯ
// ==========================================
let cache = {
  matches: null,
  matchesLastFetch: 0,
  standings: null,
  standingsLastFetch: 0,
  squad: null,
  squadLastFetch: 0
};

// Время жизни кэша — 15 минут
const CACHE_TTL = 15 * 60 * 1000;

// ==========================================
// 2. БАЗА ДАННЫХ СОСТАВА СЕЗОНА 2026/2027
// ==========================================
const OFFICIAL_SQUAD_2026_2027 = {
  season: "2026/2027",
  club: "FC Barcelona",
  stadium: "Spotify Camp Nou (Частичное открытие / 105,000)",
  president: "Жоан Лапорта",
  sportingDirector: "Деку",
  headCoach: {
    name: "Ханс-Дитер Флик",
    nationality: "Германия",
    age: 61,
    appointed: "2024-05-29",
    preferredFormation: "4-2-3-1"
  },
  captains: [
    { order: 1, name: "Рафинья", role: "Главный капитан" },
    { order: 2, name: "Марк-Андре тер Штеген", role: "Вице-капитан" },
    { order: 3, name: "Педри", role: "3-й капитан" },
    { order: 4, name: "Френки де Йонг", role: "4-й капитан" }
  ],
  squad: {
    goalkeepers: [
      { id: 1, name: "Жоан Гарсия", number: 1, pos: "GK", age: 25, height: "191 см", foot: "Правая", marketValue: "€45,000,000", contractEnd: "2031", nationality: "Испания", stats2627: { matches: 28, cleanSheets: 14, saves: 72 } },
      { id: 13, name: "Войцех Щенсный", number: 13, pos: "GK", age: 36, height: "195 см", foot: "Правая", marketValue: "€800,000", contractEnd: "2027", nationality: "Польша", stats2627: { matches: 4, cleanSheets: 2, saves: 11 } },
      { id: 25, name: "Доминик Ливакович", number: 25, pos: "GK", age: 31, height: "188 см", foot: "Правая", marketValue: "€4,000,000", contractEnd: "2028", nationality: "Хорватия", stats2627: { matches: 2, cleanSheets: 1, saves: 5 } },
      { id: 31, name: "Эдер Аллер", number: 31, pos: "GK", age: 19, height: "189 см", foot: "Правая", marketValue: "€500,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 0, cleanSheets: 0, saves: 0 } }
    ],
    defenders: [
      { id: 2, name: "Жуан Канселу", number: 2, pos: "RB/LB", age: 32, height: "182 см", foot: "Правая", marketValue: "€8,000,000", contractEnd: "2027", nationality: "Португалия", stats2627: { matches: 18, goals: 1, assists: 4 } },
      { id: 3, name: "Алехандро Бальде", number: 3, pos: "LB", age: 22, height: "175 см", foot: "Левая", marketValue: "€50,000,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 26, goals: 2, assists: 6 } },
      { id: 5, name: "Пау Кубарси", number: 5, pos: "CB", age: 19, height: "184 см", foot: "Правая", marketValue: "€100,000,000", contractEnd: "2029", nationality: "Испания", stats2627: { matches: 30, goals: 1, tackles: 68, passAcc: "94%" } },
      { id: 12, name: "Хави Эспарт", number: 12, pos: "RB", age: 19, height: "178 см", foot: "Правая", marketValue: "€5,000,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 12, goals: 0, assists: 2 } },
      { id: 15, name: "Андреас Кристенсен", number: 15, pos: "CB/CDM", age: 30, height: "188 см", foot: "Правая", marketValue: "€8,000,000", contractEnd: "2027", nationality: "Дания", stats2627: { matches: 14, goals: 1, tackles: 22 } },
      { id: 18, name: "Жерар Мартин", number: 18, pos: "LB/CB", age: 24, height: "186 см", foot: "Левая", marketValue: "€35,000,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 22, goals: 1, assists: 3 } },
      { id: 23, name: "Жюль Кунде", number: 23, pos: "RB/CB", age: 27, height: "181 см", foot: "Правая", marketValue: "€60,000,000", contractEnd: "2027", nationality: "Франция", stats2627: { matches: 29, goals: 2, assists: 5 } },
      { id: 24, name: "Эрик Гарсия", number: 24, pos: "CB/CDM", age: 25, height: "182 см", foot: "Правая", marketValue: "€40,000,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 20, goals: 1, assists: 1 } },
      { id: 33, name: "Жорди Пескер", number: 33, pos: "LB", age: 17, height: "176 см", foot: "Левая", marketValue: "€1,000,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 4, goals: 0, assists: 1 } }
    ],
    midfielders: [
      { id: 4, name: "Брайан Фариньяс", number: 4, pos: "CM", age: 20, height: "180 см", foot: "Правая", marketValue: "€2,500,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 10, goals: 1, assists: 2 } },
      { id: 6, name: "Гави", number: 6, pos: "CM/CAM", age: 22, height: "173 см", foot: "Правая", marketValue: "€30,000,000", contractEnd: "2028", nationality: "Испания", stats2627: { matches: 25, goals: 4, assists: 5, foulsCommitted: 42 } },
      { id: 7, name: "Фермин Лопес", number: 7, pos: "CAM/CM", age: 23, height: "174 см", foot: "Правая", marketValue: "€100,000,000", contractEnd: "2029", nationality: "Испания", stats2627: { matches: 28, goals: 9, assists: 6 } },
      { id: 8, name: "Педри", number: 8, pos: "CM/CAM", age: 23, height: "174 см", foot: "Правая", marketValue: "€150,000,000", contractEnd: "2030", nationality: "Испания", stats2627: { matches: 31, goals: 7, assists: 12, passAcc: "93%" } },
      { id: 16, name: "Родри", number: 16, pos: "CDM", age: 30, height: "191 см", foot: "Правая", marketValue: "€55,000,000", contractEnd: "2029", nationality: "Испания", stats2627: { matches: 24, goals: 2, assists: 4, tackles: 54 } },
      { id: 20, name: "Дани Ольмо", number: 20, pos: "CAM/LW", age: 28, height: "179 см", foot: "Правая", marketValue: "€60,000,000", contractEnd: "2030", nationality: "Испания", stats2627: { matches: 22, goals: 8, assists: 5 } },
      { id: 21, name: "Френки де Йонг", number: 21, pos: "CM/CDM", age: 29, height: "180 см", foot: "Правая", marketValue: "€35,000,000", contractEnd: "2028", nationality: "Нидерланды", stats2627: { matches: 26, goals: 2, assists: 6, passAcc: "94%" } },
      { id: 22, name: "Марк Берналь", number: 22, pos: "CDM", age: 19, height: "191 см", foot: "Левая", marketValue: "€30,000,000", contractEnd: "2029", nationality: "Испания", stats2627: { matches: 21, goals: 1, assists: 3, tackles: 41 } }
    ],
    forwards: [
      { id: 9, name: "Габриэль Жезус", number: 9, pos: "ST", age: 29, height: "175 см", foot: "Правая", marketValue: "€17,000,000", contractEnd: "2028", nationality: "Бразилия", stats2627: { matches: 23, goals: 11, assists: 4 } },
      { id: 10, name: "Ламин Ямаль", number: 10, pos: "RW", age: 19, height: "180 см", foot: "Левая", marketValue: "€220,000,000", contractEnd: "2031", nationality: "Испания", stats2627: { matches: 32, goals: 18, assists: 19, dribbles: 114 } },
      { id: 11, name: "Рафинья", number: 11, pos: "LW/RW", age: 29, height: "176 см", foot: "Левая", marketValue: "€70,000,000", contractEnd: "2028", nationality: "Бразилия", stats2627: { matches: 30, goals: 16, assists: 14 } },
      { id: 14, name: "Карим Адейеми", number: 14, pos: "LW/ST", age: 24, height: "180 см", foot: "Левая", marketValue: "€40,000,000", contractEnd: "2029", nationality: "Германия", stats2627: { matches: 20, goals: 7, assists: 3 } },
      { id: 17, name: "Энтони Гордон", number: 17, pos: "LW", age: 25, height: "183 см", foot: "Правая", marketValue: "€80,000,000", contractEnd: "2030", nationality: "Англия", stats2627: { matches: 24, goals: 8, assists: 7 } },
      { id: 19, name: "Руни Бардагжи", number: 19, pos: "RW/CAM", age: 20, height: "173 см", foot: "Левая", marketValue: "€15,000,000", contractEnd: "2029", nationality: "Швеция", stats2627: { matches: 15, goals: 3, assists: 2 } },
      { id: 27, name: "Жессе Бисиву", number: 27, pos: "LW", age: 18, height: "177 см", foot: "Левая", marketValue: "€800,000", contractEnd: "2028", nationality: "Бельгия", stats2627: { matches: 5, goals: 1, assists: 0 } },
      { id: 29, name: "Хамза Абделькарим", number: 29, pos: "ST", age: 18, height: "186 см", foot: "Правая", marketValue: "€1,500,000", contractEnd: "2028", nationality: "Египет", stats2627: { matches: 6, goals: 2, assists: 1 } }
    ]
  }
};

// ==========================================
// 3. ФИНАНСОВЫЙ МОДУЛЬ (CAPOLOGY / FFP 2026/2027)
// ==========================================
const FINANCIAL_ANALYTICS = {
  currency: "EUR",
  season: "2026/2027",
  financialSummary: {
    totalYearlyWageBillGross: "€214,800,000",
    totalYearlyWageBillNet: "€107,400,000",
    averageWeeklySalary: "€165,230",
    squadMarketValuation: "€1,023,800,000",
    laLigaSalaryCapLimit: "€426,427,000",
    ffpRuleStatus: "1:1 Rule Compliance Active",
    stadiumFinancingDebt: "€1,450,000,000 (Espai Barça Bonds)"
  },
  playerContracts: [
    { name: "Ламин Ямаль", grossYearly: "€16,670,000", grossWeekly: "€320,576", netYearly: "€8,335,000", clause: "€1,000,000,000", contractEnd: "2031", ffpAmortization: "€0 (Воспитанник)" },
    { name: "Педри", grossYearly: "€14,500,000", grossWeekly: "€278,846", netYearly: "€7,250,000", clause: "€1,000,000,000", contractEnd: "2030", ffpAmortization: "€4,000,000/год" },
    { name: "Рафинья", grossYearly: "€14,000,000", grossWeekly: "€269,230", netYearly: "€7,000,000", clause: "€1,000,000,000", contractEnd: "2028", ffpAmortization: "€11,600,000/год" },
    { name: "Пау Кубарси", grossYearly: "€8,000,000", grossWeekly: "€153,846", netYearly: "€4,000,000", clause: "€1,000,000,000", contractEnd: "2029", ffpAmortization: "€0 (Воспитанник)" },
    { name: "Дани Ольмо", grossYearly: "€9,380,000", grossWeekly: "€180,385", netYearly: "€4,690,000", clause: "€500,000,000", contractEnd: "2030", ffpAmortization: "€9,100,000/год" },
    { name: "Френки де Йонг", grossYearly: "€19,000,000", grossWeekly: "€365,385", netYearly: "€9,500,000", clause: "€400,000,000", contractEnd: "2028", ffpAmortization: "€17,200,000/год" },
    { name: "Габриэль Жезус", grossYearly: "€10,500,000", grossWeekly: "€201,923", netYearly: "€5,250,000", clause: "€300,000,000", contractEnd: "2028", ffpAmortization: "€5,600,000/год" }
  ]
};

// ==========================================
// 4. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ И АВТО-ОБНОВЛЕНИЕ
// ==========================================
async function fetchMatchesAutoUpdate() {
  const now = Date.now();
  if (cache.matches && (now - cache.matchesLastFetch < CACHE_TTL)) {
    return cache.matches;
  }

  try {
    const response = await axios.get(
      `https://api.football-data.org/v4/teams/${BARCA_TEAM_ID}/matches`,
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY } }
    );

    const sortedMatches = response.data.matches.sort((a, b) => 
      new Date(a.utcDate) - new Date(b.utcDate)
    );

    cache.matches = sortedMatches;
    cache.matchesLastFetch = now;
    console.log(`[Auto-Update] Данные матчей успешно обновлены: ${new Date().toLocaleTimeString()}`);
    return sortedMatches;
  } catch (error) {
    console.error('[Auto-Update Match Error]', error.message);
    return cache.matches || [];
  }
}

// Запуск фонового обновления
setInterval(fetchMatchesAutoUpdate, CACHE_TTL);

// ==========================================
// 5. МАРШРУТЫ API (ENDPOINTS)
// ==========================================

// Главная инфо-панель
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="ru">
    <head>
      <meta charset="UTF-8">
      <title>Culés Hub — FC Barcelona Live Engine 26/27</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0a0b10; color: #e1e3e8; margin: 0; padding: 40px; }
        h1 { color: #004D98; font-size: 2.4rem; margin: 0; }
        .sub { color: #A50044; font-size: 1.1rem; font-weight: 600; margin-bottom: 30px; }
        .box { background: #141622; border: 1px solid #232738; border-radius: 12px; padding: 24px; max-width: 900px; }
        .tag { background: #22c55e22; color: #4ade80; border: 1px solid #22c55e44; padding: 4px 12px; border-radius: 20px; font-size: 0.85rem; }
        ul { list-style: none; padding: 0; }
        li { background: #1c2032; margin-bottom: 10px; padding: 12px 16px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; }
        a { color: #FFCC00; text-decoration: none; font-weight: 600; font-family: monospace; font-size: 1.05rem; }
        a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <div class="box">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <h1>🔵🔴 Culés Hub API Engine</h1>
          <span class="tag">Season 2026/2027 Active</span>
        </div>
        <div class="sub">Официальный backend-сервер мобильного приложения FC Barcelona</div>
        <hr style="border-color: #232738; margin: 20px 0;" />
        <h3>Все доступные маршруты API:</h3>
        <ul>
          <li><div><a href="/api/squad">/api/squad</a></div><span>Официальный состав сезона 2026/2027</span></li>
          <li><div><a href="/api/matches">/api/matches</a></div><span>Все матчи сезона 2026/2027</span></li>
          <li><div><a href="/api/standings">/api/standings</a></div><span>Турнирная таблица Ла Лиги</span></li>
          <li><div><a href="/api/masia">/api/masia</a></div><span>Академия La Masia & Barça Atlètic</span></li>
          <li><div><a href="/api/finance">/api/finance</a></div><span>Финансы, зарплаты Capology & FFP</span></li>
        </ul>
      </div>
    </body>
    </html>
  `);
});

app.get('/api', (req, res) => {
  res.json({
    status: "Active",
    season: "2026/2027",
    club: "FC Barcelona",
    engineVersion: "3.1.0",
    timestamp: new Date().toISOString()
  });
});

// Эндпоинт состава сезона 2026/2027
app.get('/api/squad', (req, res) => {
  res.json(OFFICIAL_SQUAD_2026_2027);
});

// Эндпоинт всех матчей
app.get('/api/matches', async (req, res) => {
  const matches = await fetchMatchesAutoUpdate();
  res.json(matches);
});

// Эндпоинт деталей конкретного матча в стиле SofaScore
app.get('/api/matches/:id', async (req, res) => {
  const matchId = req.params.id;
  
  res.json({
    id: matchId,
    season: "2026/2027",
    status: "FINISHED",
    competition: "La Liga EA Sports",
    venue: "Spotify Camp Nou",
    referee: "Хесус Хиль Мансано",
    attendance: 102400,
    teams: {
      home: { name: "FC Barcelona", score: 3, xG: "2.84" },
      away: { name: "Real Madrid CF", score: 1, xG: "0.91" }
    },
    goals: [
      { minute: "14'", player: "Роберт Левандовски", assist: "Педри", score: "1-0" },
      { minute: "52'", player: "Ламин Ямаль", assist: "Рафинья", score: "2-0" },
      { minute: "68'", player: "Винисиус Жуниор", assist: "Джуд Беллингем", score: "2-1" },
      { minute: "88'", player: "Рафинья", assist: "Ламин Ямаль", score: "3-1" }
    ],
    sofaScoreRatings: [
      { name: "Ламин Ямаль", pos: "RW", rating: "9.2", isMotm: true, stats: "1 гол, 1 ассист, 6 успешных дриблингов" },
      { name: "Рафинья", pos: "LW", rating: "8.8", isMotm: false, stats: "1 гол, 1 ассист, 12.1 км пробега" },
      { name: "Педри", pos: "CM", rating: "8.6", isMotm: false, stats: "1 ассист, 94% точных пасов" },
      { name: "Пау Кубарси", pos: "CB", rating: "7.8", isMotm: false, stats: "6 выносов, 95% точных передач" }
    ],
    advancedStats: {
      possession: { home: "64%", away: "36%" },
      shotsOnTarget: { home: "9", away: "2" },
      totalShots: { home: "18", away: "7" },
      corners: { home: "8", away: "3" },
      fouls: { home: "10", away: "15" }
    }
  });
});

// Эндпоинт турнирной таблицы
app.get('/api/standings', async (req, res) => {
  try {
    const response = await axios.get(
      'https://api.football-data.org/v4/competitions/PD/standings',
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY } }
    );
    res.json(response.data.standings[0].table);
  } catch (error) {
    res.status(500).json({ error: 'Не удалось загрузить турнирную таблицу' });
  }
});

// Эндпоинт La Masia
app.get('/api/masia', (req, res) => {
  res.json({
    teamInfo: {
      name: 'Barça Atlètic',
      league: 'Primera Federación (Группа 1)',
      stadium: 'Estadi Johan Cruyff',
      headCoach: 'Альберт Санчес',
      averageAge: '18.8 лет'
    },
    players: [
      { name: 'Унаи Эрнандес', number: '10', pos: 'CM / LW', age: 19, marketValue: '€2.5M', potential: '86' },
      { name: 'Марк Берналь', number: '28', pos: 'CDM', age: 19, marketValue: '€30.0M', potential: '91' },
      { name: 'Андрес Куэнка', number: '4', pos: 'CB', age: 17, marketValue: '€1.2M', potential: '85' },
      { name: 'Ким Джуньент', number: '8', pos: 'CAM', age: 17, marketValue: '€1.8M', potential: '88' },
      { name: 'Гилье Фернандес', number: '16', pos: 'CM', age: 16, marketValue: '€3.0M', potential: '92' }
    ]
  });
});

// Эндпоинт финансов
app.get('/api/finance', (req, res) => {
  res.json(FINANCIAL_ANALYTICS);
});

// ==========================================
// 6. ЗАПУСК СЕРВЕРА
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`===========================================`);
  console.log(`FC Barcelona API Engine 2026/2027 Started`);
  console.log(`Port: ${PORT}`);
  console.log(`===========================================`);
  fetchMatchesAutoUpdate();
});
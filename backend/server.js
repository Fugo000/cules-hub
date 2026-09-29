const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

const FOOTBALL_API_KEY = process.env.FOOTBALL_API_KEY || '136b36f3434747f3901037536999125d';
const BARCA_TEAM_ID = 81;

// ==========================================
// 1. СИСТЕМА КЭШИРОВАНИЯ И LIVE-ОБНОВЛЕНИЯ
// ==========================================
let cache = {
  matches: null,
  matchesLastFetch: 0,
  standings: null,
  standingsLastFetch: 0
};

const REGULAR_CACHE_TTL = 15 * 60 * 1000; // 15 минут
const LIVE_CACHE_TTL = 30 * 1000;         // 30 секунд при LIVE-матчах

// ==========================================
// 2. РАСШИРЕННАЯ БАЗА ДАННЫХ СОСТАВА (2026/2027)
// ==========================================
const DETAILED_SQUAD_DATABASE_2026_2027 = {
  season: "2026/2027",
  club: "FC Barcelona",
  stadium: {
    name: "Spotify Camp Nou",
    capacity: 105000,
    status: "Частичное открытие (68,000 зрителей в сентябре 2026)",
    pitchDimensions: "105m x 68m",
    surface: "Hybrid Grass (GrassMaster)"
  },
  management: {
    president: "Жоан Лапорта",
    firstVicePresident: "Рафа Юсте",
    sportingDirector: "Деку",
    coordinator: "Боян Кркич",
    headCoach: {
      name: "Ханс-Дитер Флик",
      nationality: "Германия",
      age: 61,
      appointed: "2024-05-29",
      preferredFormation: "4-2-3-1 / 4-3-3 Heavy Pressing",
      assistantCoaches: ["Тони Тапалович", "Маркус Зорг"]
    }
  },
  captains: [
    { order: 1, name: "Рафинья", role: "Главный капитан (Первый)" },
    { order: 2, name: "Марк-Андре тер Штеген", role: "Вице-капитан (Второй)" },
    { order: 3, name: "Педри", role: "3-й капитан" },
    { order: 4, name: "Френки де Йонг", role: "4-й капитан" },
    { order: 5, name: "Пау Кубарси", role: "5-й капитан" }
  ],
  squad: {
    goalkeepers: [
      {
        id: 1,
        name: "Жоан Гарсия",
        number: 1,
        pos: "GK",
        age: 25,
        height: "191 см",
        weight: "82 кг",
        foot: "Правая",
        marketValue: "€45,000,000",
        contractEnd: "2031-06-30",
        clause: "€400,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 28, cleanSheets: 14, saves: 72, savePercentage: "78.2%", xGConcededPrevented: "+4.12", accurateLongPasses: "62.4%" },
        traits: "Элитная игра на выходах, рефлексы на линии, уверенный первый пас под прессингом"
      },
      {
        id: 13,
        name: "Войцех Щенсный",
        number: 13,
        pos: "GK",
        age: 36,
        height: "195 см",
        weight: "84 кг",
        foot: "Правая",
        marketValue: "€800,000",
        contractEnd: "2027-06-30",
        clause: "€50,000,000",
        nationality: "Польша",
        status: "Здоровый",
        stats2627: { matches: 4, cleanSheets: 2, saves: 11, savePercentage: "73.3%", xGConcededPrevented: "+0.85", accurateLongPasses: "58.1%" },
        traits: "Колоссальный опыт в топ-матчах, руководство защитной линией, отражение пенальти"
      },
      {
        id: 25,
        name: "Доминик Ливакович",
        number: 25,
        pos: "GK",
        age: 31,
        height: "188 см",
        weight: "79 кг",
        foot: "Правая",
        marketValue: "€4,000,000",
        contractEnd: "2028-06-30",
        clause: "€100,000,000",
        nationality: "Хорватия",
        status: "Здоровый",
        stats2627: { matches: 2, cleanSheets: 1, saves: 5, savePercentage: "71.4%", xGConcededPrevented: "+0.10", accurateLongPasses: "55.0%" },
        traits: "Реакция при ближних ударах, хладнокровие в сериях пенальти"
      }
    ],
    defenders: [
      {
        id: 2,
        name: "Жуан Канселу",
        number: 2,
        pos: "RB/LB",
        age: 32,
        height: "182 см",
        weight: "74 кг",
        foot: "Правая",
        marketValue: "€8,000,000",
        contractEnd: "2027-06-30",
        clause: "€150,000,000",
        nationality: "Португалия",
        status: "Здоровый",
        stats2627: { matches: 18, goals: 1, assists: 4, keyPassesPer90: 1.85, tacklesPer90: 2.1, progressiveCarries: 68 },
        traits: "Инвертированный фланговый защитник, смещение в опорную зону, скрытые передачи в штрафную"
      },
      {
        id: 3,
        name: "Алехандро Бальде",
        number: 3,
        pos: "LB",
        age: 22,
        height: "175 см",
        weight: "69 кг",
        foot: "Левая",
        marketValue: "€50,000,000",
        contractEnd: "2028-06-30",
        clause: "€1,000,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 26, goals: 2, assists: 6, keyPassesPer90: 2.12, topSpeed: "35.8 км/ч", successfulCrosses: "34.2%" },
        traits: "Взрывная стартовая скорость, ширина атаки на левом фланге, страховка при контратаках"
      },
      {
        id: 5,
        name: "Пау Кубарси",
        number: 5,
        pos: "CB",
        age: 19,
        height: "184 см",
        weight: "77 кг",
        foot: "Правая",
        marketValue: "€100,000,000",
        contractEnd: "2029-06-30",
        clause: "€1,000,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 30, goals: 1, tackles: 68, passAcc: "94.1%", longPassAcc: "82.5%", aerialDuelsWon: "68.4%" },
        traits: "Феноменальный первый пас (Out-of-defense ball progression), чтение игры, выбор позиции"
      },
      {
        id: 23,
        name: "Жюль Кунде",
        number: 23,
        pos: "RB/CB",
        age: 27,
        height: "181 см",
        weight: "75 кг",
        foot: "Правая",
        marketValue: "€60,000,000",
        contractEnd: "2027-06-30",
        clause: "€1,000,000,000",
        nationality: "Франция",
        status: "Здоровый",
        stats2627: { matches: 29, goals: 2, assists: 5, duelsWonPercentage: "64.1%", tackles: 71, minutesPlayed: 2580 },
        traits: "Универсализм, надежность в единоборствах 1-в-1, подключения по флангу"
      },
      {
        id: 24,
        name: "Эрик Гарсия",
        number: 24,
        pos: "CB/CDM",
        age: 25,
        height: "182 см",
        weight: "76 кг",
        foot: "Правая",
        marketValue: "€40,000,000",
        contractEnd: "2028-06-30",
        clause: "€400,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 20, goals: 1, assists: 1, passAcc: "92.8%", interceptionsPer90: 1.6 },
        traits: "Тактическая гибкость, страховка в высокой линии защиты"
      }
    ],
    midfielders: [
      {
        id: 6,
        name: "Гави",
        number: 6,
        pos: "CM/CAM",
        age: 22,
        height: "173 см",
        weight: "70 кг",
        foot: "Правая",
        marketValue: "€30,000,000",
        contractEnd: "2028-06-30",
        clause: "€1,000,000,000",
        nationality: "Испания",
        status: "Восстановление после нагрузок",
        stats2627: { matches: 25, goals: 4, assists: 5, pressureActionsPer90: 28.4, foulsWon: 52 },
        traits: "Бескомпромиссный контрпрессинг, агрессия в борьбе, продвижение мяча"
      },
      {
        id: 7,
        name: "Фермин Лопес",
        number: 7,
        pos: "CAM/CM",
        age: 23,
        height: "174 см",
        weight: "68 кг",
        foot: "Правая",
        marketValue: "€100,000,000",
        contractEnd: "2029-06-30",
        clause: "€500,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 28, goals: 9, assists: 6, shotsPer90: 2.8, xG: "8.42" },
        traits: "Агрессивное врывание в штрафную из глубины, поставленный дальний удар"
      },
      {
        id: 8,
        name: "Педри",
        number: 8,
        pos: "CM/CAM",
        age: 23,
        height: "174 см",
        weight: "67 кг",
        foot: "Правая",
        marketValue: "€150,000,000",
        contractEnd: "2030-06-30",
        clause: "€1,000,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 31, goals: 7, assists: 12, passAcc: "93.4%", keyPassesTotal: 84, xA: "11.2" },
        traits: "Управление темпом матча, видение поля, пауза (la pausa)"
      },
      {
        id: 20,
        name: "Дани Ольмо",
        number: 20,
        pos: "CAM/LW",
        age: 28,
        height: "179 см",
        weight: "72 кг",
        foot: "Правая",
        marketValue: "€60,000,000",
        contractEnd: "2030-06-30",
        clause: "€500,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 22, goals: 8, assists: 5, successfulDribbles: "62.5%" },
        traits: "Игра между линиями соперника, обработка мяча в узких пространствах"
      },
      {
        id: 21,
        name: "Френки де Йонг",
        number: 21,
        pos: "CM/CDM",
        age: 29,
        height: "180 см",
        weight: "74 кг",
        foot: "Правая",
        marketValue: "€35,000,000",
        contractEnd: "2028-06-30",
        clause: "€400,000,000",
        nationality: "Нидерланды",
        status: "Здоровый",
        stats2627: { matches: 26, goals: 2, assists: 6, passAcc: "94.2%", progressiveCarriesPer90: 8.4 },
        traits: "Продвижение мяча на дриблинге из первой третьи, укрывание мяча корпусом"
      }
    ],
    forwards: [
      {
        id: 9,
        name: "Габриэль Жезус",
        number: 9,
        pos: "ST",
        age: 29,
        height: "175 см",
        weight: "73 кг",
        foot: "Правая",
        marketValue: "€17,000,000",
        contractEnd: "2028-06-30",
        clause: "€300,000,000",
        nationality: "Бразилия",
        status: "Здоровый",
        stats2627: { matches: 23, goals: 11, assists: 4, shotsOnTargetRatio: "54.2%", xG: "10.1" },
        traits: "Прессинг защитников, подыгрыш партнёрам, смещения в полуфланги"
      },
      {
        id: 10,
        name: "Ламин Ямаль",
        number: 10,
        pos: "RW",
        age: 19,
        height: "180 см",
        weight: "72 кг",
        foot: "Левая",
        marketValue: "€220,000,000",
        contractEnd: "2031-06-30",
        clause: "€1,000,000,000",
        nationality: "Испания",
        status: "Здоровый",
        stats2627: { matches: 32, goals: 18, assists: 19, completedDribbles: 114, bigChancesCreated: 24, xG: "15.8", xA: "17.1" },
        traits: "Уникальный дриблинг 1-в-1, обводящие удары в дальний угол, нестандартные передачи"
      },
      {
        id: 11,
        name: "Рафинья",
        number: 11,
        pos: "LW/RW",
        age: 29,
        height: "176 см",
        weight: "68 кг",
        foot: "Левая",
        marketValue: "€70,000,000",
        contractEnd: "2028-06-30",
        clause: "€1,000,000,000",
        nationality: "Бразилия",
        status: "Здоровый",
        stats2627: { matches: 30, goals: 16, assists: 14, distanceCoveredAvg: "11.8 км", keyPassesPer90: 3.1 },
        traits: "Объем беговой работы, открывания за спину защитникам, исполнения стандартов"
      }
    ]
  }
};

// ==========================================
// 3. БАЗА ДАННЫХ: СКАУТИНГ LA MASIA
// ==========================================
const LA_MASIA_ACADEMY_DATABASE = {
  teamInfo: {
    name: "Barça Atlètic",
    league: "Primera Federación (Группа 1)",
    stadium: "Estadi Johan Cruyff",
    capacity: 6000,
    headCoach: "Альберт Санчес",
    averageAge: "18.8 лет",
    tacticalSystem: "4-3-3 Position Play"
  },
  players: [
    {
      id: 301,
      name: "Унаи Эрнандес",
      number: "10",
      pos: "CM / LW",
      age: 19,
      height: "176 см",
      weight: "67 кг",
      foot: "Правая",
      marketValue: "€2,500,000",
      potential: "86 / 99",
      contractUntil: "2027",
      stats: "8 голов, 5 ассистов (22 матча)",
      traits: "Мастер стандартов, поставленный удар с правой, видение свободного пространства",
      scoutingReport: "Готов к регулярным выходам на замену в первой команде."
    },
    {
      id: 302,
      name: "Марк Берналь",
      number: "28",
      pos: "CDM",
      age: 19,
      height: "191 см",
      weight: "81 кг",
      foot: "Левая",
      marketValue: "€30,000,000",
      potential: "91 / 99",
      contractUntil: "2029",
      stats: "Закрепился в заявке первой команды",
      traits: "Чтение игры, перехваты, хладнокровие под прессингом",
      scoutingReport: "Один из наиболее перспективных опорников академии со времён Бускетса."
    },
    {
      id: 303,
      name: "Андрес Куэнка",
      number: "4",
      pos: "CB",
      age: 17,
      height: "183 см",
      weight: "74 кг",
      foot: "Левая",
      marketValue: "€1,200,000",
      potential: "85 / 99",
      contractUntil: "2027",
      stats: "18 матчей, 91% точность передач",
      traits: "Первый пас с левой ноги, страховка партнёров",
      scoutingReport: "Надежный центральный защитник для системы с высокой линией обороны."
    },
    {
      id: 304,
      name: "Ким Джуньент",
      number: "8",
      pos: "CAM",
      age: 17,
      height: "171 см",
      weight: "63 кг",
      foot: "Правая",
      marketValue: "€1,800,000",
      potential: "88 / 99",
      contractUntil: "2028",
      stats: "6 голов, 4 ассиста",
      traits: "Дриблинг на носовом платке, быстрая принятия решений",
      scoutingReport: "Высокая культура паса и мобильность между линиями."
    },
    {
      id: 305,
      name: "Гилье Фернандес",
      number: "16",
      pos: "CM",
      age: 16,
      height: "179 см",
      weight: "72 кг",
      foot: "Правая",
      marketValue: "€3,000,000",
      potential: "92 / 99",
      contractUntil: "2028",
      stats: "14 матчей, 3 гола",
      traits: "Мощный рывок с мячом, завершение из-за штрафной",
      scoutingReport: "Физически развитый полузащитник профиля Box-to-Box."
    }
  ]
};

// ==========================================
// 4. БАЗА ДАННЫХ: CAPOLOGY & FFP
// ==========================================
const DETAILED_FINANCIAL_HUB = {
  currency: "EUR",
  season: "2026/2027",
  financialSummary: {
    totalYearlyWageBillGross: "€214,800,000",
    totalYearlyWageBillNet: "€107,400,000",
    averageWeeklySalary: "€165,230",
    squadMarketValuation: "€1,023,800,000",
    laLigaSalaryCapLimit: "€426,427,000",
    ffpRuleStatus: "Правило 1:1 (Полное соответствие требований La Liga)",
    stadiumFinancingDebt: "€1,450,000,000 (Облигации Goldman Sachs / JP Morgan)"
  },
  playerContracts: [
    {
      name: "Ламин Ямаль",
      grossYearly: "€16,670,000",
      grossWeekly: "€320,576",
      netYearly: "€8,335,000",
      marketVal: "€220.0M",
      clause: "€1,000,000,000",
      contractEnd: "2031-06-30",
      ffpAmortization: "€0 (Воспитанник академии)"
    },
    {
      name: "Педри",
      grossYearly: "€14,500,000",
      grossWeekly: "€278,846",
      netYearly: "€7,250,000",
      marketVal: "€150.0M",
      clause: "€1,000,000,000",
      contractEnd: "2030-06-30",
      ffpAmortization: "€4,000,000/год"
    },
    {
      name: "Рафинья",
      grossYearly: "€14,000,000",
      grossWeekly: "€269,230",
      netYearly: "€7,000,000",
      marketVal: "€70.0M",
      clause: "€1,000,000,000",
      contractEnd: "2028-06-30",
      ffpAmortization: "€11,600,000/год"
    },
    {
      name: "Пау Кубарси",
      grossYearly: "€8,000,000",
      grossWeekly: "€153,846",
      netYearly: "€4,000,000",
      marketVal: "€100.0M",
      clause: "€1,000,000,000",
      contractEnd: "2029-06-30",
      ffpAmortization: "€0 (Воспитанник академии)"
    },
    {
      name: "Дани Ольмо",
      grossYearly: "€9,380,000",
      grossWeekly: "€180,385",
      netYearly: "€4,690,000",
      marketVal: "€60.0M",
      clause: "€500,000,000",
      contractEnd: "2030-06-30",
      ffpAmortization: "€9,100,000/год"
    },
    {
      name: "Френки де Йонг",
      grossYearly: "€19,000,000",
      grossWeekly: "€365,385",
      netYearly: "€9,500,000",
      marketVal: "€35.0M",
      clause: "€400,000,000",
      contractEnd: "2028-06-30",
      ffpAmortization: "€17,200,000/год"
    }
  ]
};

// ==========================================
// 5. ВЫЗОВЫ API И ОБНОВЛЕНИЕ
// ==========================================
async function fetchMatchesAutoUpdate() {
  const now = Date.now();
  const ttl = (cache.matches && cache.matches.some(m => m.status === 'IN_PLAY')) 
    ? LIVE_CACHE_TTL 
    : REGULAR_CACHE_TTL;

  if (cache.matches && (now - cache.matchesLastFetch < ttl)) {
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
    return sortedMatches;
  } catch (error) {
    console.error('[Auto-Update Match Error]', error.message);
    return cache.matches || [];
  }
}

setInterval(fetchMatchesAutoUpdate, 30000);

// ==========================================
// 6. API ENDPOINTS
// ==========================================

app.get('/', (req, res) => {
  res.send(`
    <div style="font-family: sans-serif; padding: 20px; background: #0c0d12; color: #fff; min-height: 100vh;">
      <h1 style="color: #004D98;">🔵🔴 Culés Hub — Extended Analytics Engine 26/27</h1>
      <p style="color: #4AF6C3;">Backend-сервер с расширенной статистикой успешно работает!</p>
      <hr style="border-color: #232738;" />
      <ul>
        <li><a style="color:#FFCC00;" href="/api/squad">/api/squad</a> — Состав 2026/2027 с продвинутыми метриками</li>
        <li><a style="color:#FFCC00;" href="/api/matches">/api/matches</a> — Календарь матчей с фильтрами</li>
        <li><a style="color:#FFCC00;" href="/api/masia">/api/masia</a> — Скаутинг и характеристики La Masia</li>
        <li><a style="color:#FFCC00;" href="/api/finance">/api/finance</a> — Финансовый отчет Capology & FFP</li>
      </ul>
    </div>
  `);
});

app.get('/api', (req, res) => {
  res.json({
    status: "Active",
    season: "2026/2027",
    club: "FC Barcelona",
    engineVersion: "4.0.0",
    timestamp: new Date().toISOString()
  });
});

app.get('/api/squad', (req, res) => {
  res.json(DETAILED_SQUAD_DATABASE_2026_2027);
});

app.get('/api/matches', async (req, res) => {
  const matches = await fetchMatchesAutoUpdate();
  res.json(matches);
});

app.get('/api/matches/:id', async (req, res) => {
  const matchId = req.params.id;
  res.json({
    id: matchId,
    season: "2026/2027",
    status: "FINISHED",
    competition: "La Liga EA Sports",
    venue: "Spotify Camp Nou",
    referee: "Хесус Хиль Мансано",
    attendance: 68000,
    teams: {
      home: { name: "FC Barcelona", score: 3, xG: "2.84" },
      away: { name: "Real Madrid CF", score: 1, xG: "0.91" }
    },
    goals: [
      { minute: "14'", player: "Габриэль Жезус", assist: "Педри", score: "1-0" },
      { minute: "52'", player: "Ламин Ямаль", assist: "Рафинья", score: "2-0" },
      { minute: "68'", player: "Винисиус Жуниор", assist: "Джуд Беллингем", score: "2-1" },
      { minute: "88'", player: "Рафинья", assist: "Ламин Ямаль", score: "3-1" }
    ],
    sofaScoreRatings: [
      { name: "Ламин Ямаль", pos: "RW", rating: "9.2", isMotm: true, stats: "1 гол, 1 ассист, 6 успешных дриблингов" },
      { name: "Рафинья", pos: "LW", rating: "8.8", isMotm: false, stats: "1 гол, 1 ассист, 11.8 км пробега" },
      { name: "Педри", pos: "CM", rating: "8.6", isMotm: false, stats: "1 ассист, 93.4% точных пасов" },
      { name: "Пау Кубарси", pos: "CB", rating: "7.8", isMotm: false, stats: "6 выносов, 94.1% точных передач" }
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

app.get('/api/masia', (req, res) => {
  res.json(LA_MASIA_ACADEMY_DATABASE);
});

app.get('/api/finance', (req, res) => {
  res.json(DETAILED_FINANCIAL_HUB);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
  fetchMatchesAutoUpdate();
});
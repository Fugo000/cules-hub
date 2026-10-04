const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

const FOOTBALL_API_KEY = process.env.FOOTBALL_API_KEY || '136b36f3434747f3901037536999125d';
const BARCA_TEAM_ID = 81;

// ==========================================
// 1. КЭШ И АВТООБНОВЛЕНИЕ
// ==========================================
let cache = {
  matches: null,
  matchesLastFetch: 0,
  standings: null,
  standingsLastFetch: 0
};

const REGULAR_CACHE_TTL = 15 * 60 * 1000; // 15 минут
const LIVE_CACHE_TTL = 30 * 1000;         // 30 секунд

// ==========================================
// 2. БАЗА ДАННЫХ СОСТАВА 2026/2027
// ==========================================
const SQUAD_2026_2027 = {
  season: "2026/2027",
  club: "FC Barcelona",
  stadium: {
    name: "Spotify Camp Nou",
    capacity: 105000,
    status: "Частичное открытие (68,000 мест)"
  },
  management: {
    headCoach: "Ханс-Дитер Флик",
    sportingDirector: "Деку",
    president: "Жоан Лапорта"
  },
  squad: {
    goalkeepers: [
      { id: 1, name: "Жоан Гарсия", number: 1, pos: "GK", age: 25, height: "191 см", weight: "82 кг", foot: "Правая", marketValue: "€45M", contractEnd: "2031", clause: "€400M", nationality: "Испания", stats2627: { matches: 28, cleanSheets: 14, saves: 72 }, traits: "Рефлексы на линии, игра под прессингом" },
      { id: 13, name: "Войцех Щенсный", number: 13, pos: "GK", age: 36, height: "195 см", weight: "84 кг", foot: "Правая", marketValue: "€800K", contractEnd: "2027", clause: "€50M", nationality: "Польша", stats2627: { matches: 4, cleanSheets: 2, saves: 11 }, traits: "Опыт в топ-матчах, отражение пенальти" }
    ],
    defenders: [
      { id: 2, name: "Жуан Канселу", number: 2, pos: "RB/LB", age: 32, height: "182 см", weight: "74 кг", foot: "Правая", marketValue: "€8M", contractEnd: "2027", clause: "€150M", nationality: "Португалия", stats2627: { matches: 18, goals: 1, assists: 4 }, traits: "Инвертированный крайний защитник, подключения в атаку" },
      { id: 3, name: "Алехандро Бальде", number: 3, pos: "LB", age: 22, height: "175 см", weight: "69 кг", foot: "Левая", marketValue: "€50M", contractEnd: "2028", clause: "€1000M", nationality: "Испания", stats2627: { matches: 26, goals: 2, assists: 6 }, traits: "Стартовая скорость 35.8 км/ч, ширина атаки" },
      { id: 5, name: "Пау Кубарси", number: 5, pos: "CB", age: 19, height: "184 см", weight: "77 кг", foot: "Правая", marketValue: "€100M", contractEnd: "2029", clause: "€1000M", nationality: "Испания", stats2627: { matches: 30, goals: 1, passAcc: "94.1%" }, traits: "Первый пас под прессингом, чтение игры" },
      { id: 23, name: "Жюль Кунде", number: 23, pos: "RB/CB", age: 27, height: "181 см", weight: "75 кг", foot: "Правая", marketValue: "€60M", contractEnd: "2027", clause: "€1000M", nationality: "Франция", stats2627: { matches: 29, goals: 2, assists: 5 }, traits: "Единоборства 1-в-1, универсализм" },
      { id: 24, name: "Эрик Гарсия", number: 24, pos: "CB/CDM", age: 25, height: "182 см", weight: "76 кг", foot: "Правая", marketValue: "€40M", contractEnd: "2028", clause: "€400M", nationality: "Испания", stats2627: { matches: 20, goals: 1, assists: 1 }, traits: "Страховка высокой линии обороны" }
    ],
    midfielders: [
      { id: 6, name: "Гави", number: 6, pos: "CM/CAM", age: 22, height: "173 см", weight: "70 кг", foot: "Правая", marketValue: "€30M", contractEnd: "2028", clause: "€1000M", nationality: "Испания", stats2627: { matches: 25, goals: 4, assists: 5 }, traits: "Контрпрессинг, агрессия в отборе" },
      { id: 7, name: "Фермин Лопес", number: 7, pos: "CAM/CM", age: 23, height: "174 см", weight: "68 кг", foot: "Правая", marketValue: "€100M", contractEnd: "2029", clause: "€500M", nationality: "Испания", stats2627: { matches: 28, goals: 9, assists: 6 }, traits: "Врывания в штрафную из глубины, дальний удар" },
      { id: 8, name: "Педри", number: 8, pos: "CM/CAM", age: 23, height: "174 см", weight: "67 кг", foot: "Правая", marketValue: "€150M", contractEnd: "2030", clause: "€1000M", nationality: "Испания", stats2627: { matches: 31, goals: 7, assists: 12 }, traits: "Управление темпом игры, пауза (la pausa)" },
      { id: 20, name: "Дани Ольмо", number: 20, pos: "CAM/LW", age: 28, height: "179 см", weight: "72 кг", foot: "Правая", marketValue: "€60M", contractEnd: "2030", clause: "€500M", nationality: "Испания", stats2627: { matches: 22, goals: 8, assists: 5 }, traits: "Дриблинг в узких зонах, игра между линиями" },
      { id: 21, name: "Френки де Йонг", number: 21, pos: "CM/CDM", age: 29, height: "180 см", weight: "74 кг", foot: "Правая", marketValue: "€35M", contractEnd: "2028", clause: "€400M", nationality: "Нидерланды", stats2627: { matches: 26, goals: 2, assists: 6 }, traits: "Продвижение мяча из первой третьи" }
    ],
    forwards: [
      { id: 9, name: "Габриэль Жезус", number: 9, pos: "ST", age: 29, height: "175 см", weight: "73 кг", foot: "Правая", marketValue: "€17M", contractEnd: "2028", clause: "€300M", nationality: "Бразилия", stats2627: { matches: 23, goals: 11, assists: 4 }, traits: "Прессинг защитников, подыгрыш" },
      { id: 10, name: "Ламин Ямаль", number: 10, pos: "RW", age: 19, height: "180 см", weight: "72 кг", foot: "Левая", marketValue: "€220M", contractEnd: "2031", clause: "€1000M", nationality: "Испания", stats2627: { matches: 32, goals: 18, assists: 19 }, traits: "Обводка 1-в-1, обводящие удары" },
      { id: 11, name: "Рафинья", number: 11, pos: "LW/RW", age: 29, height: "176 см", weight: "68 кг", foot: "Левая", marketValue: "€70M", contractEnd: "2028", clause: "€1000M", nationality: "Бразилия", stats2627: { matches: 30, goals: 16, assists: 14 }, traits: "Объем беговой работы, исполнение стандартов" }
    ]
  }
};

// ==========================================
// 3. БАЗА LA MASIA И ФИНАНСОВ
// ==========================================
const MASIA_DATA = {
  teamInfo: {
    name: "Barça Atlètic",
    league: "Primera Federación (Группа 1)",
    stadium: "Estadi Johan Cruyff",
    headCoach: "Альберт Санчес",
    tacticalSystem: "4-3-3 Position Play"
  },
  players: [
    { id: 301, name: "Унаи Эрнандес", pos: "CM/LW", age: 19, marketValue: "€2.5M", potential: "86/99", traits: "Исполнение штрафных, видение поля", scoutingReport: "Готов к ротации в первой команде" },
    { id: 302, name: "Марк Берналь", pos: "CDM", age: 19, marketValue: "€30.0M", potential: "91/99", traits: "Перехваты, физика, чтение игры", scoutingReport: "Главный профильный опорник системы" },
    { id: 303, name: "Андрес Куэнка", pos: "CB", age: 17, marketValue: "€1.2M", potential: "85/99", traits: "Первый пас с левой ноги", scoutingReport: "Надежен для высокой линии защиты" },
    { id: 304, name: "Ким Джуньент", pos: "CAM", age: 17, marketValue: "€1.8M", potential: "88/99", traits: "Дриблинг в узких пространствах", scoutingReport: "Высокая культура короткого паса" },
    { id: 305, name: "Гилье Фернандес", pos: "CM", age: 16, marketValue: "€3.0M", potential: "92/99", traits: "Мощный рывок, дальний удар", scoutingReport: "Физически развитый полузащитник Box-to-Box" }
  ]
};

const FINANCIAL_DATA = {
  currency: "EUR",
  season: "2026/2027",
  financialSummary: {
    totalYearlyWageBillGross: "€214,800,000",
    totalYearlyWageBillNet: "€107,400,000",
    squadMarketValuation: "€1,023,800,000",
    laLigaSalaryCapLimit: "€426,427,000",
    ffpRuleStatus: "Правило 1:1 (Соответствие требованиям)"
  },
  playerContracts: [
    { name: "Ламин Ямаль", grossYearly: "€16,670,000", grossWeekly: "€320,576", clause: "€1,000M", contractEnd: "2031", ffpAmortization: "€0 (Воспитанник)" },
    { name: "Педри", grossYearly: "€14,500,000", grossWeekly: "€278,846", clause: "€1,000M", contractEnd: "2030", ffpAmortization: "€4,000,000/год" },
    { name: "Рафинья", grossYearly: "€14,000,000", grossWeekly: "€269,230", clause: "€1,000M", contractEnd: "2028", ffpAmortization: "€11,600,000/год" },
    { name: "Пау Кубарси", grossYearly: "€8,000,000", grossWeekly: "€153,846", clause: "€1,000M", contractEnd: "2029", ffpAmortization: "€0 (Воспитанник)" },
    { name: "Дани Ольмо", grossYearly: "€9,380,000", grossWeekly: "€180,385", clause: "€500M", contractEnd: "2030", ffpAmortization: "€9,100,000/год" },
    { name: "Френки де Йонг", grossYearly: "€19,000,000", grossWeekly: "€365,385", clause: "€400M", contractEnd: "2028", ffpAmortization: "€17,200,000/год" }
  ]
};

// ==========================================
// 4. МАРШРУТЫ API
// ==========================================

async function fetchMatchesAutoUpdate() {
  const now = Date.now();
  const ttl = (cache.matches && cache.matches.some(m => m.status === 'IN_PLAY')) ? LIVE_CACHE_TTL : REGULAR_CACHE_TTL;

  if (cache.matches && (now - cache.matchesLastFetch < ttl)) {
    return cache.matches;
  }

  try {
    const response = await axios.get(
      `https://api.football-data.org/v4/teams/${BARCA_TEAM_ID}/matches`,
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY } }
    );
    const sorted = response.data.matches.sort((a, b) => new Date(a.utcDate) - new Date(b.utcDate));
    cache.matches = sorted;
    cache.matchesLastFetch = now;
    return sorted;
  } catch (e) {
    return cache.matches || [];
  }
}

app.get('/api/squad', (req, res) => res.json(SQUAD_2026_2027));
app.get('/api/matches', async (req, res) => res.json(await fetchMatchesAutoUpdate()));
app.get('/api/masia', (req, res) => res.json(MASIA_DATA));
app.get('/api/finance', (req, res) => res.json(FINANCIAL_DATA));

app.get('/api/matches/:id', (req, res) => {
  res.json({
    id: req.params.id,
    season: "2026/2027",
    status: "FINISHED",
    competition: "La Liga EA Sports",
    venue: "Spotify Camp Nou",
    teams: { home: { name: "FC Barcelona", score: 3, xG: "2.84" }, away: { name: "Real Madrid CF", score: 1, xG: "0.91" } },
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
    advancedStats: { possession: { home: "64%", away: "36%" }, shotsOnTarget: { home: "9", away: "2" }, totalShots: { home: "18", away: "7" }, corners: { home: "8", away: "3" } }
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Culés Hub Engine active on port ${PORT}`));
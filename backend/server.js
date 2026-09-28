const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// =============================================================
// 1. МАТЧ-ЦЕНТР (СЕЗОН 2026/2027)
// =============================================================
app.get('/api/match/latest', (req, res) => {
  res.json({
    season: "2026/2027",
    latestMatch: {
      round: "Ла Лига • Тур 7",
      date: "19.09.2026",
      stadium: "Рамон Санчес Писхуан",
      homeTeam: { name: "Севилья", score: 1, logo: "SEV" },
      awayTeam: { name: "Барселона", score: 3, logo: "FCB" },
      matchStats: {
        possession: { home: "31%", away: "69%" },
        shots: { home: 7, away: 24 },
        shotsOnGoal: { home: 4, away: 7 },
        accuratePasses: { home: "170 (73%)", away: "573 (92%)" },
        corners: { home: 1, away: 3 },
        fouls: { home: 10, away: 11 }
      },
      goals: [
        { minute: "19'", player: "Юссуф Фофана", team: "SEV" },
        { minute: "22'", player: "Рафинья", team: "FCB" },
        { minute: "52'", player: "Рафинья", team: "FCB" },
        { minute: "69'", player: "Рафинья", team: "FCB" }
      ],
      sofascoreRatings: [
        { name: "Рафинья", pos: "ПВ", rating: 9.6, goals: 3, isMotm: true },
        { name: "Ламин Ямаль", pos: "ПВ", rating: 8.8, assists: 2 },
        { name: "Пау Кубарси", pos: "ЦЗ", rating: 7.9, passAcc: "93%" },
        { name: "Педри", pos: "ЦП", rating: 8.2, keyPasses: 4 },
        { name: "Родри", pos: "ОП", rating: 7.8, duelsWon: "6/8" },
        { name: "Доминик Ливакович", pos: "ВР", rating: 7.1, saves: 3 }
      ]
    },
    completedMatches: [
      { round: "Ла Лига • Тур 1", date: "23.08.2026", opponent: "Эльче", score: "5 : 0", venue: "Мануэль Мартинес Валеро" },
      { round: "Ла Лига • Тур 2", date: "27.08.2026", opponent: "Атлетик Бильбао", score: "2 : 0", venue: "Камп Ноу" },
      { round: "Ла Лига • Тур 3", date: "31.08.2026", opponent: "Райо Вальекано", score: "5 : 2", venue: "Камп Ноу" },
      { round: "Ла Лига • Тур 4", date: "06.09.2026", opponent: "Валенсия", score: "5 : 0", venue: "Месталья" },
      { round: "ЛЧ • Тур 1", date: "09.09.2026", opponent: "Фейеноорд", score: "5 : 1", venue: "Камп Ноу" },
      { round: "Ла Лига • Тур 5", date: "13.09.2026", opponent: "Леванте", score: "4 : 2", venue: "Сьюдад де Валенсия" },
      { round: "Ла Лига • Тур 6", date: "16.09.2026", opponent: "Расинг Сантандер", score: "7 : 2", venue: "Камп Ноу" },
      { round: "Ла Лига • Тур 7", date: "19.09.2026", opponent: "Севилья", score: "3 : 1", venue: "Рамон Санчес Писхуан" }
    ],
    upcomingMatches: [
      { round: "Ла Лига • Тур 8", date: "10.10.2026, 19:30", opponent: "Хетафе", venue: "Камп Ноу" },
      { round: "ЛЧ • Тур 2", date: "13.10.2026, 22:00", opponent: "Галатасарай", venue: "RAMS Park (Стамбул)" },
      { round: "Ла Лига • Тур 9", date: "17.10.2026, 19:30", opponent: "Реал Бетис", venue: "Ла-Картуха" },
      { round: "ЛЧ • Тур 3", date: "20.10.2026, 22:00", opponent: "Пари Сен-Жермен", venue: "Парк де Пренс" },
      { round: "Ла Лига • Тур 10 (El Clásico)", date: "25.10.2026, 22:00", opponent: "Реал Мадрид", venue: "Камп Ноу" }
    ]
  });
});

// =============================================================
// 2. РЕАЛЬНЫЙ СОСТАВ LA MASIA & BARÇA ATLÈTIC (2026/2027)
// =============================================================
app.get('/api/masia', (req, res) => {
  res.json({
    teamInfo: {
      name: "Barça Atlètic",
      league: "Primera Federación - Group 1",
      stadium: "Estadi Johan Cruyff",
      captains: ["Landry Farré", "Eder Aller", "Alex Campos"]
    },
    players: [
      // Вратари
      { number: 1, name: "Eder Aller", pos: "ВР", age: 19, marketValue: "€1.2M", potential: 87, stats: "6 сухих матчей" },
      { number: 13, name: "Max Bonfill", pos: "ВР", age: 18, marketValue: "€600K", potential: 84, stats: "2 сухих матча" },
      
      // Защитники
      { number: 2, name: "Landry Farré", pos: "ПЗ", age: 19, marketValue: "€1.8M", potential: 88, stats: "14 отборов, 2 ассиста" },
      { number: 3, name: "Javi Castro", pos: "ЦЗ", age: 21, marketValue: "€2.0M", potential: 85, stats: "89% точных передач" },
      { number: 4, name: "Alex Campos", pos: "ЦЗ", age: 20, marketValue: "€1.5M", potential: 86, stats: "18 перехватов" },
      { number: 5, name: "Josué Caicedo", pos: "ЦЗ", age: 19, marketValue: "€1.0M", potential: 84, stats: "Аренда из LDU Quito" },
      
      // Полузащитники
      { number: 6, name: "Pedro Villar", pos: "ЦП", age: 19, marketValue: "€1.2M", potential: 86, stats: "91% точных передач" },
      { number: 8, name: "Pedro Rodríguez", pos: "ЦП / ОП", age: 18, marketValue: "€2.5M", potential: 90, stats: "2 гола, 3 ассиста" },
      { number: 10, name: "Ebrima Tunkara", pos: "ЦАП", age: 17, marketValue: "€3.0M", potential: 93, stats: "4 гола, 2 ассиста" },
      { number: 12, name: "Mirza Catovic", pos: "ОП", age: 19, marketValue: "€1.4M", potential: 85, stats: "Аренда из VfB Stuttgart" },
      { number: 26, name: "Adam Argemí", pos: "ЦП", age: 18, marketValue: "€800K", potential: 87, stats: "Академия La Masia" },
      { number: 28, name: "Orian Goren", pos: "ЦАП", age: 17, marketValue: "€1.1M", potential: 89, stats: "Академия La Masia" },
      
      // Нападающие / Винги
      { number: 7, name: "Aziz Issah", pos: "ПВ", age: 20, marketValue: "€2.0M", potential: 88, stats: "3 гола, 4 ассиста" },
      { number: 11, name: "Shane Kluivert", pos: "ЛВ / НАП", age: 19, marketValue: "€2.8M", potential: 91, stats: "5 голов, 3 ассиста" },
      { number: 27, name: "Joni Hernández", pos: "НАП", age: 18, marketValue: "€900K", potential: 86, stats: "3 гола" },
      { number: 29, name: "Jesse Bisiwu", pos: "ЛВ", age: 18, marketValue: "€1.5M", potential: 88, stats: "2 гола, 2 ассиста" },
      { number: 30, name: "Hamza Abdelkarim", pos: "НАП", age: 19, marketValue: "€2.2M", potential: 87, stats: "5 голов" }
    ]
  });
});

app.listen(PORT, () => {
  console.log(`Сервер запущен на http://localhost:${PORT}`);
});
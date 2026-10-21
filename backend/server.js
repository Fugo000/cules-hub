const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

const FOOTBALL_API_KEY = process.env.FOOTBALL_API_KEY || '136b36f3434747f3901037536999125d';
const BARCA_TEAM_ID = 81;

// ==========================================
// 1. БАЗА СОСТАВА И РЕЗЕРВА СЕЗОНА 2026/2027 (28 ИГРОКОВ)
// ==========================================
const SQUAD_2026_2027 = {
  season: "2026/2027",
  club: "FC Barcelona",
  stadium: {
    name: "Spotify Camp Nou",
    capacity: 105000,
    status: "Открыт (68,000 зрителей на первом этапе)"
  },
  management: {
    headCoach: "Ханс-Дитер Флик",
    formation: "4-2-3-1 High Line",
    sportingDirector: "Деку",
    president: "Жоан Лапорта"
  },
  squad: {
    goalkeepers: [
      { id: 1, name: "Жоан Гарсия", number: 1, pos: "GK", role: "Starter", age: 25, height: "191 см", weight: "82 кг", foot: "Правая", marketValue: "€45.0M", contractEnd: "2031", clause: "€400M", nationality: "Испания", rating: "8.1", stats2627: { matches: 14, cleanSheets: 8, saves: 41, passAcc: "89%" }, traits: "Элитная реакция на линии, игра на выходах, длинный первый пас" },
      { id: 13, name: "Войцех Щенсный", number: 13, pos: "GK", role: "Reserve", age: 36, height: "195 см", weight: "84 кг", foot: "Правая", marketValue: "€800K", contractEnd: "2027", clause: "€50M", nationality: "Польша", rating: "7.3", stats2627: { matches: 3, cleanSheets: 1, saves: 9, passAcc: "84%" }, traits: "Опыт в топ-матчах, отражение пенальти, руководство обороной" },
      { id: 25, name: "Доминик Ливакович", number: 25, pos: "GK", role: "Reserve", age: 31, height: "188 см", weight: "79 кг", foot: "Правая", marketValue: "€4.0M", contractEnd: "2028", clause: "€100M", nationality: "Хорватия", rating: "7.1", stats2627: { matches: 1, cleanSheets: 1, saves: 4, passAcc: "82%" }, traits: "Игра на ленточке, серии пенальти" },
      { id: 31, name: "Эдер Аллер", number: 31, pos: "GK", role: "Reserve", age: 19, height: "189 см", weight: "80 кг", foot: "Правая", marketValue: "€500K", contractEnd: "2028", clause: "€50M", nationality: "Испания", rating: "6.9", stats2627: { matches: 0, cleanSheets: 0, saves: 0, passAcc: "90%" }, traits: "Игра ногами под прессингом, воспитанник академии" }
    ],
    defenders: [
      { id: 23, name: "Жюль Кунде", number: 23, pos: "RB / CB", role: "Starter", age: 27, height: "181 см", weight: "75 кг", foot: "Правая", marketValue: "€60.0M", contractEnd: "2027", clause: "€1000M", nationality: "Франция", rating: "7.9", stats2627: { matches: 15, goals: 2, assists: 4, tackles: 38, passAcc: "91%" }, traits: "Единоборства 1-в-1, подключения по правому флангу, выносливость" },
      { id: 5, name: "Пау Кубарси", number: 5, pos: "CB", role: "Starter", age: 19, height: "184 см", weight: "77 кг", foot: "Правая", marketValue: "€100.0M", contractEnd: "2029", clause: "€1000M", nationality: "Испания", rating: "8.2", stats2627: { matches: 15, goals: 1, assists: 2, tackles: 34, passAcc: "95%" }, traits: "Эталонный первый пас, чтение офсайдной ловушки, хладнокровие" },
      { id: 24, name: "Эрик Гарсия", number: 24, pos: "CB / CDM", role: "Starter", age: 25, height: "182 см", weight: "76 кг", foot: "Правая", marketValue: "€40.0M", contractEnd: "2028", clause: "€400M", nationality: "Испания", rating: "7.6", stats2627: { matches: 13, goals: 1, assists: 1, tackles: 25, passAcc: "94%" }, traits: "Продвижение мяча, универсальность (ЦЗ / Опорник), высокая линия" },
      { id: 3, name: "Алехандро Бальде", number: 3, pos: "LB", role: "Starter", age: 22, height: "175 см", weight: "69 кг", foot: "Левая", marketValue: "€50.0M", contractEnd: "2028", clause: "€1000M", nationality: "Испания", rating: "7.8", stats2627: { matches: 14, goals: 1, assists: 5, tackles: 24, passAcc: "89%" }, traits: "Рывок 35.8 км/ч, проходы по всей бровке, возврат в оборону" },
      { id: 2, name: "Жуан Канселу", number: 2, pos: "RB / LB", role: "Reserve", age: 32, height: "182 см", weight: "74 кг", foot: "Правая", marketValue: "€8.0M", contractEnd: "2027", clause: "€150M", nationality: "Португалия", rating: "7.4", stats2627: { matches: 10, goals: 1, assists: 3, tackles: 14, passAcc: "87%" }, traits: "Ложный фулбэк, креатив в финальной трети, удары шведой" },
      { id: 15, name: "Андреас Кристенсен", number: 15, pos: "CB / CDM", role: "Reserve", age: 30, height: "188 см", weight: "82 кг", foot: "Правая", marketValue: "€8.0M", contractEnd: "2027", clause: "€500M", nationality: "Дания", rating: "7.3", stats2627: { matches: 8, goals: 1, assists: 0, tackles: 16, passAcc: "94%" }, traits: "Позиционная грамотность, игра головой, спокойствие" },
      { id: 18, name: "Жерар Мартин", number: 18, pos: "LB / CB", role: "Reserve", age: 24, height: "186 см", weight: "78 кг", foot: "Левая", marketValue: "€35.0M", contractEnd: "2028", clause: "€200M", nationality: "Испания", rating: "7.2", stats2627: { matches: 11, goals: 0, assists: 2, tackles: 19, passAcc: "90%" }, traits: "Надежность в обороне, кроссы с левой ноги" },
      { id: 12, name: "Хави Эспарт", number: 12, pos: "RB", role: "Reserve", age: 19, height: "178 см", weight: "71 кг", foot: "Правая", marketValue: "€5.0M", contractEnd: "2028", clause: "€100M", nationality: "Испания", rating: "7.0", stats2627: { matches: 6, goals: 0, assists: 1, tackles: 10, passAcc: "88%" }, traits: "Интенсивный прессинг, скорость на фланге" },
      { id: 33, name: "Жорди Пескер", number: 33, pos: "LB", role: "Reserve", age: 17, height: "176 см", weight: "68 кг", foot: "Левая", marketValue: "€1.0M", contractEnd: "2028", clause: "€50M", nationality: "Испания", rating: "6.9", stats2627: { matches: 3, goals: 0, assists: 1, tackles: 5, passAcc: "89%" }, traits: "Техника Ла Масии, подключения в атаку" }
    ],
    midfielders: [
      { id: 8, name: "Педри", number: 8, pos: "CM / CAM", role: "Starter", age: 23, height: "174 см", weight: "67 кг", foot: "Правая", marketValue: "€150.0M", contractEnd: "2030", clause: "€1000M", nationality: "Испания", rating: "8.7", stats2627: { matches: 15, goals: 4, assists: 8, keyPasses: 46, passAcc: "94%" }, traits: "Гений тайминга (La Pausa), разрезающие передачи, контроль темпа" },
      { id: 21, name: "Френки де Йонг", number: 21, pos: "CM / CDM", role: "Starter", age: 29, height: "180 см", weight: "74 кг", foot: "Правая", marketValue: "€35.0M", contractEnd: "2028", clause: "€400M", nationality: "Нидерланды", rating: "7.9", stats2627: { matches: 14, goals: 1, assists: 4, keyPasses: 22, passAcc: "95%" }, traits: "Выход из-под прессинга на дриблинге, связующее звено" },
      { id: 20, name: "Дани Ольмо", number: 20, pos: "CAM / LW", role: "Starter", age: 28, height: "179 см", weight: "72 кг", foot: "Правая", marketValue: "€60.0M", contractEnd: "2030", clause: "€500M", nationality: "Испания", rating: "8.1", stats2627: { matches: 13, goals: 6, assists: 4, keyPasses: 28, passAcc: "88%" }, traits: "Прием мяча в полуфлангах, удар с двух ног, игра в касание" },
      { id: 16, name: "Родри", number: 16, pos: "CDM", role: "Reserve", age: 30, height: "191 см", weight: "82 кг", foot: "Правая", marketValue: "€55.0M", contractEnd: "2029", clause: "€500M", nationality: "Испания", rating: "8.3", stats2627: { matches: 12, goals: 2, assists: 3, tackles: 32, passAcc: "95%" }, traits: "Тотальный контроль опорной зоны, перехваты, дальние удары" },
      { id: 7, name: "Фермин Лопес", number: 7, pos: "CAM / CM", role: "Reserve", age: 23, height: "174 см", weight: "68 кг", foot: "Правая", marketValue: "€100.0M", contractEnd: "2029", clause: "€500M", nationality: "Испания", rating: "8.0", stats2627: { matches: 15, goals: 6, assists: 4, keyPasses: 21, passAcc: "87%" }, traits: "Врывания вторым темпом, пушечный удар, прессинг" },
      { id: 6, name: "Гави", number: 6, pos: "CM / CAM", role: "Reserve", age: 22, height: "173 см", weight: "70 кг", foot: "Правая", marketValue: "€30.0M", contractEnd: "2028", clause: "€1000M", nationality: "Испания", rating: "7.7", stats2627: { matches: 12, goals: 2, assists: 3, tackles: 29, passAcc: "90%" }, traits: "Сердце команды, контрпрессинг, бесстрашие в дуэлях" },
      { id: 22, name: "Марк Берналь", number: 22, pos: "CDM", role: "Reserve", age: 19, height: "191 см", weight: "81 кг", foot: "Левая", marketValue: "€30.0M", contractEnd: "2029", clause: "€500M", nationality: "Испания", rating: "7.6", stats2627: { matches: 11, goals: 1, assists: 2, tackles: 24, passAcc: "93%" }, traits: "Наследник Бускетса, левоногий диспетчер, перехваты" },
      { id: 4, name: "Брайан Фариньяс", number: 4, pos: "CM", role: "Reserve", age: 20, height: "180 см", weight: "72 кг", foot: "Правая", marketValue: "€2.5M", contractEnd: "2028", clause: "€100M", nationality: "Испания", rating: "7.0", stats2627: { matches: 5, goals: 0, assists: 1, keyPasses: 6, passAcc: "91%" }, traits: "Контроль мяча, работоспособность" }
    ],
    forwards: [
      { id: 10, name: "Ламин Ямаль", number: 10, pos: "RW", role: "Starter", age: 19, height: "180 см", weight: "72 кг", foot: "Левая", marketValue: "€220.0M", contractEnd: "2031", clause: "€1000M", nationality: "Испания", rating: "9.1", stats2627: { matches: 15, goals: 11, assists: 12, dribbles: 68, passAcc: "86%" }, traits: "Лучший дриблинг мира, обводящие удары в девятку, плеймейкер на фланге" },
      { id: 11, name: "Рафинья", number: 11, pos: "LW / RW", role: "Starter", age: 29, height: "176 см", weight: "68 кг", foot: "Левая", marketValue: "€70.0M", contractEnd: "2028", clause: "€1000M", nationality: "Бразилия", rating: "8.6", stats2627: { matches: 15, goals: 10, assists: 8, keyPasses: 39, passAcc: "84%" }, traits: "Капитан, рывки за спину защитникам, прессинг 90 минут" },
      { id: 9, name: "Габриэль Жезус", number: 9, pos: "ST", role: "Starter", age: 29, height: "175 см", weight: "73 кг", foot: "Правая", marketValue: "€17.0M", contractEnd: "2028", clause: "€300M", nationality: "Бразилия", rating: "7.8", stats2627: { matches: 13, goals: 8, assists: 3, shotsOnTarget: 21, passAcc: "83%" }, traits: "Мобильный форвард, прессинг вратаря, комбинационная игра в штрафной" },
      { id: 17, name: "Энтони Гордон", number: 17, pos: "LW", role: "Reserve", age: 25, height: "183 см", weight: "74 кг", foot: "Правая", marketValue: "€80.0M", contractEnd: "2030", clause: "€500M", nationality: "Англия", rating: "7.7", stats2627: { matches: 12, goals: 5, assists: 4, dribbles: 28, passAcc: "84%" }, traits: "Взрывная скорость на пространстве, прямолинейный дриблинг" },
      { id: 14, name: "Карим Адейеми", number: 14, pos: "LW / ST", role: "Reserve", age: 24, height: "180 см", weight: "71 кг", foot: "Левая", marketValue: "€40.0M", contractEnd: "2029", clause: "€400M", nationality: "Германия", rating: "7.5", stats2627: { matches: 11, goals: 4, assists: 2, dribbles: 22, passAcc: "82%" }, traits: "Спринт в контратаках, открывания под длинный пас" },
      { id: 19, name: "Руни Бардагжи", number: 19, pos: "RW / CAM", role: "Reserve", age: 20, height: "173 см", weight: "67 кг", foot: "Левая", marketValue: "€15.0M", contractEnd: "2029", clause: "€300M", nationality: "Швеция", rating: "7.3", stats2627: { matches: 9, goals: 2, assists: 2, dribbles: 18, passAcc: "85%" }, traits: "Резкое смещение в центр, хлесткий удар с левой" },
      { id: 29, name: "Хамза Абделькарим", number: 29, pos: "ST", role: "Reserve", age: 18, height: "186 см", weight: "78 кг", foot: "Правая", marketValue: "€1.5M", contractEnd: "2028", clause: "€100M", nationality: "Египет", rating: "7.1", stats2627: { matches: 4, goals: 2, assists: 0, shotsOnTarget: 5, passAcc: "80%" }, traits: "Игра в штрафной, мощный корпус" },
      { id: 27, name: "Жессе Бисиву", number: 27, pos: "LW", role: "Reserve", age: 18, height: "177 см", weight: "69 кг", foot: "Левая", marketValue: "€800K", contractEnd: "2028", clause: "€100M", nationality: "Бельгия", rating: "7.0", stats2627: { matches: 3, goals: 1, assists: 0, dribbles: 7, passAcc: "83%" }, traits: "Нестандартный дриблинг 1-в-1" }
    ]
  }
};

// ==========================================
// 2. ПОЛНЫЙ КАЛЕНДАРЬ МАТЧЕЙ СЕЗОНА 2026/2027
// ==========================================
const BASE_MATCHES_2026_2027 = [
  { id: 2601, utcDate: "2026-08-16T19:30:00Z", status: "FINISHED", matchday: 1, competition: { name: "La Liga EA Sports" }, venue: "Estadio de Mestalla", homeTeam: { id: 95, name: "Valencia CF" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: 1, away: 3 } } },
  { id: 2602, utcDate: "2026-08-23T19:00:00Z", status: "FINISHED", matchday: 2, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 77, name: "Athletic Club" }, score: { fullTime: { home: 2, away: 0 } } },
  { id: 2603, utcDate: "2026-08-30T17:00:00Z", status: "FINISHED", matchday: 3, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 250, name: "Real Valladolid" }, score: { fullTime: { home: 5, away: 0 } } },
  { id: 2604, utcDate: "2026-09-13T19:00:00Z", status: "FINISHED", matchday: 4, competition: { name: "La Liga EA Sports" }, venue: "Estadi Montilivi", homeTeam: { id: 298, name: "Girona FC" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: 1, away: 4 } } },
  { id: 2605, utcDate: "2026-09-17T19:00:00Z", status: "FINISHED", matchday: 1, competition: { name: "UEFA Champions League" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 524, name: "Paris Saint-Germain" }, score: { fullTime: { home: 3, away: 1 } } },
  { id: 2606, utcDate: "2026-09-20T16:30:00Z", status: "FINISHED", matchday: 5, competition: { name: "La Liga EA Sports" }, venue: "Estadio de la Cerámica", homeTeam: { id: 94, name: "Villarreal CF" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: 1, away: 5 } } },
  { id: 2607, utcDate: "2026-09-27T19:00:00Z", status: "FINISHED", matchday: 6, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 82, name: "Getafe CF" }, score: { fullTime: { home: 2, away: 0 } } },
  { id: 2608, utcDate: "2026-10-01T19:00:00Z", status: "FINISHED", matchday: 2, competition: { name: "UEFA Champions League" }, venue: "Allianz Arena", homeTeam: { id: 5, name: "FC Bayern München" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: 1, away: 2 } } },
  { id: 2609, utcDate: "2026-10-04T19:00:00Z", status: "FINISHED", matchday: 7, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 559, name: "Sevilla FC" }, score: { fullTime: { home: 4, away: 1 } } },
  { id: 2610, utcDate: "2026-10-18T19:00:00Z", status: "FINISHED", matchday: 8, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 86, name: "Real Madrid CF" }, score: { fullTime: { home: 3, away: 1 } } },
  { id: 2611, utcDate: "2026-10-21T19:00:00Z", status: "IN_PLAY", minute: "78'", matchday: 3, competition: { name: "UEFA Champions League" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 65, name: "Manchester City" }, score: { fullTime: { home: 2, away: 1 } } },
  { id: 2612, utcDate: "2026-10-25T19:00:00Z", status: "SCHEDULED", matchday: 9, competition: { name: "La Liga EA Sports" }, venue: "Reale Arena", homeTeam: { id: 92, name: "Real Sociedad" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: null, away: null } } },
  { id: 2613, utcDate: "2026-11-01T17:30:00Z", status: "SCHEDULED", matchday: 10, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 80, name: "RCD Espanyol" }, score: { fullTime: { home: null, away: null } } },
  { id: 2614, utcDate: "2026-11-04T20:00:00Z", status: "SCHEDULED", matchday: 4, competition: { name: "UEFA Champions League" }, venue: "San Siro", homeTeam: { id: 108, name: "FC Internazionale" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: null, away: null } } },
  { id: 2615, utcDate: "2026-11-08T20:00:00Z", status: "SCHEDULED", matchday: 11, competition: { name: "La Liga EA Sports" }, venue: "Balaídos", homeTeam: { id: 558, name: "RC Celta de Vigo" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: null, away: null } } },
  { id: 2616, utcDate: "2026-11-22T20:00:00Z", status: "SCHEDULED", matchday: 12, competition: { name: "La Liga EA Sports" }, venue: "Spotify Camp Nou", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 78, name: "Atlético de Madrid" }, score: { fullTime: { home: null, away: null } } },
  { id: 2617, utcDate: "2026-12-06T20:00:00Z", status: "SCHEDULED", matchday: 15, competition: { name: "La Liga EA Sports" }, venue: "Benito Villamarín", homeTeam: { id: 90, name: "Real Betis" }, awayTeam: { id: 81, name: "FC Barcelona" }, score: { fullTime: { home: null, away: null } } },
  { id: 2618, utcDate: "2027-01-10T20:00:00Z", status: "SCHEDULED", matchday: 1, competition: { name: "Supercopa de España" }, venue: "King Abdullah Sports City", homeTeam: { id: 81, name: "FC Barcelona" }, awayTeam: { id: 77, name: "Athletic Club" }, score: { fullTime: { home: null, away: null } } }
];

// ==========================================
// 3. БАЗА LA MASIA И BARÇA ATLÈTIC
// ==========================================
const LA_MASIA_DATABASE = {
  teamInfo: {
    name: "Barça Atlètic & Juvenil A",
    league: "Primera Federación (Группа 1) / UEFA Youth League",
    stadium: "Estadi Johan Cruyff (6,000 зрителей)",
    headCoach: "Альберт Санчес",
    tacticalSystem: "4-3-3 Cruyffismo / Positional Play",
    academyDirector: "Хосе Рамон Алекanko"
  },
  players: [
    { id: 301, name: "Марк Берналь", number: "22", pos: "CDM", age: 19, height: "191 см", foot: "Левая", marketValue: "€30.0M", potential: 93, stats: "11 матчей в первой команде, 93% точность передач", traits: "Эталонный опорник, чтение игры, длинный пас с левой ноги", scoutingReport: "Основной преемник Серхио Бускетса в системе Ханси Флика." },
    { id: 302, name: "Гилье Фернандес", number: "16", pos: "CM / CAM", age: 18, height: "181 см", foot: "Правая", marketValue: "€12.0M", potential: 92, stats: "9 голов, 6 ассистов за Barça Atlètic", traits: "Мощный проход через центр, удар из-за штрафной, физическая мощь", scoutingReport: "Самый результативный полузащитник резервной команды, регулярно тренируется с основой." },
    { id: 303, name: "Тони Фернандес", number: "19", pos: "RW / SS", age: 18, height: "176 см", foot: "Левая", marketValue: "€10.0M", potential: 91, stats: "11 голов, 7 ассистов в сезоне", traits: "Тонкий дриблинг, нестандартные решения в штрафной, исполнение стандартов", scoutingReport: "Обладает уникальной техникой удара и креативом между линиями." },
    { id: 304, name: "Ким Джуньент", number: "8", pos: "CAM / CM", age: 19, height: "173 см", foot: "Правая", marketValue: "€5.0M", potential: 89, stats: "6 голов, 9 ассистов, 91% точных передач", traits: "Контроль темпа, развороты на 360 градусов, скрытые пасы", scoutingReport: "Классический центральный полузащитник школы Ла Масии." },
    { id: 305, name: "Андрес Куэнка", number: "4", pos: "CB", age: 19, height: "185 см", foot: "Левая", marketValue: "€4.5M", potential: 88, stats: "20 матчей, 92% точных пасов, 68% выигранных дуэлей", traits: "Левоногий центральный защитник, продвигающий пас, высокая линия", scoutingReport: "Идеальный профиль для игры в паре с Пау Кубарси." },
    { id: 306, name: "Унаи Эрнандес", number: "10", pos: "CM / LW", age: 21, height: "176 см", foot: "Правая", marketValue: "€4.0M", potential: 86, stats: "10 голов, 6 ассистов (Капитан Barça Atlètic)", traits: "Лидерские качества, штрафные удары, дриблинг на скорости", scoutingReport: "Готовый игрок для ротации атакующей линии." },
    { id: 307, name: "Ландри Фарре", number: "2", pos: "RB / CB", age: 19, height: "182 см", foot: "Правая", marketValue: "€3.5M", potential: 87, stats: "18 матчей, 3 ассиста, 74% успешных отборов", traits: "Физический атлетизм, игра 1-в-1 против быстрых вингеров", scoutingReport: "Универсальный защитник по типу Жюля Кунде." },
    { id: 308, name: "Диего Кочен", number: "1", pos: "GK", age: 20, height: "188 см", foot: "Правая", marketValue: "€3.0M", potential: 88, stats: "16 матчей, 8 сухих игр, 77% отраженных ударов", traits: "Взрывная реакция, короткий и средний пас под давлением", scoutingReport: "Перспективный вратарь с опытом сборов в первой команде." },
    { id: 309, name: "Педро Родригес (Дро)", number: "14", pos: "CM", age: 18, height: "178 см", foot: "Правая", marketValue: "€2.5M", potential: 87, stats: "5 голов, 7 ассистов в Юношеской лиге УЕФА", traits: "Видение поля, продвижение мяча между линиями", scoutingReport: "Лидер полузащиты Juvenil A." },
    { id: 310, name: "Оскар Гистау", number: "9", pos: "ST", age: 18, height: "184 см", foot: "Правая", marketValue: "€2.8M", potential: 88, stats: "14 голов в 19 матчах", traits: "Классический центрфорвард, игра на опережение, удар головой", scoutingReport: "Лучший бомбардир академии в текущем сезоне." }
  ]
};

// ==========================================
// 4. ПОЛНАЯ ФИНАНСОВАЯ БАЗА CAPOLOGY & FFP (ВСЕ ИГРОКИ)
// ==========================================
const FINANCIAL_DATABASE = {
  currency: "EUR",
  season: "2026/2027",
  financialSummary: {
    totalYearlyWageBillGross: "€214,800,000",
    totalYearlyWageBillNet: "€107,400,000",
    averageWeeklySalary: "€147,527",
    squadMarketValuation: "€1,227,100,000",
    laLigaSalaryCapLimit: "€468,200,000",
    ffpRuleStatus: "Правило 1:1 активно (Полное соответствие FFP)",
    stadiumFinancingDebt: "€1,450,000,000 (Espai Barça / Доходность €340M/год)"
  },
  playerContracts: [
    { name: "Френки де Йонг", pos: "CM", grossYearly: "€19,000,000", netYearly: "€9,500,000", grossWeekly: "€365,385", marketVal: "€35.0M", clause: "€400M", contractEnd: "2028", ffpAmortization: "€8,500,000/год" },
    { name: "Ламин Ямаль", pos: "RW", grossYearly: "€16,670,000", netYearly: "€8,335,000", grossWeekly: "€320,576", marketVal: "€220.0M", clause: "€1,000M", contractEnd: "2031", ffpAmortization: "€0 (Воспитанник La Masia)" },
    { name: "Педри", pos: "CM", grossYearly: "€14,500,000", netYearly: "€7,250,000", grossWeekly: "€278,846", marketVal: "€150.0M", clause: "€1,000M", contractEnd: "2030", ffpAmortization: "€2,000,000/год" },
    { name: "Рафинья", pos: "LW", grossYearly: "€14,000,000", netYearly: "€7,000,000", grossWeekly: "€269,230", marketVal: "€70.0M", clause: "€1,000M", contractEnd: "2028", ffpAmortization: "€11,600,000/год" },
    { name: "Родри", pos: "CDM", grossYearly: "€14,000,000", netYearly: "€7,000,000", grossWeekly: "€269,230", marketVal: "€55.0M", clause: "€500M", contractEnd: "2029", ffpAmortization: "€12,000,000/год" },
    { name: "Жюль Кунде", pos: "RB", grossYearly: "€13,550,000", netYearly: "€6,775,000", grossWeekly: "€260,577", marketVal: "€60.0M", clause: "€1,000M", contractEnd: "2027", ffpAmortization: "€10,000,000/год" },
    { name: "Энтони Гордон", pos: "LW", grossYearly: "€11,200,000", netYearly: "€5,600,000", grossWeekly: "€215,384", marketVal: "€80.0M", clause: "€500M", contractEnd: "2030", ffpAmortization: "€13,000,000/год" },
    { name: "Габриэль Жезус", pos: "ST", grossYearly: "€10,500,000", netYearly: "€5,250,000", grossWeekly: "€201,923", marketVal: "€17.0M", clause: "€300M", contractEnd: "2028", ffpAmortization: "€5,500,000/год" },
    { name: "Дани Ольмо", pos: "CAM", grossYearly: "€9,380,000", netYearly: "€4,690,000", grossWeekly: "€180,385", marketVal: "€60.0M", clause: "€500M", contractEnd: "2030", ffpAmortization: "€9,100,000/год" },
    { name: "Андреас Кристенсен", pos: "CB", grossYearly: "€9,000,000", netYearly: "€4,500,000", grossWeekly: "€173,077", marketVal: "€8.0M", clause: "€500M", contractEnd: "2027", ffpAmortization: "€0 (Свободный агент)" },
    { name: "Пау Кубарси", pos: "CB", grossYearly: "€8,000,000", netYearly: "€4,000,000", grossWeekly: "€153,846", marketVal: "€100.0M", clause: "€1,000M", contractEnd: "2029", ffpAmortization: "€0 (Воспитанник La Masia)" },
    { name: "Гави", pos: "CM", grossYearly: "€8,000,000", netYearly: "€4,000,000", grossWeekly: "€153,846", marketVal: "€30.0M", clause: "€1,000M", contractEnd: "2028", ffpAmortization: "€0 (Воспитанник La Masia)" },
    { name: "Карим Адейеми", pos: "LW", grossYearly: "€7,500,000", netYearly: "€3,750,000", grossWeekly: "€144,230", marketVal: "€40.0M", clause: "€400M", contractEnd: "2029", ffpAmortization: "€7,000,000/год" },
    { name: "Фермин Лопес", pos: "CAM", grossYearly: "€6,800,000", netYearly: "€3,400,000", grossWeekly: "€130,769", marketVal: "€100.0M", clause: "€500M", contractEnd: "2029", ffpAmortization: "€0 (Воспитанник La Masia)" },
    { name: "Алехандро Бальде", pos: "LB", grossYearly: "€6,500,000", netYearly: "€3,250,000", grossWeekly: "€125,000", marketVal: "€50.0M", clause: "€1,000M", contractEnd: "2028", ffpAmortization: "€0 (Воспитанник La Masia)" },
    { name: "Жоан Гарсия", pos: "GK", grossYearly: "€6,000,000", netYearly: "€3,000,000", grossWeekly: "€115,384", marketVal: "€45.0M", clause: "€400M", contractEnd: "2031", ffpAmortization: "€5,000,000/год" },
    { name: "Эрик Гарсия", pos: "CB", grossYearly: "€6,000,000", netYearly: "€3,000,000", grossWeekly: "€115,384", marketVal: "€40.0M", clause: "€400M", contractEnd: "2028", ffpAmortization: "€0 (Свободный агент)" },
    { name: "Жуан Канселу", pos: "RB", grossYearly: "€5,500,000", netYearly: "€2,750,000", grossWeekly: "€105,769", marketVal: "€8.0M", clause: "€150M", contractEnd: "2027", ffpAmortization: "€3,000,000/год" },
    { name: "Марк Берналь", pos: "CDM", grossYearly: "€3,500,000", netYearly: "€1,750,000", grossWeekly: "€67,307", marketVal: "€30.0M", clause: "€500M", contractEnd: "2029", ffpAmortization: "€0 (Воспитанник La Masia)" },
    { name: "Руни Бардагжи", pos: "RW", grossYearly: "€3,200,000", netYearly: "€1,600,000", grossWeekly: "€61,538", marketVal: "€15.0M", clause: "€300M", contractEnd: "2029", ffpAmortization: "€2,000,000/год" },
    { name: "Войцех Щенсный", pos: "GK", grossYearly: "€3,000,000", netYearly: "€1,500,000", grossWeekly: "€57,692", marketVal: "€800K", clause: "€50M", contractEnd: "2027", ffpAmortization: "€0 (Свободный агент)" },
    { name: "Жерар Мартин", pos: "LB", grossYearly: "€2,800,000", netYearly: "€1,400,000", grossWeekly: "€53,846", marketVal: "€35.0M", clause: "€200M", contractEnd: "2028", ffpAmortization: "€0 (Воспитанник)" }
  ]
};

// ==========================================
// 5. ТАБЛИЦА ЛА ЛИГИ 2026/2027 (РЕЗЕРВ + LIVE)
// ==========================================
const FALLBACK_STANDINGS = [
  { position: 1, team: { id: 81, name: "FC Barcelona" }, playedGames: 8, won: 8, draw: 0, lost: 0, points: 24, goalsFor: 26, goalsAgainst: 4, goalDifference: 22 },
  { position: 2, team: { id: 86, name: "Real Madrid CF" }, playedGames: 8, won: 6, draw: 1, lost: 1, points: 19, goalsFor: 18, goalsAgainst: 7, goalDifference: 11 },
  { position: 3, team: { id: 78, name: "Atlético de Madrid" }, playedGames: 8, won: 5, draw: 2, lost: 1, points: 17, goalsFor: 15, goalsAgainst: 6, goalDifference: 9 },
  { position: 4, team: { id: 94, name: "Villarreal CF" }, playedGames: 8, won: 5, draw: 1, lost: 2, points: 16, goalsFor: 16, goalsAgainst: 12, goalDifference: 4 },
  { position: 5, team: { id: 77, name: "Athletic Club" }, playedGames: 8, won: 4, draw: 2, lost: 2, points: 14, goalsFor: 13, goalsAgainst: 9, goalDifference: 4 },
  { position: 6, team: { id: 90, name: "Real Betis" }, playedGames: 8, won: 4, draw: 1, lost: 3, points: 13, goalsFor: 11, goalsAgainst: 10, goalDifference: 1 },
  { position: 7, team: { id: 92, name: "Real Sociedad" }, playedGames: 8, won: 3, draw: 3, lost: 2, points: 12, goalsFor: 10, goalsAgainst: 8, goalDifference: 2 },
  { position: 8, team: { id: 298, name: "Girona FC" }, playedGames: 8, won: 3, draw: 2, lost: 3, points: 11, goalsFor: 12, goalsAgainst: 13, goalDifference: -1 }
];

// ==========================================
// 6. ГЕНЕРАТОР ДЕТАЛЬНОЙ SOFASCORE СТАТИСТИКИ ДЛЯ ЛЮБОГО МАТЧА
// ==========================================
function buildMatchDetails(matchId, allMatches) {
  const found = allMatches.find(m => String(m.id) === String(matchId)) || BASE_MATCHES_2026_2027[9];
  const isBarcaHome = found.homeTeam?.id === 81 || (found.homeTeam?.name || '').includes('Barcelona');
  const hScore = found.score?.fullTime?.home ?? (found.status === 'SCHEDULED' ? 0 : 3);
  const aScore = found.score?.fullTime?.away ?? (found.status === 'SCHEDULED' ? 0 : 1);

  return {
    id: found.id,
    season: "2026/2027",
    competition: found.competition?.name || "La Liga EA Sports",
    utcDate: found.utcDate,
    status: found.status,
    minute: found.minute || (found.status === 'FINISHED' ? '90+4\'' : 'Превью'),
    venue: found.venue || (isBarcaHome ? "Spotify Camp Nou (68,000)" : "Стадион соперника"),
    referee: "Хесус Хиль Мансано (Испания)",
    homeTeam: found.homeTeam,
    awayTeam: found.awayTeam,
    score: {
      fullTime: { home: hScore, away: aScore }
    },
    teams: {
      home: { name: found.homeTeam?.name || "FC Barcelona", score: hScore, xG: isBarcaHome ? "2.94" : "0.88" },
      away: { name: found.awayTeam?.name || "Соперник", score: aScore, xG: isBarcaHome ? "0.88" : "2.94" }
    },
    goals: found.status === 'SCHEDULED' ? [] : [
      { minute: "16'", player: "Ламин Ямаль", assist: "Педри", team: "FC Barcelona", score: isBarcaHome ? "1 - 0" : "0 - 1", detail: "Обводящий удар с левой в дальний угол" },
      { minute: "39'", player: "Габриэль Жезус", assist: "Рафинья", team: "FC Barcelona", score: isBarcaHome ? "2 - 0" : "0 - 2", detail: "Замыкание прострела из вратарской" },
      { minute: "61'", player: "Игрок соперника", assist: "Стандарт", team: isBarcaHome ? found.awayTeam?.name : found.homeTeam?.name, score: isBarcaHome ? "2 - 1" : "1 - 2", detail: "Удар после углового" },
      { minute: "74'", player: "Замена: Фермин Лопес ↔ Дани Ольмо", assist: "Тактическая", team: "FC Barcelona", score: "Замена", detail: "Усиление прессинга" },
      { minute: "85'", player: "Рафинья", assist: "Ламин Ямаль", team: "FC Barcelona", score: `${hScore} - ${aScore}`, detail: "Выход один на один после разрезающего паса" }
    ],
    playerRatings: [
      { name: "Ламин Ямаль", number: 10, pos: "RW", rating: "9.3", isMotm: true, stats: "1 гол, 1 ассист • 7/9 дриблинг • 4 ключевых паса • xG 0.78" },
      { name: "Рафинья", number: 11, pos: "LW", rating: "8.9", isMotm: false, stats: "1 гол, 1 ассист • 11.9 км пробега • 3 удара в створ • xA 0.65" },
      { name: "Педри", number: 8, pos: "CM", rating: "8.7", isMotm: false, stats: "1 ассист • 94% точных передач (78/83) • 5 ключевых пасов • 8 возвратов" },
      { name: "Пау Кубарси", number: 5, pos: "CB", rating: "8.2", isMotm: false, stats: "96% точных пасов • 7/8 выигранных дуэлей • 5 перехватов • 11 длинных передач" },
      { name: "Габриэль Жезус", number: 9, pos: "ST", rating: "8.0", isMotm: false, stats: "1 гол • 3 удара в створ • 6 прессинг-действий в чужой штрафной" },
      { name: "Жоан Гарсия", number: 1, pos: "GK", rating: "7.9", isMotm: false, stats: "4 сейва (2 из штрафной) • +1.12 предотвращенных xG • 91% точность пасов" },
      { name: "Жюль Кунде", number: 23, pos: "RB", rating: "7.8", isMotm: false, stats: "5 отборов • 100% выигранных верховых дуэлей • 2 созданных момента" },
      { name: "Френки де Йонг", number: 21, pos: "CM", rating: "7.7", isMotm: false, stats: "95% точность передач • 4 успешных прохода на дриблинге" },
      { name: "Дани Ольмо", number: 20, pos: "CAM", rating: "7.5", isMotm: false, stats: "74 минуты на поле • 2 удара в створ • 3 ключевых паса" },
      { name: "Алехандро Бальде", number: 3, pos: "LB", rating: "7.5", isMotm: false, stats: "Топ-скорость 35.4 км/ч • 4 успешных кросса • 3 перехвата" },
      { name: "Эрик Гарсия", number: 24, pos: "CB", rating: "7.4", isMotm: false, stats: "93% точных пасов • 4 выноса • 3 перехвата в высокой линии" },
      { name: "Фермин Лопес (Замена)", number: 7, pos: "CAM", rating: "7.2", isMotm: false, stats: "16 минут • 1 удар в штангу • 2 отбора в прессинге" }
    ],
    stats: {
      xG: { home: isBarcaHome ? "2.94" : "0.88", away: isBarcaHome ? "0.88" : "2.94" },
      possession: { home: isBarcaHome ? "65%" : "35%", away: isBarcaHome ? "35%" : "65%" },
      totalShots: { home: isBarcaHome ? "19" : "7", away: isBarcaHome ? "7" : "19" },
      shotsOnTarget: { home: isBarcaHome ? "10" : "3", away: isBarcaHome ? "3" : "10" },
      bigChances: { home: isBarcaHome ? "6" : "1", away: isBarcaHome ? "1" : "6" },
      passes: { home: isBarcaHome ? "648 (92%)" : "340 (83%)", away: isBarcaHome ? "340 (83%)" : "648 (92%)" },
      corners: { home: isBarcaHome ? "8" : "3", away: isBarcaHome ? "3" : "8" },
      tackles: { home: isBarcaHome ? "18" : "12", away: isBarcaHome ? "12" : "18" },
      fouls: { home: isBarcaHome ? "9" : "14", away: isBarcaHome ? "14" : "9" },
      yellowCards: { home: isBarcaHome ? "1" : "3", away: isBarcaHome ? "3" : "1" }
    }
  };
}

// ==========================================
// 7. КЭШ И СИНХРОНИЗАЦИЯ МАТЧЕЙ
// ==========================================
let cachedMatches = [...BASE_MATCHES_2026_2027];
let lastFetchTime = 0;

async function getMatchesSynced() {
  const now = Date.now();
  if (now - lastFetchTime < 30000 && cachedMatches.length > 0) {
    return cachedMatches;
  }

  try {
    const response = await axios.get(
      `https://api.football-data.org/v4/teams/${BARCA_TEAM_ID}/matches`,
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY }, timeout: 5000 }
    );
    if (response.data && Array.isArray(response.data.matches) && response.data.matches.length > 0) {
      const apiMatches = response.data.matches;
      const combined = [...BASE_MATCHES_2026_2027];
      apiMatches.forEach(am => {
        if (!combined.some(bm => String(bm.id) === String(am.id))) {
          combined.push(am);
        }
      });
      combined.sort((a, b) => new Date(a.utcDate) - new Date(b.utcDate));
      cachedMatches = combined;
    }
    lastFetchTime = now;
  } catch (err) {
    console.log('[Sync Info] Используется встроенный календарь сезона 2026/2027');
  }
  return cachedMatches;
}

// ==========================================
// 8. МАРШРУТЫ API
// ==========================================
app.get('/', (req, res) => {
  res.send(`
    <div style="font-family:sans-serif;background:#0a0b10;color:#fff;padding:40px;min-height:100vh;">
      <h1 style="color:#004D98;">🔵🔴 Culés Hub — Ultimate Server 2026/2027</h1>
      <p style="color:#4ade80;">Все модули активны и синхронизированы с фронтендом!</p>
      <ul>
        <li><a style="color:#FFCC00" href="/api/matches">/api/matches</a> — Полный календарь + LIVE</li>
        <li><a style="color:#FFCC00" href="/api/matches/2610">/api/matches/2610</a> — Детали Эль-Класико SofaScore</li>
        <li><a style="color:#FFCC00" href="/api/squad">/api/squad</a> — Полный состав и резерв 26/27 (28 игроков)</li>
        <li><a style="color:#FFCC00" href="/api/masia">/api/masia</a> — Вся академия La Masia</li>
        <li><a style="color:#FFCC00" href="/api/finance">/api/finance</a> — Финансы и зарплаты всех игроков</li>
        <li><a style="color:#FFCC00" href="/api/standings">/api/standings</a> — Таблица Ла Лиги</li>
      </ul>
    </div>
  `);
});

app.get('/api/squad', (req, res) => res.json(SQUAD_2026_2027));

app.get('/api/matches', async (req, res) => {
  const matches = await getMatchesSynced();
  res.json(matches);
});

app.get('/api/matches/:id', async (req, res) => {
  const matches = await getMatchesSynced();
  const details = buildMatchDetails(req.params.id, matches);
  res.json(details);
});

app.get('/api/masia', (req, res) => res.json(LA_MASIA_DATABASE));

app.get('/api/finance', (req, res) => res.json(FINANCIAL_DATABASE));

app.get('/api/standings', async (req, res) => {
  try {
    const response = await axios.get(
      'https://api.football-data.org/v4/competitions/PD/standings',
      { headers: { 'X-Auth-Token': FOOTBALL_API_KEY }, timeout: 5000 }
    );
    if (response.data?.standings?.[0]?.table) {
      return res.json(response.data.standings[0].table);
    }
  } catch (_) {}
  res.json(FALLBACK_STANDINGS);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Culés Hub 26/27 Server running on port ${PORT}`);
});
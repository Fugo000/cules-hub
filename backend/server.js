const express = require('express');
const cors = require('cors');

const app = express();

// Разрешаем CORS для запросов с GitHub Pages и локального окружения
app.use(cors());
app.use(express.json());

// 1. Эндпоинт Матч-Центра
app.get('/api/match/latest', (req, res) => {
    res.json({
        latestMatch: {
            round: "Ла Лига • Тур 7",
            stadium: "Рамон Санчес Писхуан",
            homeTeam: { name: "Севилья", score: 1 },
            awayTeam: { name: "Барселона", score: 3 },
            sofascoreRatings: [
                { name: "Рафинья", pos: "ПВ", rating: 9.6, isMotm: true },
                { name: "Ламин Ямаль", pos: "ПВ", rating: 8.8 },
                { name: "Педри", pos: "ЦП", rating: 8.2 }
            ]
        },
        upcomingMatches: [
            { round: "Ла Лига • Тур 8", opponent: "Хетафе", venue: "Камп Ноу", date: "10.10.2026, 19:30" },
            { round: "ЛЧ • Тур 2", opponent: "Галатасарай", venue: "RAMS Park", date: "13.10.2026, 22:00" }
        ]
    });
});

// 2. Эндпоинт La Masia & Barça Atlètic
app.get('/api/masia', (req, res) => {
    res.json({
        teamInfo: {
            name: "Barça Atlètic",
            league: "Primera Federación - Group 1",
            stadium: "Estadi Johan Cruyff"
        },
        players: [
            { number: 1, name: "Eder Aller", pos: "ВР", age: 19, marketValue: "€1.2M", potential: 87, stats: "6 сухих матчей" },
            { number: 2, name: "Landry Farré", pos: "ПЗ", age: 19, marketValue: "€1.8M", potential: 88, stats: "14 отборов" },
            { number: 10, name: "Ebrima Tunkara", pos: "ЦАП", age: 17, marketValue: "€3.0M", potential: 93, stats: "4 гола, 2 ассиста" },
            { number: 11, name: "Shane Kluivert", pos: "ЛВ", age: 19, marketValue: "€2.8M", potential: 91, stats: "5 голов" }
        ]
    });
});

// 3. Эндпоинт Финансов и ФФП
app.get('/api/transfers-and-finance', (req, res) => {
    res.json({
        financialMetrics: {
            totalYearlyWageBill: "€263.8M",
            squadValuationTotal: "€1,180.0M",
            laLigaCapLimit: "€426.0M",
            ruleStatus: "Правило 1:1 соблюдено"
        },
        squadFinancials: [
            { id: 19, name: "Lamine Yamal", pos: "ПВ", grossYearly: "€16.70M", grossWeekly: "€321K", marketVal: "€180.0M", clause: "€1,000M", contractEnd: "2031", age: 19, foot: "Левая", height: "180 см", ffpAmort: "€0.0M", stats: "22 матча, 12 голов", traits: "Феноменальный дриблинг" },
            { id: 8, name: "Pedri", pos: "ЦП", grossYearly: "€12.50M", grossWeekly: "€240K", marketVal: "€100.0M", clause: "€1,000M", contractEnd: "2030", age: 23, foot: "Правая", height: "174 см", ffpAmort: "€4.0M/год", stats: "20 матчей, 5 голов", traits: "Видение поля" }
        ]
    });
});

// Считываем порт от облачного хостинга (Render) или ставим 3000 по умолчанию
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

// Ваш API токен от football-data.org
const FOOTBALL_API_KEY = process.env.FOOTBALL_API_KEY || '136b36f3434747f3901037536999125d'; 
const BARCA_TEAM_ID = 81; 

// Тестовый ендпоинт
app.get('/api', (req, res) => {
  res.json({ message: 'Culés Hub API is running!' });
});

// Ендпоинт для матчей
app.get('/api/matches', async (req, res) => {
  try {
    const response = await axios.get(
      `https://api.football-data.org/v4/teams/${BARCA_TEAM_ID}/matches?limit=10`,
      {
        headers: { 'X-Auth-Token': FOOTBALL_API_KEY }
      }
    );
    res.json(response.data.matches);
  } catch (error) {
    console.error('Error fetching matches:', error.response?.data || error.message);
    res.status(500).json({ 
      error: 'Не удалось загрузить данные матчей',
      details: error.response?.data?.message || error.message 
    });
  }
});

// Ендпоинт для турнирной таблицы Ла Лиги
app.get('/api/standings', async (req, res) => {
  try {
    const response = await axios.get(
      'https://api.football-data.org/v4/competitions/PD/standings',
      {
        headers: { 'X-Auth-Token': FOOTBALL_API_KEY }
      }
    );
    res.json(response.data.standings[0].table);
  } catch (error) {
    console.error('Error fetching standings:', error.response?.data || error.message);
    res.status(500).json({ error: 'Не удалось загрузить турнирную таблицу' });
  }
});

// Ендпоинт для состава Barça Atlètic и La Masia
app.get('/api/masia', (req, res) => {
  res.json({
    teamInfo: {
      name: 'Barça Atlètic',
      league: 'Primera Federación',
      stadium: 'Estadi Johan Cruyff'
    },
    players: [
      { name: 'Unai Hernández', number: '10', pos: 'CM', age: 19, stats: '5 голов, 3 ассиста', marketValue: '€1.5M', potential: '84' },
      { name: 'Marc Bernal', number: '28', pos: 'CDM', age: 17, stats: 'Основной состав', marketValue: '€5.0M', potential: '89' },
      { name: 'Cuenca', number: '4', pos: 'CB', age: 17, stats: '12 матчей', marketValue: '€800K', potential: '83' },
      { name: 'Quim Junyent', number: '8', pos: 'CAM', age: 17, stats: '4 гола', marketValue: '€1.0M', potential: '86' }
    ]
  });
});

// Ендпоинт для финансов, зарплат и лимитов FFP
app.get('/api/finance', (req, res) => {
  res.json({
    financialMetrics: {
      totalYearlyWageBill: '€208.5M',
      squadValuationTotal: '€950.0M',
      laLigaCapLimit: '€426.0M',
      ruleStatus: 'Правило 1:1 восстановлено'
    },
    squadFinancials: [
      {
        id: '9',
        name: 'Роберт Левандовски',
        pos: 'ST',
        grossYearly: '€33.3M',
        grossWeekly: '€640K',
        marketVal: '€15.0M',
        age: 36,
        foot: 'Правая',
        height: '185 см',
        clause: '€500M',
        contractEnd: '2026',
        ffpAmort: '€11.2M/год',
        stats: '19 голов, 3 ассиста',
        traits: 'Завершение, Выбор позиции'
      },
      {
        id: '19',
        name: 'Ламин Ямаль',
        pos: 'RW',
        grossYearly: '€1.67M',
        grossWeekly: '€32K',
        marketVal: '€150.0M',
        age: 17,
        foot: 'Левая',
        height: '180 см',
        clause: '€1.000M',
        contractEnd: '2026 (Продление до 2031)',
        ffpAmort: '€0M (Воспитанник)',
        stats: '8 голов, 11 ассистов',
        traits: 'Дриблинг, Видение поля'
      },
      {
        id: '8',
        name: 'Педри',
        pos: 'CM',
        grossYearly: '€9.38M',
        grossWeekly: '€180K',
        marketVal: '€80.0M',
        age: 21,
        foot: 'Правая',
        height: '174 см',
        clause: '€1.000M',
        contractEnd: '2026',
        ffpAmort: '€5.0M/год',
        stats: '4 гола, 5 ассистов',
        traits: 'Плеймейкинг, Контроль темпа'
      }
    ]
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
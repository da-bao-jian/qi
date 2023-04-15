require('dotenv').config();
const express = require('express');
const WebSocket = require('ws');
const { Pool } = require('pg');

const app = express();
const server = app.listen(3000, () => console.log('Listening on port 3000'));
const wss = new WebSocket.Server({ server });

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

wss.on('connection', async (ws) => {
  console.log('Client connected');

  const query = `
    SELECT * FROM messages
    WHERE deadline > NOW() AND executed = FALSE;
  `;

  try {
    const { rows } = await pool.query(query);

    ws.send(JSON.stringify(rows));
  } catch (error) {
    console.error(error);
    ws.send(JSON.stringify({ error: 'Failed to fetch messages' }));
  }

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

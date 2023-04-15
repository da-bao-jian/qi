const ws = new WebSocket('ws://localhost:3000');

ws.addEventListener('open', () => {
  console.log('Connected to WebSocket server');
});

ws.addEventListener('message', (event) => {
  const messages = JSON.parse(event.data);
  console.log('Received messages:', messages);
});

ws.addEventListener('close', () => {
  console.log('Disconnected from WebSocket server');
});

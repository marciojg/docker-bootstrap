
import express from 'express';

const server = express();
const port = 8080;

server.get('/', (req: any, res: any) => {
  const hello = {
    message: 'Hello World!',
    date: new Date().toLocaleDateString(),
  };
  res.json(hello);
});

server.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});

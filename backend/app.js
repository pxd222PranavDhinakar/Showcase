const express = require('express');
const app = express();
const port = 3000;  // You can choose any port that is free on your system

app.get('/api', (req, res) => {
    res.send('This is a response from the server.');
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});

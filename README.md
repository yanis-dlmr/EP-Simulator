# EP-Simulator

## How to run

Use ``npm start``

## How to dist setup.exe

Use ``npm run dist``
Before you have to change in sec/index.js the following lines :

``` js
mainWindow.loadFile(path.join(__dirname, '../interface/accueil.html'));
into
mainWindow.loadFile(path.join(__dirname, '../../interface/accueil.html'));

and

const pythonScriptPath = path.join(__dirname, '../server.py');
into
const pythonScriptPath = path.join(__dirname, '../../server.py');
```

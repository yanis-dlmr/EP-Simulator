# EP-Simulator

## In short

> **Note**
> This project is not finished, some content might be wrong and missing.

The main objective of this project is to set up an interface to manage simulations in Modern Fortran (f90). This allows us to modify the inputs, to run the simulations and to display the results in a dynamic way with Plotly.
These simulations were made within the framework of a Scientific Project to apply the Navier-Stockes equations.

This software uses the ElectronJs framework. The backend is realized with a local python server launched automatically.

## How to run

Use ``npm start``

## How to dist setup.exe

Use ``npm run dist``
Before you have to change in sec/index.js the following lines :

``` js
mainWindow.loadFile(path.join(__dirname, '../interface/accueil.html'));
```
into
``` js
mainWindow.loadFile(path.join(__dirname, '../../interface/accueil.html'));
```
and
``` js
const pythonScriptPath = path.join(__dirname, '../server.py');
```
into
``` js
const pythonScriptPath = path.join(__dirname, '../../server.py');
```

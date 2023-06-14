const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
var fs = require('fs')
require('electron-reload')(__dirname)

if (require('electron-squirrel-startup')) {
  app.quit();
}

const { spawn } = require('child_process');

let fastapiServer;

const createWindow = () => {
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    icon: path.join(__dirname, 'logo.png'),
    webPreferences: {
      nodeIntegration: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });
  mainWindow.setMenuBarVisibility(false);
  mainWindow.loadFile(path.join(__dirname, '../interface/accueil.html'));
  mainWindow.webContents.on('did-finish-load', () => {
    mainWindow.maximize();
  });
  //mainWindow.webContents.openDevTools();
};

app.whenReady().then(() => {

  const pythonScriptPath = path.join(__dirname, '../server.py');
  const pythonProcess = spawn('python', [pythonScriptPath]);

  //fastapiServer = spawn('uvicorn', ['server:app', '--port', '8000']);
  //fastapiServer = spawn('uvicorn', [path.join(__dirname, '../server:app'), '--port', '8000']);

  //fastapiServer.stdout.on('data', (data) => {
  //  console.log(`stdout: ${data}`);
  //});
  //
  //fastapiServer.stderr.on('data', (data) => {
  //  console.error(`stderr: ${data}`);
  //});
  //
  //fastapiServer.on('close', (code) => {
  //  console.log(`FastAPI server exited with code ${code}`);
  //});

  //const { PythonShell } = require('python-shell');
  //let pyshell = new PythonShell('server.py');

  //let python = spawn('python', [path.join(app.getAppPath(), '..', 'python_scripts/server.py')]);
  
  createWindow();


});

  //fastapiServer = spawn('uvicorn', [path.join(__dirname, '..', 'server.py:app'), '--port', '8000']);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

app.on('before-quit', () => {
  fastapiServer.kill();
});
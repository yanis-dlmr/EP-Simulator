from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import markdown2
import numpy as np
import os
import json
import subprocess
import uvicorn
import pandas as pd
import asyncio

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins = origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/hello")
async def root():
    return {"message" : "Hello World"}

@app.get("/loadHome")
async def root():
    file_path = 'Projet_scientifique/accueil.md'
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()
    except OSError as e:
        return {"error": f"Unable to read file: {str(e)}"}

    html = markdown2.markdown(text, "fenced-code-blocks")
    return {"html": html}



@app.get("/ping")
async def root():
    return {
        'data': os.path.abspath(__file__)
    }


@app.post("/loadMarkdown")
async def receive_post_request(data: dict):
    path = data.get('path')
    with open(path, 'r', encoding='utf-8') as file:
        text = file.read()
    html = markdown2.markdown(text, "fenced-code-blocks")
    return{
        "html": html
    }

@app.post("/saveData")
async def receive_post_request(data: dict):
    new_content = data.get('text')
    path = data.get('path')
    with open(path, "w") as f:
        f.write(new_content)
    response_data = {"message": "Requête POST reçue avec succès !"}
    return response_data

#@app.post("/runFortran")
#async def receive_post_request(data: dict):
#    path = data.get('path')
#    repertoire_initial = os.getcwd()
#    repertoire_parent = os.path.dirname(path)
#    os.chdir(repertoire_parent)
#    nom_fichier = os.path.basename(path)
#    os.system(f'gfortran {nom_fichier}')
#    os.system('a.exe')
#    os.chdir(repertoire_initial)
#    response_data = {"message": "Requête POST reçue avec succès !"}
#    return response_data

import multiprocessing
import time

def run_gfortran(path):
    repertoire_initial = os.getcwd()
    repertoire_parent = os.path.dirname(path)
    os.chdir(repertoire_parent)
    nom_fichier = os.path.basename(path)
    os.system(f'gfortran {nom_fichier}')
    os.system('a.exe')
    os.chdir(repertoire_initial)
    
def run_gfortran_parallel(path):
    repertoire_initial = os.getcwd()
    repertoire_parent = os.path.dirname(path)
    os.chdir(repertoire_parent)
    nom_fichier = os.path.basename(path)
    os.system(f'gfortran -fopenmp {nom_fichier} -o banane')
    time.sleep(5)
    os.system('banane.exe')
    os.chdir(repertoire_initial)

@app.post("/runFortran")
async def receive_post_request(data: dict):
    path = data.get('path')
    num_cores = multiprocessing.cpu_count()
    pool = multiprocessing.Pool(num_cores)
    results = pool.map(run_gfortran, [path])
    response_data = {"message": "Requête POST reçue avec succès !"}
    return response_data

@app.post("/runFortranParallel")
async def receive_post_request(data: dict):
    path = data.get('path')
    num_cores = multiprocessing.cpu_count()
    pool = multiprocessing.Pool(num_cores)
    results = pool.map(run_gfortran_parallel, [path])
    response_data = {"message": "Requête POST reçue avec succès !"}
    return response_data


@app.get("/data1")
async def root():
    # solution_finale
    with open('Projet_scientifique/etape_1/resultats/solution_finale.dat', 'r') as f:
        data = f.read().split('#')
    tableaux1 = [[x for x in t.strip().split('\n') if x.strip()] for t in data]
    tableaux1 = tableaux1[ : -1]
    # solution_analytique
    with open('Projet_scientifique/etape_1/resultats/solution_analytique.dat', 'r') as f:
        data = f.read().split('#')
    tableaux2 = [[x for x in t.strip().split('\n') if x.strip()] for t in data]
    tableaux2 = tableaux2[ : -1]
    # fusion
    tableaux =  [ [x,y] for x, y in zip(tableaux1, tableaux2)]
    return {
        'x' : tableaux1[0],
        'y' : tableaux[1:]
    }

@app.post("/data_2D_heatmap")
async def receive_post_request(data_input: dict):
    folderPath = data_input.get('path')
    filenames = [filename for filename in os.listdir(folderPath) if filename.endswith(".dat")]

    datas = []

    for idx, filename in enumerate(filenames):
        with open(os.path.join(folderPath, filename), "r") as f:
            f.readline()
            f.readline()
            f.readline()
            lines = f.readlines()

        data = np.zeros((len(lines), 3))
        
        try:
            champs = data_input.get('champs')
        except:
            champs = 2
        champsToCol = {
            'u': 2,
            'v': 3,
            'p': 4
        }
        col = champsToCol.get(champs)
        for i, line in enumerate(lines):
            values = line.strip().split()
            data[i, :] = [float(values[0]), float(values[1]), float(values[col])]

        datas.append(data.tolist())
    return {
        'datas': datas
    }

@app.post("/compare_data_1D")
async def receive_post_request(data_input: dict):
    folderPath = data_input.get('path2')
    filenames = [filename for filename in os.listdir(folderPath) if filename.endswith(".dat")]

    datas = []

    filename = filenames[-1]
    with open(os.path.join(folderPath, filename), "r") as f:
        f.readline()
        f.readline()
        f.readline()
        lines = f.readlines()
    
    
    sheetname = data_input.get('filename')
    filename = data_input.get('filename') + '.xlsx'

    data = {}
    data["values"] = np.zeros((int((len(lines))**0.5), 2))
    
    try:
        champs = data_input.get('champs')
    except:
        champs = 2
    champsToCol = {
        'x': 0,
        'y': 1,
        'u': 2,
        'v': 3,
        'p': 4
    }
    col = champsToCol.get(champs)
    
    if ('Y' in filename) :
        col_x = champsToCol.get('y')
        col_y = champsToCol.get('x')
    elif ('X' in filename):
        col_x = champsToCol.get('x')
        col_y = champsToCol.get('y')
    
    i = 0
    for line in lines:
        values = line.strip().split()
        if (float(values[col_x]) == 0.5):
            data["values"][i, :] = [float(values[col_y]), float(values[col])]
            i += 1
    data["name"] = "Données calculées"
    data["values"] = data["values"].tolist()

    datas.append(data)
    
    data = {}
    sheetname = data_input.get('filename')
    filename = data_input.get('filename') + '.xlsx'
    folderPath = data_input.get('path1')
    df1 = pd.read_excel (os.path.join(folderPath, filename), sheet_name=[sheetname])
    df1_1=df1[sheetname]
    
    data["values"] = np.zeros((1001, 2))
    
    champsToName = {
        'u': 'U:0',
        'v': 'U:1',
        'p': 'p',
        'x': 'Points:0',
        'y': 'Points:1'
    }
    col_name1 = champsToName.get(champs)
    values = df1_1[col_name1].values
    if ('X' in sheetname) :
        col_name2 = champsToName.get('y')
    elif ('Y' in sheetname):
        col_name2 = champsToName.get('x')
    x = df1_1[col_name2].values
    
    for i, value in enumerate(values):
        data["values"][i, :] = [float(x[i]), float(value)]
    data["name"] = "Données de références"
    data["values"] = data["values"].tolist()

    datas.append(data)
    
    return {
        'datas': datas
    }




@app.get("/data2")
async def root():
    # solution_finale
    with open('Projet_scientifique/etape_2/resultats/solution_finale.dat', 'r') as f:
        data = f.read().split('#')
    tableaux1 = [[x for x in t.strip().split('\n') if x.strip()] for t in data]
    tableaux1 = tableaux1[ : -1]
    # solution_analytique
    with open('Projet_scientifique/etape_2/resultats/solution_analytique.dat', 'r') as f:
        data = f.read().split('#')
    tableaux2 = [[x for x in t.strip().split('\n') if x.strip()] for t in data]
    tableaux2 = tableaux2[ : -1]
    # fusion
    tableaux =  [ [x,y] for x, y in zip(tableaux1, tableaux2)]
    return {
        'x' : tableaux1[0],
        'y' : tableaux[1:]
    }

async def main():
    config = uvicorn.Config("server:app", port=8000, log_level="info")
    server = uvicorn.Server(config)
    dir_path = os.path.dirname(os.path.abspath(__file__))
    os.chdir(dir_path)
    await server.serve()

if __name__ == "__main__":
    asyncio.run(main())
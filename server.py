from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import markdown2
import numpy as np
import os
import json
import subprocess
import uvicorn

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

def run_fortran(path):
    repertoire_initial = os.getcwd()
    repertoire_parent = os.path.dirname(path)
    os.chdir(repertoire_parent)
    nom_fichier = os.path.basename(path)
    os.system(f'gfortran {nom_fichier}')
    os.system('a.exe')
    os.chdir(repertoire_initial)

@app.post("/runFortran")
async def receive_post_request(data: dict):
    path = data.get('path')
    num_cores = multiprocessing.cpu_count()
    pool = multiprocessing.Pool(num_cores)
    results = pool.map(run_fortran, [path])
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

@app.get("/data_2D_heatmap")
async def root():
    foldername = "./Projet_scientifique/etape_3/resultats/"
    filenames = [filename for filename in os.listdir(foldername) if filename.endswith(".dat")]

    datas = []

    for idx, filename in enumerate(filenames):
        with open(os.path.join(foldername, filename), "r") as f:
            f.readline()
            f.readline()
            f.readline()
            lines = f.readlines()

        data = np.zeros((len(lines), 3))
        for i, line in enumerate(lines):
            values = line.strip().split()
            data[i, :] = [float(values[0]), float(values[1]), float(values[2])]

        datas.append(data.tolist())
    return {
        'datas': datas
    }


@app.get("/data_2D_heatmap_4")
async def root():
    foldername = "./Projet_scientifique/etape_4/resultats/"
    filenames = [filename for filename in os.listdir(foldername) if filename.endswith(".dat")]

    datas = []

    for idx, filename in enumerate(filenames):
        with open(os.path.join(foldername, filename), "r") as f:
            f.readline()
            f.readline()
            f.readline()
            lines = f.readlines()

        data = np.zeros((len(lines), 3))
        for i, line in enumerate(lines):
            values = line.strip().split()
            data[i, :] = [float(values[0]), float(values[1]), float(values[2])]

        datas.append(data.tolist())
    return {
        'datas': datas
    }

@app.get("/data_2D_heatmap_5")
async def root():
    foldername = "./Projet_scientifique/etape_5/resultats/"
    filenames = [filename for filename in os.listdir(foldername) if filename.endswith(".dat")]

    datas = []

    for idx, filename in enumerate(filenames):
        with open(os.path.join(foldername, filename), "r") as f:
            f.readline()
            f.readline()
            f.readline()
            lines = f.readlines()

        data = np.zeros((len(lines), 3))
        for i, line in enumerate(lines):
            values = line.strip().split()
            data[i, :] = [float(values[0]), float(values[1]), float(values[2])]

        datas.append(data.tolist())
    return {
        'datas': datas
    }

@app.get("/data_2D_heatmap_6")
async def root():
    foldername = "./Projet_scientifique/etape_6/resultats/"
    filenames = [filename for filename in os.listdir(foldername) if filename.endswith(".dat")]

    datas = []

    for idx, filename in enumerate(filenames):
        with open(os.path.join(foldername, filename), "r") as f:
            f.readline()
            f.readline()
            f.readline()
            lines = f.readlines()

        data = np.zeros((len(lines), 3))
        for i, line in enumerate(lines):
            values = line.strip().split()
            data[i, :] = [float(values[0]), float(values[1]), float(values[2])]

        datas.append(data.tolist())
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
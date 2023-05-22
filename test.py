import numpy as np
import pandas as pd
import os


def receive_post_request(data_input: dict):
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

    data = np.zeros((int((len(lines))**0.5), 2))
    
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
            data[i, :] = [float(values[col_y]), float(values[col])]
            i += 1


    datas.append(data.tolist())
    
    sheetname = data_input.get('filename')
    filename = data_input.get('filename') + '.xlsx'
    folderPath = data_input.get('path1')
    df1 = pd.read_excel (os.path.join(folderPath, filename), sheet_name=[sheetname])
    df1_1=df1[sheetname]
    
    data = np.zeros((1001, 2))
    
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
        data[i, :] = [float(x[i]), float(value)]

    datas.append(data.tolist())
    
    pomme = np.array(101)
    banane = np.array(101)
    print(len(datas[0]))
    print(len(datas[1]))
    print(datas[0][50])
    print(datas[1][50])
    
    pomme1 = [datas[1][i][0] for i in range(len(datas[1]))]
    banane1 = [datas[1][i][1] for i in range(len(datas[1]))]
    pomme0 = [datas[0][i][0] for i in range(len(datas[0]))]
    banane0 = [datas[0][i][1] for i in range(len(datas[0]))]
    import matplotlib.pyplot as plt
    plt.plot(pomme0, banane0)
    plt.plot(pomme1, banane1)
    plt.show()


data_input = {'champs' : 'p', 'filename': 'ligneY05', 'path1': 'Projet_scientifique/etape_7/','path2': 'Projet_scientifique/etape_7/resultats/'}

receive_post_request(data_input)
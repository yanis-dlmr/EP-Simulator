import numpy as np
import matplotlib.pyplot as plt
import os


with open('./Projet_scientifique/etape_2/resultats/solution_finale.dat', 'r') as f:
    data = f.read().split('#')
tableaux1 = [[x for x in t.strip().split('\n') if x.strip()] for t in data]
tableaux1 = np.array(tableaux1[ : -1]).astype(np.float64)

with open('./Projet_scientifique/etape_2/resultats/solution_analytique.dat', 'r') as f:
    data = f.read().split('#')
tableaux2 = [[x for x in t.strip().split('\n') if x.strip()] for t in data]
tableaux2 = np.array(tableaux2[ : -1]).astype(np.float64)

x = tableaux1[0]
solution_initiale = tableaux1[1]
solution_finale = tableaux1[-1]
solution_analytique = tableaux2[-1]

# Tracer le graphique
plt.plot(x, solution_initiale, marker= 'o', linestyle='-', color='black', label='solution_initiale')
plt.plot(x, solution_finale, marker= 'o', linestyle='-', color='red', label='solution_finale')
plt.plot(x, solution_analytique, linestyle='-', color='grey', label='solution_analytique')

# Ajouter une légende, une grille, afficher les labels puis le graph
plt.xlabel('x')
plt.ylabel('u')
plt.grid()
plt.legend()
plt.title('Etape 2')
plt.show()
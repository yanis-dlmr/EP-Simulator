import matplotlib.pyplot as plt

# Temps d'exécution séquentielle
sequential_time = 41.3279991

# Temps d'exécution parallèle
parallel_times = [42.1720009, 30.4220009, 30.2810001, 29.9220009, 22.3439999, 20.2500000, 19.5790005, 16.5620003]

# Nombre de threads
num_threads = [1, 2, 3, 4, 5, 6, 7, 8]

# Calcul du speed-up
speed_up = [sequential_time / t for t in parallel_times]

# Tracé du graphique
plt.plot(num_threads, speed_up, marker='o', linestyle='-', color='blue')
plt.xlabel('Nombre de threads')
plt.ylabel('Speed-up')
plt.title('Graphique de Speed-up')
plt.grid(True)
plt.show()

# Application du calcul parallèle et comparaison des temps d'execution :

### Normal :

* 1 thread : 41.3279991 s

### OpenMP :

* 1 thread : 42.1720009 s
* 2 thread : 30.4220009 s
* 3 thread : 30.2810001 s
* 4 thread : 29.9220009 s
* 5 thread : 22.3439999 s
* 6 thread : 20.2500000 s
* 7 thread : 19.5790005 s
* 8 thread : 16.5620003 s

### Soit le calcul de speed up suivant :

* 1 thread : Speed-up = 41.3279991 s / 42.1720009 s ≈ 0.9805
* 2 threads : Speed-up = 41.3279991 s / 30.4220009 s ≈ 1.3572
* 3 threads : Speed-up = 41.3279991 s / 30.2810001 s ≈ 1.3646
* 4 threads : Speed-up = 41.3279991 s / 29.9220009 s ≈ 1.3817
* 5 threads : Speed-up = 41.3279991 s / 22.3439999 s ≈ 1.8519
* 6 threads : Speed-up = 41.3279991 s / 20.2500000 s ≈ 2.0406
* 7 threads : Speed-up = 41.3279991 s / 19.5790005 s ≈ 2.1129
* 8 threads : Speed-up = 41.3279991 s / 16.5620003 s ≈ 2.4957

### Graph final

![Loutres trop belle](../pictures/speed_up.png)
# Etape 6 : Equation de Poisson en 2D

Cette étape 6 consiste à résoudre une équation de Poisson. Cette équation permettra d’évaluer la pression
dans les équations de Navier-Stokes 2D.

## Description

L’équation de Poisson s’écrit comme :
∂
2p
∂x2
+
∂
2p
∂y2
= b (1)
C’est une équation de Laplace avec un terme source ou un terme de droite non nul (ici b).

## Problème à résoudre

On souhaite résoudre l’équation (1) sur un domaine de taille 1.0 × 1.0 avec la condition initiale suivante :
p = 0 pour tout x, y (2)
et les conditions aux limites suivantes :
p = 1 en x = 0
p = 1 − 2 sinh(x) en y = 0
p = exp(y) − 2 sinh(1) en x = 1
p = exp(x) − 2 sinh(x) en y = 1
(3)
Le terme source b est :
b(x, y) = (x
2 + y
2
) exp(xy) − 2 sinh(x) (4)
Le domaine sera discrétisé avec un maillage homogène de 101 points dans chaque direction.
La résolution se fera avec un schéma centré d’ordre 2 pour les termes en dérivée seconde. Comme pour
l’étape précédente, il faut isoler le terme pi,j et résoudre de fa¸con itérative le système.
On demande dans ce problème d’arrˆeter le calcul dès qu’il est convergé, soit avant d’atteindre les 20000
itérations (nombre maximum). Pour cela on doit définir un critère d’arrˆet : la norme L2 de l’écart entre 2
itérations, qui s’écrit sous la forme
e
k =
vuut
1
NxNy
X
Nx
i=1
X
Ny
j=1

p
k+1
i,j − p
k
i,j 2
=



p
k+1 − p
k




p
2
NxNy
(5)
La solution est estimée convergée dès que e
k < 10−6
.
La solution analytique est de la forme :
p(x, y) = exp(xy) − 2 sinh(x)
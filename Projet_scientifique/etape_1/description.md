# Etape 1 : Convection linéaire 1D

L’objectif de cette première étape est de mettre en place le programme informatique (structure, routines principales) sur un problème numérique simple : la convection linéaire d’un scalaire dans un domaine 1D.

## Description
La convection linéaire consiste à résoudre un champ scalaire u(x, t) à une vitesse constante c suivant l’équation suivante :

```
∂u/∂t + c ∂u/∂x = 0
```

## Problème à résoudre
On souhaite résoudre l’équation (1) sur un domaine de taille [0; L] avec L = 1, dont la condition initiale est :

```
u(x, t = 0) = exp (- [(x-x_0)/δ])
```

avec x_0 = 0.2 et δ = 0.05 et les conditions aux limites sont :
u(x = 0, t) = 0 et u(x = L, t) = 0 . 

La vitesse de convection sera prise comme c = 1.0.
Le domaine sera discrétisé avec un maillage homogène de 201 points. La résolution se fera avec le schéma
d’Euler 1er ordre (progressif) en temps et le schéma upwind 1er ordre (régressif) en espace avec la condition
CFL = 0.5. Le résultat final attendu est au temps t_f = 0.5.
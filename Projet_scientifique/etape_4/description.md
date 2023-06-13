# Etape 4 : Equation de Burgers en 2D

Cette étape consiste à résoudre l’ensemble de la partie transport des équations de Navier-Stokes 2D.
L’équation de convection non-linéaire avec diffusion s’appelle l’équation de Burgers.

## Description
L’équation de Burgers 2D s’écrit :

```∂u/∂t + u ∂u/∂x + v ∂u/∂y = ν (∂^2 u/∂x^2 + ∂^2 u/∂y^2)```
```∂v/∂t + u ∂v/∂x + v ∂v/∂y = ν (∂^2 v/∂x^2 + ∂^2 v/∂y^2)```

## Problème à résoudre

On souhaite résoudre l’équation (1) sur un domaine de taille 2.0×2.0 avec les conditions initiales suivantes :

* ```u,v(x, t = 0) = 2.0``` pour 0.5 ≤ x,y ≤ 1
* ```u,v(x, t = 0) = 1.0``` pour partout ailleurs 

et les conditions aux limites suivantes :

* ```u = 1.0``` et ```v = 1.0``` pour ```x = 0.0 et x = 2.0 ; y = 0.0 et y = 2.0```

On prendra ν = 0.01.
Le domaine sera discrétisé avec un maillage homogène de 81 points dans chaque direction. La résolution se fera avec :

* le schéma d’Euler 1er ordre (progressif) en temps,
* le schéma upwind 1er ordre (régressif) en espace pour la convection avec la condition CFL = 0.2,
* le schéma centré d’ordre 2 pour la diffusion avec la condition de Fourier Fo = 0.1.

Le résultat final attendu est après 200 itérations.

# Etape 3 : Equation de convection-diffusion en 2D

L’objectif de cette étape est de transformer le problème 1D de l’étape 2 en problème 2D : la convection linéaire et la diffusion d’un scalaire dans un domaine 2D. De plus, on veut écrire les résultats dans un format visualisable avec le logiciel Paraview.

## Description
La convection linéaire et diffusion d’un champ scalaire u(x, y, t) à une vitesse constante c et coefficient de diffusion ν suit l’équation suivante en 2D :

```∂u/∂t + c ∂u/∂x + c ∂u/∂y = ν (∂^2 u/∂x^2) +  ν (∂^2 u/∂y^2)```

## Problème à résoudre

On souhaite résoudre l’équation (1) sur un domaine de taille L × L avec L = 2, dont la condition initiale est :

* ```u(x, t = 0) = 2``` pour 0.5 ≤ x ≤ 1 et 0.5 ≤ y ≤ 1

* ```u(x, t = 0) = 1``` pour partout ailleurs 

et les conditions aux limites suivantes :

* ```u(x = 0, y, t) = 1```  ```u(x = L, y, t) = 1``` ```u(x, y = 0, t) = 1``` ```u(x, y = L, t) = 1```

La vitesse de convection sera prise comme c = 1.0 et le coefficient de diffusion ν = 0.01.
Le domaine sera discrétisé avec un maillage homogène régulier de 81 × 81 points. La résolution se fera
avec :

* le schéma d’Euler 1er ordre (progressif) en temps,

* le schéma upwind 1er ordre (régressif) en espace avec la condition CFL = 0.1 pour la convection,

* le schéma centré d’ordre 2 pour la diffusion.

Le résultat final attendu est au temps tf = 0.5.
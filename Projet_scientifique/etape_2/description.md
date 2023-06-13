# Etape 2 : Convection linéaire + diffusion 1D

L’objectif de cette deuxième étape est d’ajouter le phénomène de diffusion par rapport à l’étape 1 : la convection linéaire et la diffusion d’un scalaire dans un domaine 1D.

## Description
La convection linéaire et diffusion d’un champ scalaire u(x, t) à une vitesse constante c et coefficient de diffusion ν suit l’équation suivante :

```∂u/∂t + c ∂u/∂x = ν (∂^2 u/∂x^2)``` (1)

## Problème à résoudre

On souhaite résoudre l’équation (1) sur un domaine de taille [0; L] avec L = 1, dont la condition initiale est :

```u(x, t = 0) = exp(−[(x − x0)/δ]^2)```

avec x0 = 0.2 et δ = 0.05 et les conditions aux limites sont :

```u(x = 0, t) = 0``` et ```u(x = L, t) = 0```

La vitesse de convection sera prise comme c = 1.0 et le coefficient de diffusion ν = 0.001.
Le domaine sera discrétisé avec un maillage homogène de 101 points. La résolution se fera avec :

* le schéma d’Euler 1er ordre (progressif) en temps,

* le schéma upwind 1er ordre (régressif) en espace avec la condition CFL = 0.5 pour la convection,

* le schéma centré d’ordre 2 pour la diffusion.

Le résultat final attendu est au temps t_f = 0.5.
La solution analytique est de la forme :

```u(x, t) = δ/√(2νt + δ^2) * exp((−(x − x0 − ct)/√ (2νt + δ^2))^2)```

## Problème rencontré

A partir d'un certains nombre de points nous constatons une instabilité.

<figure>
  <img
  src="../Projet_scientifique/etape_2/etape_2_601.gif"
  alt="...">
  <figcaption>Simulation pour n = 601</figcaption>
</figure>

Nous avons résolu ce problème en ajoutant une autre condition en plus du CFL qui est celle de Fourrier, en prenant comme valeur 0.1. Avec cette optimisation le problème a été résolu.

<figure>
  <img
  src="../Projet_scientifique/etape_2/etape_2_1000.gif"
  alt="...">
  <figcaption>Simulation pour n = 1000</figcaption>
</figure>
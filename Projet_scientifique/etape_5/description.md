# Etape 5 : Equation de Laplace en 2D

Cette étape 5 consiste à résoudre une équation de Laplace. La résolution de cette équation est un premier
pas vers la résolution de l’équation de Poisson de l’étape 6 du Projet.

## Description

L’équation de Laplace s’écrit comme :

```∂^2 p/∂x^2 + ∂^2 p/∂y^2 = 0``` (1)

## Problème à résoudre

On souhaite résoudre l’équation (1) sur un domaine de taille 1.0 × 1.0 avec la condition initiale suivante :

```p = 0``` pour tout x, y

et les conditions aux limites suivantes :

* ```p = 0``` à x = 0
* ```p = y``` à x = 1
* ```p = 0``` à y = 0
* ```p = x``` à y = 1

Le domaine sera discrétisé avec un maillage homogène de 101 points dans chaque direction.
La résolution se fera avec un schéma centré d’ordre 2 pour les termes en dérivée seconde. 

Le résultat final attendu est après 10000 itérations.

La solution analytique est de la forme :

```p(x, y) = x × y```
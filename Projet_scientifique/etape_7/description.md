# Etape 7 : Equation de Navier-Stokes incompressible

Cette dernière étape consiste à résoudre les équations de Navier-Stokes incompressibles en 2D et de les
appliquer au problème de la cavité entraînée. Pour cela, il faut rassembler le travail des étapes précédentes,
notamment les étapes 4 et 6.

## Description

Equation de quantité de mouvement sous forme vectorielle pour une vitesse ⃗v :

```∂⃗v/∂t + (⃗v · ∇)⃗v = −1/ρ * ∇p + ν∇²⃗v``` (1)

Cette équation fait intervenir plusieurs quantités scalaires : une par composante de vitesse et une pour la
pression.

Pour notre problème en 2 dimensions, le système d’équations différentielles (2 équations pour la vitesse,
une pour la pression) à résoudre est (explications données en annexe) :


```∂u/∂t + u ∂u/∂x + v ∂u/∂y = -1/ρ * ∂p/∂x + ν (∂^2 u/∂x^2 + ∂^2 u/∂y^2)```

```∂v/∂t + u ∂v/∂x + v ∂v/∂y = -1/ρ * ∂p/∂y + ν (∂^2 v/∂x^2 + ∂^2 v/∂y^2)```

```∂^2 p/∂x^2 + ∂^2 p/∂y^2 = -ρ(∂u/∂x*∂u/∂x + 2*∂u/∂y*∂v/∂x + ∂v/∂y*∂v/∂y)```

## Problème à résoudre

![Loutres trop belle](../pictures/cavite_entrainee.png)

On souhaite résoudre l’équation (1) pour le problème de la cavité entraînée à Re = 1. On prendra un
domaine carré de 1 m de côté, comme illustré par la Figure 1, avec les conditions initiales suivantes :

```u, v, p = 0.0``` pour tout x, y (3)

et les conditions aux limites suivantes :

* ```u = 1.0``` à ```y = 1.0```
* ```u, v = 0.0``` sur toutes les autres conditions frontières
* ```p = 0.0``` à ```y = 1.0```
* ```∂p/∂x = 0.0``` à ```x = 0.0``` et ```x = 1.0```
* ```∂p/∂y = 0.0``` à ```y = 0.0```

Le domaine sera discrétisé avec un maillage homogène de 51 points dans chaque direction. La résolution se fera avec :

* un schéma upwind régressif pour le terme convectif (condition CF L = 0.2),
* un schéma centré d’ordre 2 pour les termes diffusifs (confition de Fourier F o = 0.1) et en dérivée seconde,
* un schéma centré d’ordre 2 pour le terme en gradient de pression,
* le schéma d’Euler explicite progressif d’ordre 1 pour le terme temporel.

Le résultat final attendu est après 0.1 secondes de temps physique.


Plusieurs algorithmes de résolution numérique du système d’équation (2) existent dans la littérature. Dans
le cadre du projet, on va utiliser un des plus faciles : la méthode d’avancement temporelle explicite simple.
La boucle temporelle se décompose comme ceci (début d’itération temporelle avec un, que l’on supposera ne pas respecter la condition de divergence nulle) :

1. calcul du pas de temps (même méthode que l’étape 4)
2. calcul du terme de droite de l’équation de Poisson 10
3. résolution de l’équation de Poisson 10 pour obtenir la pression ```p^n``` (même méthode que l’étape 6)
4. calcul de la vitesse ```u^(n+1)``` avec l’équation 8
5. retour au point 1
# holyspirit-softshadow2d : Scattering Demo (bin+shaders)

Demo issu du blog : http://blog.mmacklin.com/2010/05/29/in-scattering-demo/

Se lance sans problème vie Wine.

Il n'y pas les sources (CPP) mais les shaders, ce qui est normalement suffisant (du moins ça m'a suffit la dernière fois ^^)

C'est une démo en 3D (sphère, plan), avec 2 types de source de lumières gérées:
- Ponctuel/directionnel : position
- Spot : position + direction

Faut voir pour récupérer le shader de calcul et l'appliquer à notre modèle 2D.
Voir si il n'y a pas de possibilités d'optimisations (comme on réduit (potentiellement) une dimension)

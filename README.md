# Testeur Push Swap

## Introduction
Ce projet est un testeur pour le projet Push Swap. Il utilise un script Ruby pour générer des nombres de manière aléatoire et vérifier la sortie de l'exécutable Push Swap.

## Utilisation
Pour utiliser ce testeur :

1. Exécutez la commande `make` pour compiler et obtenir l'exécutable.
2. Lancez le testeur avec la commande suivante : ./test.sh push_swap checker_Mac comme_tu_veux.rb

Où :
- `test.sh` est le script de test,
- `push_swap` est votre exécutable,
- `checker_Mac` est le vérificateur,
- `comme_tu_veux.rb` est le script Ruby pour générer des nombres.

Assurez-vous d'avoir `valgrind` installé sur votre système pour une analyse mémoire détaillée. Le script vérifie également l'inclusion de `stdio.h` et l'utilisation de `printf` dans tous vos fichiers.

## Nettoyage
Après avoir terminé les tests, vous pouvez exécuter la commande suivante pour nettoyer : ./test.sh bye

Cette commande supprime le script et tous les fichiers qu'il a créés.



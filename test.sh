#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Nombre d'arguments incorrect. Utilisation: ./test.sh [push_swap] [checker] [ruby_script] ou ./test.sh bye"
    exit 1
fi

# Si l'argument est "bye", supprime les fichiers et le répertoire
if [ "$1" == "bye" ]; then
    if [ $# -ne 1 ]; then
        echo "L'argument 'bye' ne doit pas être accompagné d'autres arguments. Utilisation: ./test.sh bye"
        exit 1
    fi
    rm -rf leaks_checker log_valgrind test.leaks ./comme_tu_veux.rb ./test_leaks "$0"
    echo "Les fichiers et le répertoire spécifiés ont été supprimés."
    exit 0
fi

# Le reste de votre script ici...


# Récupère les exécutables à partir des arguments
push_swap_exec=$1
checker_exec=$2
ruby_script=$3


# Nombres min et max pour la génération de nombres
MIN=-2147483648
MAX=2147483647

# Tableau des nombres à générer
Ns=(3 5 30 50 100 250 500 700)

# Couleurs
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color
RED='\033[1;31m'

for N in ${Ns[@]}; do
    # Génération de nombres aléatoires sans doublons
    numbers_str=$(ruby $ruby_script $MIN $MAX $N)

    # Exécution de push_swap et comptage du nombre de coups
    push_swap_output=$(./$push_swap_exec $numbers_str)
    if [ "$push_swap_output" == "Error" ]; then
        echo -e "${YELLOW}push_swap a renvoyé une erreur pour N=$N${NC}"
        continue
    fi
    num_moves=$(echo "$push_swap_output" | wc -l)

    # Exécution du checker
    checker_output=$(echo "$push_swap_output" | ./$checker_exec $numbers_str)

    # Affichage des résultats
    echo "Nombres envoyés à push_swap et checker: $N"
    echo "Nombre de coups utilisés par push_swap: $num_moves"
    echo -e "${MAGENTA}Résultat du checker: $checker_output${NC}"
    echo "----------------------------------------------------"
done

# Test de cas spécifiques

echo -e "${MAGENTA}Test de cas spécifiques${NC}"
echo "----------------------------------------------------"

# Envoi d'un nombre supérieur à INT MAX
echo -e "${MAGENTA}Test avec un nombre supérieur à INT MAX${NC}"
push_swap_output=$(./$push_swap_exec $((MAX + 1)) 2>&1 ) # | tr -d '\n')
echo -e "${YELLOW}Résultat de push_swap: ${RED}$push_swap_output${NC}"

# Envoi d'un nombre inférieur à INT MIN
echo -e "${MAGENTA}Test avec un nombre inférieur à INT MIN${NC}"
push_swap_output=$(./$push_swap_exec $((MIN - 1)) 2>&1) # | tr -d '\n')
echo -e "${YELLOW}Résultat de push_swap: ${RED}$push_swap_output${NC}"

# Envoi d'une chaîne vide
echo -e "${MAGENTA}Test avec une chaîne vide${NC}"
push_swap_output=$(./$push_swap_exec "" 2>&1) #| tr -d '\n')
echo -e "${YELLOW}Résultat de push_swap: ${RED}$push_swap_output${NC}"

# Sans argument
echo -e "${MAGENTA}Test sans argument${NC}"
push_swap_output=$(./$push_swap_exec 2>&1) #| tr -d '\n')
echo -e "${YELLOW}Résultat de push_swap: ${RED}$push_swap_output${NC}"

# Avec un seul argument
echo -e "${MAGENTA}Test avec un seul argument${NC}"
push_swap_output=$(./$push_swap_exec "42" 2>&1) #| tr -d '\n')
echo -e "${YELLOW}Résultat de push_swap: ${RED}$push_swap_output${NC}"

make clean > /dev/null

norm=$(find . -name "*.c" -not -path "./leaks_checker/*" -exec norminette {} \; | grep -i error)

if [[ -z $norm ]]
then
    echo "norminette OK"
else
    echo "$norm"
fi


#ls -1a | grep -E "^\.[^.]+" | grep -v "\.git"

#cp push_swap.h push_swap.h.back
#sed -i "" 's:# define PUSH_SWAP_H:# define PUSH_SWAP_H\
## include "leaks_checker/leaks.h\":' push_swap.h

#gcc -o test_leaks *.c algo/*.c parsing/*.c operations_ch/*.c leaks_checker/test.c -Llib -lft -Lleaks_checker -lleaks && ./test_leaks $(ruby $ruby_script $MIN $MAX 500) 1>/dev/null
#mv push_swap.h.back push_swap.h

#rm -rf a.out 

# Chercher récursivement dans tous les fichiers .c et .h
for file in $(find . -type f \( -name "*.c" -or -name "*.h" \) -not -path "./leaks_checker/*" -not -path "./lib/ft_printf.c" -not -path "./lib/libft.h"); do
    # Vérifie l'inclusion de stdio.h
    if grep -q '#include <stdio.h>' "$file"; then
        echo "stdio.h est inclus dans $file"
    fi

    # Vérifie l'utilisation de printf
    if grep -q 'printf(' "$file"; then
        echo "Attention: printf est utilisé dans $file"
    fi
done

################################################comparer et chercher les login 

# Obtenez le login à partir du fichier main.c
login=$(grep -oP 'Created: \d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2} by \K\w+' main.c)

# Chercher récursivement dans tous les fichiers .c et .h
for file in $(find . -type f \( -name "*.c" -or -name "*.h" \) -not -path "./leaks_checker/*" -not -name "main.c"); do
    # Obtenez le login à partir du fichier actuel
    file_login=$(grep -oP 'Created: \d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2} by \K\w+' "$file")

    # Vérifie si le login est le même
    if [ "$login" != "$file_login" ]; then
        echo "Attention: Le login est différent dans le fichier $file"
    fi
done
#######################################################################

################################################serie de test aec valgrind

#!/bin/bash

# Crée le fichier log_valgrind s'il n'existe pas
touch log_valgrind

# Couleur mauve
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

commands=(
"./push_swap  2147483648  2147483647"
"./push_swap  -2147483649  2147483647"
"./push_swap  21474836  2147483647 | ./checker_Mac 21474836 2147483647"
"./push_swap  \"\" \"\" \"\""
"./push_swap"
"./push_swap  \"\""
"--track-origins=yes --leaks-check=full -s .push_swap 900 56 43 -100"
"--track-origins=yes --leak-check=full -s ./push_swap \"\" \"\" \"\""
"--track-origins=yes --leak-check=full -s ./push_swap \"\""
"--track-origins=yes --leak-check=full -s ./push_swap 2147483648 2147483647 | ./checker_Mac 2147483648 2147483647"
"--track-origins=yes --leak-check=full -s ./push_swap -2147483649 2147483647"
"--track-origins=yes --leak-check=full -s ./push_swap"
"--track-origins=yes --leak-check=full -s ./push_swap 21474836  2147483647 | ./checker_Mac 21474836 2147483647"
"--track-origins=yes --leak-check=full -s ./push_swap \"21474836  2147483647\" \"9 67\" | ./checker_Mac \"21474836  2147483647\" \"9 67\""
"--track-origins=yes --leak-check=full -s ./push_swap \"21474836  2147483647\" \"9 67\" 389 | ./checker_Mac \"21474836  2147483647\" \"9 67\" 389"
"--track-origins=yes --leak-check=full -s ./push_swap \"21 22\" \"90\" \"11\" | ./checker_Mac \"21 22\" \"90\" \"11\""
)

for cmd in "${commands[@]}"; do
    valgrind_cmd="valgrind $cmd"
    echo -e "${MAGENTA}Executing command: ${valgrind_cmd}${NC}"
    eval "$valgrind_cmd" > log_valgrind 2>&1
    cat log_valgrind
    # Clear the log_valgrind file for the next command
    > log_valgrind
done

make clean



function executer_et_afficher {
    # Extraire la partie de la commande après './a.out'
    valeurs=$(echo "$1" | cut -d '|' -f 2)

    # Afficher les valeurs en mauve
    printf "\033[35m%s\033[0m\n" "$valeurs"

    # Exécuter la commande et capturer la sortie et les erreurs
    output=$(eval $1 2>&1)

    # Vérifier si la sortie est vide
    if [[ -z "$output" ]]; then
        echo "RIEN"
    else
        echo "$output"
    fi
}


gcc -Wall -Wextra -Werror -fsanitize=address -g algo/*.c ft_change_val_to_tab_rank.c ft_free_and_exit.c ft_nb_of_nb.c lib/libft.a main.c operations_ch/*.c parsing/*.c

executer_et_afficher "./a.out '' '' # vide"
executer_et_afficher "./a.out 2147483648 2147483647 # + int max positif"
executer_et_afficher "./a.out -2147483649 2147483647 # - int min négatif"
executer_et_afficher "./a.out 1 2 2 2 2 # doubles"
executer_et_afficher "./a.out 1 # une valeur"
executer_et_afficher "./a.out # rien"
executer_et_afficher "./a.out 1 2 3 4 5 6 7 8 9 10 # deja trié"
executer_et_afficher "./a.out 21 a18 # chiffres + lettres"
executer_et_afficher "./a.out a b c # que des lettres"

rm -rf a.out
rm -rf a.out.dSYM
rm -rf push_swap.dSYM 
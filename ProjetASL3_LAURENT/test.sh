#!/bin/bash

PROG="tpcas"
fichier="tests.log"
fichiers_valides="test/good/"
fichiers_invalides="test/syn-err/"

if([ -f ${PROG} ]); then
    if [ -f "$fichier" ] ; then
        rm -f ${fichier}  #if there is fichier we delete the old one
    fi

    echo -e "Fichiers valides : \n" >> ${fichier}

    for fichier_valide in `ls ${fichiers_valides}`  # ``is command for bash
    do
        R=$(cat ${fichiers_valides}${fichier_valide} | ./${PROG})
        echo -e '"'${fichiers_valides}${fichier_valide}'"' "a renvoyé" $? >> ${fichier}
    done

    echo -e "\nFichiers invalides : \n" >> ${fichier}

    for fichier_invalide in `ls ${fichiers_invalides}`  # ``is command for bash
    do
        R=$(cat ${fichiers_invalides}${fichier_invalide} | ./${PROG})
        echo -e '"'${fichiers_invalides}${fichier_invalide}'"' "a renvoyé" $? >> ${fichier}
    done
else
    echo "[Error] file \""${PROG}"\" is missing!!"
fi
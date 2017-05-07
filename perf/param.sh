#!/bin/bash

# Parametros para el conjunto de testers 

DATADIR=../tests/data
TESTINDIR=$DATADIR/imagenes_a_testear
ALUMNOSDIR=$DATADIR/resultados_nuestros

IMAGENES=(lena.bmp colores.bmp)
SIZES=(64x64 128x128 192x192 256x256 320x320 384x384 448x448 512x512)

TP2ALU=./tp2
TP2DATA=./tp2_data

# Colores

ROJO="\e[31m"
VERDE="\e[32m"
AZUL="\e[94m"
DEFAULT="\e[39m"
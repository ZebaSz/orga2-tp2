#!/bin/bash

source param.sh

#$1 : Programa Ejecutable
#$2 : Filtro e Implementacion Ejecutar
#$3 : Archivos de Entrada
#$4 : Archivo de Salida (sin path)

function run_test {
    echo -e "dale con... $VERDE $4 $DEFAULT"
    $1 $2 $3 $ALUMNOSDIR/$4
}

for imp in c asm; do

# convertYUV
  for s in ${SIZES[*]}; do
    for f in ${IMAGENES[*]}; do
      run_test "$TP2ALU" "$imp rgb2yuv" "$TESTINDIR/$f.$s.bmp" "$imp.$f.$s.yuv.bmp"
    done
  done
done
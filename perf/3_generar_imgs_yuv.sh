#!/bin/bash

source param.sh

img0=${IMAGENES[0]}
img0=${img0%%.*}
img1=${IMAGENES[1]}
img1=${img1%%.*}

#$1 : Programa Ejecutable
#$2 : Filtro e Implementacion Ejecutar
#$3 : Archivos de Entrada
#$4 : Archivo de Salida (sin path)

function run_test {
    echo -e "dale con... $VERDE $4 $DEFAULT"
    $1 $2 $3 $ALUMNOSDIR/$4
    ret=0; return;
}

for imp in c asm; do

# convertYUV
  for s in ${SIZES[*]}; do
    run_test "$TP2ALU" "$imp rgb2yuv" "$TESTINDIR/$img0.$s.bmp" "$imp.$img0.$s.yuv.bmp"
    if [ $ret -ne 0 ]; then exit -1; fi
    run_test "$TP2ALU" "$imp rgb2yuv" "$TESTINDIR/$img1.$s.bmp" "$imp.$img1.$s.yuv.bmp"
    if [ $ret -ne 0 ]; then exit -1; fi
  done

done
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
#$5 : Parametros del filtro

function run_test {
    echo -e "dale con... $VERDE $4 $DEFAULT"
    $1 $2 $3 $ALUMNOSDIR/$4 $5
    ret=0;return;
}

rm *.csv
echo "Algoritmo,Tamaño,Ticks" > rgb2yuv.csv 
echo "Algoritmo,Tamaño,Ticks" > yuv2rgb.csv 
echo "Algoritmo,Tamaño,Ticks" > fourCombine.csv 
echo "Algoritmo,Tamaño,Ticks" > linearZoom.csv 
echo "Algoritmo,Tamaño,Ticks" > maxCloser.csv 

for imp in c asm; do

# convertYUV
  for s in ${SIZES[*]}; do
    run_test "$TP2DATA" "$imp rgb2yuv" "$TESTINDIR/$img0.$s.bmp" "$imp.$img0.$s.yuv.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
    run_test "$TP2DATA" "$imp rgb2yuv" "$TESTINDIR/$img1.$s.bmp" "$imp.$img1.$s.yuv.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
  done

# convertYUV
  for s in ${SIZES[*]}; do
    run_test "$TP2DATA" "$imp yuv2rgb" "$ALUMNOSDIR/$imp.$img0.$s.yuv.bmp" "$imp.$img0.$s.rgb.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
    run_test "$TP2DATA" "$imp yuv2rgb" "$ALUMNOSDIR/$imp.$img1.$s.yuv.bmp" "$imp.$img1.$s.rgb.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
  done

# fourCombine
  for s in ${SIZES[*]}; do
    run_test "$TP2DATA" "$imp fourCombine" "$TESTINDIR/$img0.$s.bmp" "$imp.$img0.$s.four.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
    run_test "$TP2DATA" "$imp fourCombine" "$TESTINDIR/$img1.$s.bmp" "$imp.$img1.$s.four.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
  done

# linearZoom
  for s in ${SIZES[*]}; do
    run_test "$TP2DATA" "$imp linearZoom" "$TESTINDIR/$img0.$s.bmp" "$imp.$img0.$s.zoom.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
    run_test "$TP2DATA" "$imp linearZoom" "$TESTINDIR/$img1.$s.bmp" "$imp.$img1.$s.zoom.bmp" ""
    if [ $ret -ne 0 ]; then exit -1; fi
  done
  
# maxCloser
  for v in 0 0.313 0.5 0.713 1; do
  for s in ${SIZES[*]}; do
    run_test "$TP2DATA" "$imp maxCloser" "$TESTINDIR/$img0.$s.bmp" "$imp.$img0.$s.$v.max.bmp" "$v"
    if [ $ret -ne 0 ]; then exit -1; fi
    run_test "$TP2DATA" "$imp maxCloser" "$TESTINDIR/$img1.$s.bmp" "$imp.$img1.$s.$v.max.bmp" "$v"
    if [ $ret -ne 0 ]; then exit -1; fi
  done
  done

done
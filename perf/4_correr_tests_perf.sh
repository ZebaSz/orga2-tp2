#!/bin/bash

source param.sh

#$1 : Programa Ejecutable
#$2 : Filtro e Implementacion Ejecutar
#$3 : Archivos de Entrada
#$4 : Archivo de Salida (sin path)
#$5 : Parametros del filtro

function run_test {
    echo -e "dale con... $VERDE $4 $DEFAULT"
    $1 $2 $3 $ALUMNOSDIR/$4 $5
}

rm rgb2yuv.csv
echo "Algoritmo,Tamaño,Ticks" > rgb2yuv.csv
rm yuv2rgb.csv
echo "Algoritmo,Tamaño,Ticks" > yuv2rgb.csv
rm fourCombine.csv
echo "Algoritmo,Tamaño,Ticks" > fourCombine.csv
rm linearZoom.csv
echo "Algoritmo,Tamaño,Ticks" > linearZoom.csv
rm maxCloser.csv
echo "Algoritmo,Tamaño,Ticks" > maxCloser.csv

for imp in ${IMPS[*]}; do
# convertYUV
  for s in ${SIZES[*]}; do
    for f in ${IMAGENES[*]}; do
      run_test "$TP2DATA" "$imp rgb2yuv" "$TESTINDIR/$f.$s.bmp" "$imp.$f.$s.yuv.bmp" ""
    done
  done

# convertRGB
  for s in ${SIZES[*]}; do
    for f in ${IMAGENES[*]}; do
      run_test "$TP2DATA" "$imp yuv2rgb" "$ALUMNOSDIR/$imp.$f.$s.yuv.bmp" "$imp.$f.$s.rgb.bmp" ""
    done
  done

# fourCombine
  for s in ${SIZES[*]}; do
    for f in ${IMAGENES[*]}; do
      run_test "$TP2DATA" "$imp fourCombine" "$TESTINDIR/$f.$s.bmp" "$imp.$f.$s.four.bmp" ""
    done
  done

# linearZoom
  for s in ${SIZES[*]}; do
    for f in ${IMAGENES[*]}; do
      run_test "$TP2DATA" "$imp linearZoom" "$TESTINDIR/$f.$s.bmp" "$imp.$f.$s.zoom.bmp" ""
    done
  done
  
# maxCloser
  for v in ${VS[*]}; do
    for s in ${SIZES[*]}; do
      for f in ${IMAGENES[*]}; do
        run_test "$TP2DATA" "$imp maxCloser" "$TESTINDIR/$f.$s.bmp" "$imp.$f.$s.$v.max.bmp" "$v"
      done
    done
  done

done
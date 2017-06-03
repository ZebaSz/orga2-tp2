#!/bin/bash

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.

source param.sh

mkdir -p $TESTINDIR $CATEDRADIR $ALUMNOSDIR

for f in ${IMAGENES[*]};
do
	echo "$f.bmp"
	for s in ${SIZES[*]} ${SIZESMEM[*]}
	do
		echo "  *" $s
		`echo  "convert -resize $s!" $DATADIR/$f.bmp ` $TESTINDIR/`echo "$f.bmp" | cut -d'.' -f1`.$s.bmp
	done
done

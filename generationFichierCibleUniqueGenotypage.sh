readsCible=$1
myCNV=$2
myOut=$3
#a partir du fichier de readCount de la plaque de destination
awk -F"\t" '{OFS="\t";print $1,$2,$3,NR}' $readsCible > tmp

#intersection entre les CNVs à génotyper et le fichier généré --> obtention des cibles (ou non, si le CNV n'a pas d'équivalent dans le kit cible)
echo "SAMPLE;CNV;INTERVAL;KB;CHR;MID_BP;TARGETS;NUM_TARG;MLCN;Q_SOME" > $myOut
intersectBed -a $myCNV -b tmp -wao | cut -f 4-7 | awk -F"\t" '$4 !="." {OFS="";print "\"SAMPLE\";\"DUP\";\"",$1,":"$2,"-",$3,"\";",$3-$2,";",($2+$3)/2,";",$1,";\"",$4,"..",$4,"\";",1,";3;99"}' >> $myOut
rm tmp

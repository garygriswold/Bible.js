#!/bin/sh

# Original USX input
WEB_BIBLE_PATH="/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB World English Bible"
# Output location of XMLTokenizerTest
#OUT_BIBLE_PATH="/Users/garygriswold/Desktop/Philip Project/Bibles/USX/WEB_XML_OUT"
# Output location of USXReaderTest
OUT_BIBLE_PATH="/Users/garygriswold/Desktop/BibleApp Project/Bibles/USX/WEB_USX_OUT"

books=( "001GEN" "002EXO" "003LEV" "004NUM" "005DEU" "006JOS" "007JDG" "008RUT" "0091SA" "0102SA" "0111KI" "0122KI" "0131CH" 
	"0142CH" "015EZR" "016NEH" "017EST" "018JOB" "019PSA" "020PRO" "021ECC" "022SNG" "023ISA" "024JER" "025LAM" "026EZK" "027DAN"
	"028HOS" "029JOL" "030AMO" "031OBA" "032JON" "033MIC" "034NAM" "035HAB" "036ZEP" "037HAG" "038ZEC" "039MAL"
	"040MAT" "041MRK" "042LUK" "043JHN" "044ACT" "045ROM" "0461CO" "0472CO" "048GAL" "049EPH" "050PHP" "051COL"
	"0521TH" "0532TH" "0541TI" "0552TI" "056TIT" "057PHM" "058HEB" "059JAS" "0601PE" "0612PE" "0621JN" "0632JN" "0643JN" "065JUD" "066REV")
for element in ${books[@]}
do
    echo ${element}.usx
    diff -b "${WEB_BIBLE_PATH}/${element}.usx" "${OUT_BIBLE_PATH}/${element}.usx"
done
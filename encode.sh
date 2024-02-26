


# args passing

while getopts i:o:f: flag
do
    case "${flag}" in
        i) inputfile=${OPTARG};;
        o) outputfile=${OPTARG};;
    esac
done
echo "inputfile: $inputfile";
echo "outputfile: $outputfile";


# cleanup
rm -r .tempqr1megabyte

# create temp dir
mkdir -p .tempqr1megabyte/base64
mkdir -p .tempqr1megabyte/split
mkdir -p .tempqr1megabyte/splitnumbered

mkdir -p .tempqr1megabyte/qrcodes


#base64 $inputfile > .tempqr1megabyte/base64/temp.base64
zip .tempqr1megabyte/temp.zip $inputfile


(cd .tempqr1megabyte/split && split -b2500 ../temp.zip)

order=1
( cd .tempqr1megabyte/split/ &&
for file in ./*
do
    printf "0: %.8x" $order | sed -E 's/0: (..)(..)(..)(..)/0: \4\3\2\1/' | xxd -r -g0 | cat - $file > ../splitnumbered/$file
    ((order=order+1))
done
)

( cd .tempqr1megabyte/splitnumbered/ &&
for file in ./*
do
  #cat "$file" | qrencode -o ../qrcodes/"$file".png
  qrencode -8 -r "$file" -o ../qrcodes/"$file".png

done
)



#!/bin/bash

# Specify the directory containing your files
directory=".tempqr1megabyte/qrcodes"

# Specify the output file for the table
output_file="output_table.txt"

# Get a list of files in the directory
files=("$directory"/*)

# Check if there are files in the directory
if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in the specified directory."
    exit 1
fi

maxrow=4
maxcolum=3

counter=0

for pngfile in "$directory"/*
do
    
    if [ $counter == 0 ]
    then
        echo "\begin{figure}\begin{tabular}{ccc}">> .tempqr1megabyte/tablecontent.tex
    fi
    if ! ((($counter+1) % maxcolum)); then
        echo "\includegraphics[width=65mm]{"$pngfile"}\\\\" >> .tempqr1megabyte/tablecontent.tex
    else
        echo "\includegraphics[width=65mm]{"$pngfile"}" >> .tempqr1megabyte/tablecontent.tex
    fi
    
    if [ $counter == $(((maxrow)*(maxcolum)-1)) ]
    then
        echo "\end{tabular}\end{figure}">> .tempqr1megabyte/tablecontent.tex
        counter=-1
    fi
    ((counter=counter+1))
done

if [ $counter != 0 ]
then
    echo "\end{tabular}\end{figure}">> .tempqr1megabyte/tablecontent.tex
    counter=-1
fi

#echo "Table created successfully. Check $output_file"

outputbasename="$(basename $outputfile .pdf)"

pdflatex -interaction=nonstopmode -jobname $outputbasename latextemplate.tex

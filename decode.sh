
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
mkdir -p .tempqr1megabyte/pdfimages
mkdir -p .tempqr1megabyte/pdfimagesbindecode
mkdir -p .tempqr1megabyte/pdfimagesbindecodeorder


pdfimages -all $inputfile .tempqr1megabyte/pdfimages/img


( cd .tempqr1megabyte/pdfimages/ &&
for file in ./*
do
    filebasename="$(basename $file .png)"
    zbarimg -q --raw --oneshot -Sbinary "$file" > ../pdfimagesbindecode/"$filebasename".bin
done
)

# delete empty files
(cd .tempqr1megabyte/pdfimagesbindecode && find . -size 0 -print -delete)


( cd .tempqr1megabyte/pdfimagesbindecode &&
for file in ./*
do
    #index=`head -c 4 $file | dc`
    index=$(od -t x4 --endian=little --read-bytes=4 $file | awk '{print $2}')
    echo $index
    dd if="$file" of="../pdfimagesbindecodeorder/order$index.bin" bs=1 skip=4
done
)


cat .tempqr1megabyte/pdfimagesbindecodeorder/* > .tempqr1megabyte/concat.zip

mkdir $outputfile
(cd $outputfile && unzip "../.tempqr1megabyte/concat.zip")

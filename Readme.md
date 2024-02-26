# qrcodemegabyte

A CLI for createing pdf containing multiple qr code representing the file

depends on
 - base64 (optional)
 - split
 - gzip
 - 


## Create Random File 
```
dd if=/dev/urandom of=testinputdata.data bs=1 count=102400
```

## Encode
```
bash encode.sh -i testinputdata.data -o output.pdf
```


## Decode
```
bash decode.sh -i output.pdf -o decodefolder
```


## Test

```
diff <(xxd testinputdata.data) <(xxd decodefolder/testinputdata.data)
```



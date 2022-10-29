#!/usr/bin/env bash
# Adam Sellers
# bash for [NAME]
# run using: 
#   ./r.sh
#   ./pureasm.out

set -e
rm -f -- *.o *.lis *.out

for f in *.asm; do
    nasm -f elf64 -o "$f.o" "$f" -g -gdwarf
done

ld -o cosine.out start.asm.o itoa.asm.o atof.asm.o ftoa.asm.o scan.asm.o cos.asm.o
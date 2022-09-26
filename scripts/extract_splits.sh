#!/usr/bin/env bash
# -*- coding: utf-8 -*-

#########
# WARNING simple head/tail approach - NO SHUFFLING/DEDUPLICATION
# Example call:
# bash scripts/extract_splits.sh ../raw_data/infopankki_raw data/en-sv/infopankki/raw/
#########

indir=$1
outdir=$2

mkdir -p $outdir

head -n 1000 $indir/*.en-sv.sv >| $outdir/tiny_train.sv
head -n 1000 $indir/*.en-sv.en >| $outdir/tiny_train.en

head -n 10000 $indir/*.en-sv.sv >| $outdir/train.sv
head -n 10000 $indir/*.en-sv.en >| $outdir/train.en

head -n 10500 $indir/*.en-sv.sv | tail -n 500 >| $outdir/valid.sv
head -n 10500 $indir/*.en-sv.en | tail -n 500 >| $outdir/valid.en

head -n 11000 $indir/*.en-sv.sv | tail -n 500 >| $outdir/test.sv
head -n 11000 $indir/*.en-sv.en | tail -n 500 >| $outdir/test.en

wc -l $outdir/*

echo ""
echo "done."
echo ""


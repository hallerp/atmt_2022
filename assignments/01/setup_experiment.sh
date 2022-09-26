#!/bin/bash
# -*- coding: utf-8 -*-

set -e

pwd=`dirname "$(readlink -f "$0")"`
base=$pwd/../..

cd $base
echo "changed dir into $base"

echo ""
echo "preparing ID data..."
echo ""

# extract splits for In Domain data
python scripts/extract_splits.py \
    --src /srv/scratch6/kew/atmt/data/infopankki_raw/infopankki.en-sv.sv \
    --tgt /srv/scratch6/kew/atmt/data/infopankki_raw/infopankki.en-sv.en \
    --outdir data/en-sv/infopankki/raw

# prepare in-domain data for model training and testing
bash scripts/preprocess_data.sh data/en-sv/infopankki/raw/ sv en

echo ""
echo "preparing OOD BIBLE data..."
echo ""

python scripts/extract_splits.py \
    --src /srv/scratch6/kew/atmt/data/bible_uedin_raw/*.en-sv.sv \
    --tgt /srv/scratch6/kew/atmt/data/bible_uedin_raw/*.en-sv.en \
    --outdir data/en-sv/bible_uedin/raw

rm -rf data/en-sv/bible_uedin/raw/train*
rm -rf data/en-sv/bible_uedin/raw/tiny_train*
rm -rf data/en-sv/bible_uedin/raw/valid*

mkdir -p data/en-sv/bible_uedin/preprocessed

for lang in sv en
do
    # normalise, tokenise and apply truecase model learned on in-domain data
    cat data/en-sv/bible_uedin/raw/test.$lang | perl moses_scripts/normalize-punctuation.perl -l $lang | perl moses_scripts/tokenizer.perl -l $lang -a -q | perl moses_scripts/truecase.perl --model data/en-sv/infopankki/preprocessed/tm.$lang >| data/en-sv/bible_uedin/preprocessed/test.$lang     
done

python preprocess.py \
    --source-lang sv --vocab-src data/en-sv/infopankki/prepared/dict.sv \
    --target-lang en --vocab-trg data/en-sv/infopankki/prepared/dict.en \
    --test-prefix data/en-sv/bible_uedin/preprocessed/test \
    --dest-dir data/en-sv/bible_uedin/prepared

echo "done."

echo ""
echo "preparing OOD TED2020 data..."
echo ""

python scripts/extract_splits.py \
    --src /srv/scratch6/kew/atmt/data/TED2020_raw/*.en-sv.sv \
    --tgt /srv/scratch6/kew/atmt/data/TED2020_raw/*.en-sv.en \
    --outdir data/en-sv/TED2020/raw

rm -rf data/en-sv/TED2020/raw/train*
rm -rf data/en-sv/TED2020/raw/tiny_train*
rm -rf data/en-sv/TED2020/raw/valid*

mkdir -p data/en-sv/TED2020/preprocessed

for lang in sv en
do
    # normalise, tokenise and apply truecase model learned on in-domain data
    cat data/en-sv/TED2020/raw/test.$lang | perl moses_scripts/normalize-punctuation.perl -l $lang | perl moses_scripts/tokenizer.perl -l $lang -a -q | perl moses_scripts/truecase.perl --model data/en-sv/infopankki/preprocessed/tm.$lang >| data/en-sv/TED2020/preprocessed/test.$lang     
done

python preprocess.py \
    --source-lang sv --vocab-src data/en-sv/infopankki/prepared/dict.sv \
    --target-lang en --vocab-trg data/en-sv/infopankki/prepared/dict.en \
    --test-prefix data/en-sv/TED2020/preprocessed/test \
    --dest-dir data/en-sv/TED2020/prepared

echo "done."
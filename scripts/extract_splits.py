#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""

Use this script to extract deduplicated and shuffled src-tgt pairs from
src-tgt aligned files downloaded from OPUS.

Example call:

    python extract_splits.py --src /mnt/storage/clwork/users/kew/HS2021/infopankki_raw/infopankki.en-sv.sv --tgt /mnt/storage/clwork/users/kew/HS2021/infopankki_raw/infopankki.en-sv.en --outdir /mnt/storage/clwork/users/kew/HS2021/atmt/data/en-sv/infopankki/raw

"""

import argparse
import random
from pathlib import Path

def set_args():

    ap = argparse.ArgumentParser()
    ap.add_argument('--src', required=True, type=str, help='')
    ap.add_argument('--tgt', required=True, type=str, help='')
    ap.add_argument('--outdir', required=True, type=str, help='')
    
    ap.add_argument('--train_size', required=False, default=10000, type=int, help='')
    ap.add_argument('--test_size', required=False, default=500, type=int, help='')
    ap.add_argument('--valid_size', required=False, default=500, type=int, help='')
    ap.add_argument('--tiny_train_size', required=False, default=1000, type=int, help='')

    ap.add_argument('--shuffle', required=False, default=True, type=bool, help='')

    return ap.parse_args()

def iter_lines(file):
    with open(file, 'r', encoding='utf8') as f:
        for line in f:
            yield line.rstrip()


if __name__ == '__main__':
    
    args = set_args()

    c = 0
    data_set = dict()
    for src_line, tgt_line in zip(iter_lines(args.src), iter_lines(args.tgt)):
        c += 1
        # print(src_line, '---',  tgt_line)
        hashed_pair = hash(src_line + tgt_line)
        if hashed_pair not in data_set:
            data_set[hashed_pair] = [src_line, tgt_line]

    print(f'Found {len(data_set)} unique src-tgt pairs out of {c}...')

    if len(data_set) < args.train_size+args.test_size+args.valid_size:
        print('! WARNING - size of desired splits is larger than the number of unique items in dataset!')
        
    # infer src & tgt langs from input files (expected to
    # end in language code (*.en))
    src_lang = args.src[-2:]
    tgt_lang = args.tgt[-2:]

    data_set = list(data_set.values())
    
    if args.shuffle:
        random.seed(42)
        random.shuffle(data_set)

    test_set = data_set[:args.test_size]
    valid_set = data_set[args.test_size:args.test_size+args.valid_size]
    train_set = data_set[args.test_size+args.valid_size:args.test_size+args.valid_size+args.train_size]
    tiny_train_set = train_set[:args.tiny_train_size]

    Path(args.outdir).mkdir(parents=True, exist_ok=True)

    for split_name, split_data in {'test': test_set, 'valid': valid_set, 'train': train_set, 'tiny_train': tiny_train_set}.items():
        src_file = Path(args.outdir) / f'{split_name}.{src_lang}'       
        tgt_file = Path(args.outdir) / f'{split_name}.{tgt_lang}'

        c = 0
        with open(src_file, 'w', encoding='utf8') as src_f:
            with open(tgt_file, 'w', encoding='utf8') as tgt_f:
                for src, tgt in split_data:
                    src_f.write(f'{src}\n')
                    tgt_f.write(f'{tgt}\n')
                    c += 1
        print(f'Wrote {c} lines to {split_name} split...')

print('Done.')
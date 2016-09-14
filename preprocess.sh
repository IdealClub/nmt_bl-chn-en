#!/bin/sh

source /home/shuoyangd/experiments/nmt16-chn-en/exp2/env.sh

# this sample script preprocesses a sample corpus, including tokenization,
# truecasing, and subword segmentation. 
# for application to a different language pair,
# change source and target prefix, optionally the number of BPE operations,
# and the file names (currently, data/corpus and data/newsdev2016 are being processed)

# in the tokenization step, you will want to remove Romanian-specific normalization / diacritic removal,
# and you may want to add your own.
# also, you may want to learn BPE segmentations separately for each language,
# especially if they differ in their alphabet

# suffix of source language files
SRC=$SRC_LANG

# suffix of target language files
TRG=$TGT_LANG

# number of merge operations. Network vocabulary should be slightly larger (to include characters),
# or smaller if the operations are learned on the joint vocabulary
bpe_operations=$BPE_OPT

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=$MOSES

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
subword_nmt=$SUBWORD

# path to nematus ( https://www.github.com/rsennrich/nematus )
nematus=$NEMATUS

# path to stanford-seg
stanford_seg=/home/shuoyangd/stanford-seg

# tokenize
for prefix in $TRN_PREFIX $DEV_PREFIX
 do
   # segmentation for chinese
   cat data/$prefix.$SRC | \
   ./segmentstd.sh $stanford_seg/segment.sh data/ ctb UTF-8 0 | \
   $mosesdecoder/scripts/tokenizer/escape-special-chars.perl | \
   ./chinese-punctuations-utf8.perl > data/$prefix.tok.$SRC

   cat data/$prefix.$TRG | \
   $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $TRG | \
   $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > data/$prefix.tok.$TRG

 done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl $TRNDATA.tok $SRC $TRG $TRNDATA.tok.clean 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus $TRNDATA.tok.clean.$SRC -model model/truecase-model.$SRC
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus $TRNDATA.tok.clean.$TRG -model model/truecase-model.$TRG

# apply truecaser (cleaned training corpus)
for prefix in $TRN_PREFIX
 do
  $mosesdecoder/scripts/recaser/truecase.perl -model model/truecase-model.$SRC < data/$prefix.tok.clean.$SRC > data/$prefix.tc.$SRC
  $mosesdecoder/scripts/recaser/truecase.perl -model model/truecase-model.$TRG < data/$prefix.tok.clean.$TRG > data/$prefix.tc.$TRG
 done

# apply truecaser (dev/test files)
for prefix in $DEV_PREFIX
 do
  $mosesdecoder/scripts/recaser/truecase.perl -model model/truecase-model.$SRC < data/$prefix.tok.$SRC > data/$prefix.tc.$SRC
  $mosesdecoder/scripts/recaser/truecase.perl -model model/truecase-model.$TRG < data/$prefix.tok.$TRG > data/$prefix.tc.$TRG
 done

# train BPE
cat $TRNDATA.tc.$SRC $TRNDATA.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > model/$SRC$TRG.bpe

# apply BPE

for prefix in $TRN_PREFIX $DEV_PREFIX
 do
  $subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/$prefix.tc.$SRC > data/$prefix.bpe.$SRC
  $subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/$prefix.tc.$TRG > data/$prefix.bpe.$TRG
 done

# build network dictionary
$nematus/data/build_dictionary.py $TRNDATA.bpe.$SRC $TRNDATA.bpe.$TRG

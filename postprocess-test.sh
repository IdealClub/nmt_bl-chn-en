#/bin/sh

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=/home/pkoehn/moses

# suffix of target language files
lng=en

sed -r 's/ \@(\S*?)\@ /\1/g' | \
$mosesdecoder/scripts/recaser/detruecase.perl | \
$mosesdecoder/scripts/tokenizer/detokenizer.perl -l $lng

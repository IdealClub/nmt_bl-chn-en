export NEMATUS=/home/shuoyangd/nmt/nematus
export SUBWORD=/home/shuoyangd/nmt/subword-nmt
export MOSES=/export/b11/shuoyangd/mosesstd

export WORKDIR=/export/b10/shuoyangd/nmt16-chn-en/exp2

export SRC_LANG=zh
export TGT_LANG=en
export VOCAB_SIZE=50000
export BPE_OPT=49500
export QSUB_PREFIX="qsub -l 'arch=*64,gpu=1,hostname=b1[12345678]*' -o $WORKDIR/outs -e $WORKDIR/outs"

export TRN_PREFIX=corpus
export DEV_PREFIX=eval05
export TST_PREFIX=eval08

export TRNDATA=$WORKDIR/data/corpus
export DEVDATA=$WORKDIR/data/eval05
export TSTDATA=$WORKDIR/data/eval08
export VLD_SCRPT=$WORKDIR/validate.sh


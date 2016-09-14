#!/bin/bash
#$ -q g.q
#$ -M dings@jhu.edu
#$ -l 'arch=*64,gpu=1,hostname=b1[12345678]*'
#$ -o /home/shuoyangd/experiments/nmt16-chn-en/exp2/outs/ -e /home/shuoyangd/experiments/nmt16-chn-en/exp2/outs/

source /home/shuoyangd/experiments/nmt16-chn-en/exp2/env.sh
cd $WORKDIR
source /home/shuoyangd/pyenv/theano/bin/activate

export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export PATH=/opt/NVIDIA/cuda-7/bin:/opt/NVIDIA/cuda-7.0/bin:$PATH

# theano device
export n_gpus=`lspci | grep -i "nvidia" | wc -l`
export device=gpu`nvidia-smi | sed -e '1,/Processes/d' | tail -n+3 | head -n-1 | perl -ne 'next unless /^\|\s+(\d)\s+\d+/; $a{$1}++; for(my $i=0;$i<$ENV{"n_gpus"};$i++) { if (!defined($a{$i})) { print $i."\n"; last; }}' | tail -n 1`
echo $device
THEANO_FLAGS=mode=FAST_RUN,floatX=float32,device=$device,on_unused_input=warn python config.py


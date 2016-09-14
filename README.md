This directory is forked from Rico Sennrich's [wmt16-scripts](https://github.com/rsennrich/wmt16-scripts), with tweaks to facilitate easier usage and special configurations added to train a Chinese-English neural machine translation system. Note that apart from the preprocess script, all the other scripts are language-agnostic.

All the scripts are tested to run on the CLSP grid of Johns Hopkins University.

DEPENDENCIES
------------
Stanford Chinese Word Segmentor >= v3.4.1
[nematus](https://github.com/shuoyangd/nematus) (Note the upstream copy may not run smoothly on CLSP grid)
[subword-nmt](https://github.com/rsennrich/subword-nmt)
[Moses Decoder](https://github.com/shuoyangd/mosesdecoder) (You don't need to compile for this since we only use the scripts)

SETUP
------------
You need to change the following files to run your own experiment:
+ `env.sh`: change all the paths to your directory
+ `preprocess.sh` `train.sh` `validate.sh`: find a line `source /path/to/env.sh`, point it to the env.sh in your directory

INSTRUCTIONS
------------

all scripts contain variables that you will need to set to run the scripts.
For processing the sample data, only paths to different toolkits need to be set.
For processing new data, more changes will be necessary.

As a first step, preprocess the training data:

  ./preprocess.sh

Then, start training: on normal-size data sets, this will take about 1-2 weeks to converge.
Models are saved regularly, and you may want to interrupt this process without waiting for it to finish.

  ./train.sh

Given a model, preprocessed text can be translated thusly:

  ./translate.sh

Finally, you may want to post-process the translation output, namely merge BPE segments,
detruecase and detokenize:

  ./postprocess-test.sh < data/newsdev2016.output > data/newsdev2016.postprocessed

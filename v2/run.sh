#!/bin/bash
# Copyright   2017   Johns Hopkins University (Author: Daniel Garcia-Romero)
#             2017   Johns Hopkins University (Author: Daniel Povey)
#        2017-2018   David Snyder
#             2018   Ewald Enzinger
# Apache 2.0.
#
# See ../README.txt for more info on data required.
# Results (mostly equal error-rates) are inline in comments below.

. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc


nnet_dir=exp/0007_voxceleb_v2_1a/exp/xvector_nnet_1a # Pretrained model downloaded from Kaldi website
of_data=  # The kaldi data directory with original and fake data

stage=0

# Download model
if [ $stage -le 0 ]; then
  local/download_and_untar.sh
fi

nj=32
if [ $stage -le 1 ]; then
  # Make MFCCs and compute the energy-based VAD for each dataset
  for name in $of_data; do
    steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config conf/mfcc.conf --nj $nj --cmd "$train_cmd" \
      data/${name} exp/make_mfcc $mfccdir
    utils/fix_data_dir.sh data/${name}
    sid/compute_vad_decision.sh --nj $nj --cmd "$train_cmd" \
      data/${name} exp/make_vad $vaddir
    utils/fix_data_dir.sh data/${name}
  done
fi

if [ $stage -le 2 ]; then
  # Extract x-vectors for of_data.
  sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 4G" --nj $nj \
    $nnet_dir data/${of_data} \
    $nnet_dir/xvectors_${of_data}

fi

if [ $stage -le 3 ]; then
  local/plot_real_fake.py ${of_data}
fi


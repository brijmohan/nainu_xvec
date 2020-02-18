#!/bin/bash

mkdir -p exp

data=exp
url="http://kaldi-asr.org/models/7"
part="0007_voxceleb_v2_1a"


if [ -f $data/$part/.complete ]; then
  echo "$0: model was already successfully extracted, nothing to do."
  exit 0;
fi


pushd $data

if [ ! -f $part.tar.gz ]; then
  if ! which wget >/dev/null; then
    echo "$0: wget is not installed."
    exit 1;
  fi
  full_url=$url/$part.tar.gz
  echo "$0: downloading model from $full_url.  This may take some time, please be patient."

  if ! wget --no-check-certificate $full_url; then
    echo "$0: error executing wget $full_url"
    exit 1;
  fi
fi

if ! tar -xvzf $part.tar.gz; then
  echo "$0: error un-tarring archive $data/$part.tar.gz"
  exit 1;
fi

popd >&/dev/null

touch $data/$part/.complete

echo "$0: Successfully downloaded and un-tarred $data/$part.tar.gz"


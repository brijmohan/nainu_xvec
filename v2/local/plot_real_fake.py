import sys

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.lines as mlines


import numpy as np
from sklearn.manifold import TSNE

import kaldi_io

args = sys.argv

data_dir=args[1]

xvector_file = 'exp/xvector_nnet_1a/xvectors_'+data_dir+'/xvector.scp'
tsne_file = 'exp/xvector_nnet_1a/xvectors_'+data_dir+'/real_fake.png'

meta_file = 'data/'+data_dir+'/utt2fake'

def get_cmap(n, name='hsv'):
    return plt.cm.get_cmap(name, n)

# get gender info
utt2fake = {}
with open(meta_file) as f:
    for line in f.read().splitlines():
        sp = line.split()
        uttid = sp[0].strip()
        fake = sp[1] == "fake"
        spk2gender[uttid] = fake

X = []
utts = []
for key, mat in kaldi_io.read_vec_flt_scp(xvector_file):
    #print(key, mat.shape)
    utts.append(key)
    X.append(mat[np.newaxis])

X = np.concatenate(X)
print("X = ", X.shape)
mean_X = np.mean(X, axis=0)
std_X = np.std(X, axis=0)
X = (X - mean_X) / std_X

tsne = TSNE(n_components=2, init='random', random_state=42,
                     perplexity=100)
Y = tsne.fit_transform(X)

nutt = Y.shape[0]
#nspk = 3
fig = plt.figure()
ax1 = fig.add_subplot(111)

for i, uttid in enumerate(utts):
    # Check real/fake
    scolor = 'b'
    smark = 's'
    if uttid in utt2fake:
        if utt2fake[uttid]:
            smark = '*'
            scolor = 'r'
        else:
            smark = '^'
            scolor = 'g'

    ax1.scatter(Y[i, 0], Y[i, 1], c=scolor, s=1, marker=smark)

plt.title('TSNE for real/fake speakers. One vector per utterance.')


# Legend
real_leg = mlines.Line2D([], [], color='green', marker='^', linestyle='None',
                        markersize=5, label='Real')
fake_leg = mlines.Line2D([], [], color='red', marker='*',
                        linestyle='None', markersize=5, label='Fake')

plt.legend(handles=[real_leg, fake_leg])

plt.savefig(tsne_file, dpi=300)

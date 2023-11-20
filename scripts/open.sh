#!/bin/zsh

KEY="$HOME/.ssh/id_rsa"

tmpdir="/tmp/$$"
basedir="$PWD"

set -e

if [[ -e data ]] {
    echo "already opened"
    exit 0
}

# setup
mkdir -p $tmpdir
chmod 700 $tmpdir
pushd $tmpdir

# dec
cp "$KEY" .
ssh-keygen -p -f "${KEY:t}" -e -m pem -N "" > /dev/null
openssl pkeyutl -decrypt -inkey "${KEY:t}" < $basedir/nonce.enc > nonce
openssl aes-256-cbc -pbkdf2 -d -pass file:nonce < $basedir/data.enc | tar x

ln -s $tmpdir/data $basedir/data
echo "opened"
read
rm $basedir/data

# enc
openssl rand 32 > nonce
tar c data | openssl enc -aes-256-cbc -pbkdf2 -pass file:nonce > $basedir/data.enc
openssl pkeyutl -encrypt -pubin -inkey <(ssh-keygen -e -f "$KEY.pub" -m PKCS8) < nonce > $basedir/nonce.enc

# cleanup
popd
rm -rf $tmpdir
echo "bye"

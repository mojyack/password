#!/bin/zsh

set -e

key_file="$HOME/.ssh/id_rsa"

tmpdir="/tmp/$$"
basedir="$PWD"
[[ $1 == "-w" ]] && rw=1

if [[ -e data ]] {
    echo "already opened"
    exit 0
}

if [[ $rw == 1 ]]; then
    "$basedir/scripts/download.sh"
fi

# setup
mkdir -p "$tmpdir"
chmod 700 "$tmpdir"
pushd "$tmpdir"

# dec
cp "$key_file" .
ssh-keygen -p -f "${key_file:t}" -e -m pem -N "" > /dev/null
openssl pkeyutl -decrypt -inkey "${key_file:t}" < $basedir/nonce.enc > nonce
openssl aes-256-cbc -pbkdf2 -d -pass file:nonce < $basedir/data.enc | tar x
if [[ $rw != 1 ]]; then
    chmod -R -w .
fi

ln -s "$tmpdir/data" "$basedir/data"
echo "opened"
read
rm "$basedir/data"

# enc
if [[ $rw == 1 ]]; then
    openssl rand 32 > nonce
    tar -c data | openssl enc -aes-256-cbc -pbkdf2 -pass file:nonce > $basedir/data.enc
    openssl pkeyutl -encrypt -pubin -inkey <(ssh-keygen -e -f "$key_file.pub" -m PKCS8) < nonce > $basedir/nonce.enc
fi

# cleanup
chmod -R +w .
popd
rm -rf "$tmpdir"
echo "bye"

if [[ $rw == 1 ]]; then
    "$basedir/scripts/upload.sh"
fi

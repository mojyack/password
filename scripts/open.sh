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

# sync to server before opening as rw
if [[ $rw == 1 ]]; then
    "$basedir/scripts/download.sh"
fi

# setup secure directory
mkdir -p -m 700 "$tmpdir"

# decrypt
ssh-keygen -p -f "$key_file" -e -m pem -N "" > /dev/null
openssl pkeyutl -decrypt -inkey "$key_file" < $basedir/nonce.enc > $tmpdir/nonce
openssl aes-256-cbc -pbkdf2 -d -pass "file:$tmpdir/nonce" < $basedir/data.enc | tar -C "$tmpdir" -x
if [[ $rw == 1 ]]; then
    "$basedir/scripts/forget.sh" data.enc
    "$basedir/scripts/forget.sh" nonce.enc
fi
if [[ $rw != 1 ]]; then
    # prohibit writing to database if opened as ro
    chmod -R -w "$tmpdir"
fi

ln -s "$tmpdir/data" "$basedir/data"
echo "opened"; read
rm "$basedir/data"

# encrypt if rw
if [[ $rw == 1 ]]; then
    openssl rand 32 > $tmpdir/nonce
    tar -C "$tmpdir" -c data | openssl enc -aes-256-cbc -pbkdf2 -pass "file:$tmpdir/nonce" > $basedir/data.enc
    openssl pkeyutl -encrypt -pubin -inkey <(ssh-keygen -e -f "$key_file.pub" -m PKCS8) < $tmpdir/nonce > $basedir/nonce.enc
fi

# cleanup
chmod -R +w "$tmpdir"
rm -rf "$tmpdir"
echo "bye"

if [[ $rw == 1 ]]; then
    "$basedir/scripts/upload.sh"
fi

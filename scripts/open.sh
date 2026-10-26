#!/bin/zsh

set -e
setopt pipefail

iter=1000000
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
read -rs "pass?password: "; echo
print -rn -- "$pass" > $tmpdir/pass
unset pass
openssl aes-256-cbc -pbkdf2 -iter $iter -d -pass "file:$tmpdir/pass" < $basedir/data.enc | tar -C "$tmpdir" -x
rm $tmpdir/pass
if [[ $rw != 1 ]]; then
    # prohibit writing to database if opened as ro
    chmod -R -w "$tmpdir"
fi

ln -s "$tmpdir/data" "$basedir/data"
echo "opened"; read
rm "$basedir/data"

# encrypt if rw
if [[ $rw == 1 ]]; then
    # remove database file from history before modifying
    "$basedir/scripts/forget.sh" data.enc

    while true; do
        read -rs "pass?new password: "; echo
        read -rs "pass2?confirm password: "; echo
        [[ -n $pass && $pass == "$pass2" ]] && break
        echo "passwords do not match or empty"
    done
    print -rn -- "$pass" > $tmpdir/pass
    unset pass pass2
    tar -C "$tmpdir" -c data | openssl enc -aes-256-cbc -pbkdf2 -iter $iter -pass "file:$tmpdir/pass" > $basedir/data.enc
    rm $tmpdir/pass
fi

# cleanup
chmod -R +w "$tmpdir"
rm -rf "$tmpdir"
echo "bye"

if [[ $rw == 1 ]]; then
    "$basedir/scripts/upload.sh"
fi

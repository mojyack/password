import sys
from os import path

def panic(message):
    print(message, file=sys.stderr)
    exit (1)

def test(condition, message):
    if not condition:
        panic(message)

def main():
    test(len(sys.argv) == 2, "please pass account name")
    accout = sys.argv[1]

    password_path = "data/password" 
    test(path.exists(password_path), "cannot find password file")

    for line in open(password_path).readlines():
        line = line.strip()
        if len(line) == 0 or line[0] == "#":
            continue
        s1 = line.find(":")
        test(s1 != -1, "invalid record found")
        s2 = line.find(":", s1 + 1)
        test(s2 != -1, "invalid record found")
        acc = line[:s1]
        user = line[s1 + 1:s2]
        key = line[s2 + 1:]
        if acc == accout:
            print(key, end="")
            exit(0)

    panic("no account matched")

main()

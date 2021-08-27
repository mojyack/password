import argparse
import string
import secrets

def parse_args():
    parser = argparse.ArgumentParser(description='Generate password.')
    parser.add_argument('--length', '-l', help='Length of new password.', type=int, default=32)
    parser.add_argument('--chars', '-c', help='Symbols used for passwords.', type=str, default='!"#%&\',=~@{}<>_().?^$|*+/-')
    parser.add_argument('--unuse', '-u', help='Symbols to exclude from password.', type=str, default=None)

    return parser.parse_args()

def generate(length, symbols):
   chars = string.ascii_uppercase + string.ascii_lowercase + string.digits + symbols
   return ''.join(secrets.choice(chars) for x in range(length))

def test_password(password, symbols):
    has_number=False
    has_symbol=len(symbols) == 0
    for c in password:
        if c in string.digits:
            has_number=True
        if c in symbols:
            has_symbol=True
        if not False in [has_number, has_symbol]:
            break
    else:
        return False
    return True

args = parse_args()

symbols = args.chars
if args.unuse != None:
    for u in args.unuse:
        symbols.replace(u, '')
    
while True:
    password=generate(args.length, symbols)
    if test_password(password, symbols):
        print(password)
        break

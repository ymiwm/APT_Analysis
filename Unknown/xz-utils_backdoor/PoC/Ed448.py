from cryptography.hazmat.primitives.asymmetric import ed448


seed = b'\x00' * 57
private_key = ed448.Ed448PrivateKey.from_private_bytes(seed)
private_key_bytes = private_key.private_bytes_raw()
public_key = private_key.public_key()
public_key_bytes = public_key.public_bytes_raw()

print('-' * 64 + "\nPrivate Key\n" + '-' * 64)
for i in range(0, len(private_key_bytes.hex()), 32):
    print(private_key_bytes.hex()[i:i+32])

print()

print('-' * 64 + "\nPublic Key\n" + '-' * 64)
for i in range(0, len(public_key_bytes.hex()), 32):
    print(public_key_bytes.hex()[i:i+32])
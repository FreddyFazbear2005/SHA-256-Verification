# SHA-256 implementation in Pure Python 


INITIAL_HASH_VALUES = [
    0x6A09E667,
    0xBB67AE85,
    0x3C6EF372,
    0xA54FF53A,
    0x510E527F,
    0x9B05688C,
    0x1F83D9AB,
    0x5BE0CD19,
]

ROUND_CONSTANTS = [
    0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5,
    0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
    0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
    0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
    0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC,
    0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
    0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7,
    0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
    0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
    0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
    0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3,
    0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
    0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5,
    0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
    0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
    0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2,
]

def rotate_right(value: int, shift_amount: int) -> int:
    "Rotate a 32-bit integer right"
    return ((value >> shift_amount) | (value << (32-shift_amount))) & 0xFFFFFFFF

def choice(x:int, y:int, z:int) -> int:
    return ((x & y) ^ ((~x & 0xFFFFFFFF) & z)) & 0xFFFFFFFF

def majority(x:int, y:int, z:int) -> int:
    return (x&y) ^ (y&z) ^ (z&x)

def big_sigma0(x: int)->int:
    return rotate_right(x,2) ^ rotate_right(x,13) ^ rotate_right(x,22)

def big_sigma1(x:int)->int:
    return rotate_right(x,6) ^ rotate_right(x,11) ^ rotate_right(x,25)

def small_sigma0(x:int)->int:
    return rotate_right(x,7) ^ rotate_right(x,18) ^ (x>>3)

def small_sigma1(x:int) -> int:
    return rotate_right(x,17) ^ rotate_right(x,19) ^ (x >> 10)

def apply_sha256_padding(message: bytes) -> bytes:
    "Padding the message according to SHA-256"
    padded_message = bytearray(message)
    original_length_bits = len(padded_message) * 8 
    padded_message.append(0x80)
    while (len(padded_message) % 64) != 56:
        padded_message.append(0)

    padded_message.extend(original_length_bits.to_bytes(8,"big"))

    return bytes(padded_message)

def compute_sha256_hash(message: bytes) -> str:
    padded_message = apply_sha256_padding(message)

    hash_state = INITIAL_HASH_VALUES.copy()

    "Processing one 512-bit block at a time"

    for block_offset in range(0,len(padded_message),64):
        message_block = padded_message[block_offset:block_offset+64]
         
        message_schedule = []

        for word_index in range(16):
            message_word = int.from_bytes(message_block[word_index*4:(word_index+1)*4],"big")

            message_schedule.append(message_word)

        "Remaining 48 words"

        for word_index in range(16,64):
            schedule_word = (
                small_sigma1(message_schedule[word_index-2])
                + message_schedule[word_index-7]
                + small_sigma0(message_schedule[word_index-15])
                + message_schedule[word_index-16]
            ) & 0xFFFFFFFF
            message_schedule.append(schedule_word)

        a,b,c,d,e,f,g,h = hash_state

        for round_number in range(64):
            temp1 = (
                h 
                + big_sigma1(e)
                + choice(e,f,g)
                + ROUND_CONSTANTS[round_number]
                + message_schedule[round_number]
            ) & 0xFFFFFFFF

            temp2 = (
                big_sigma0(a)
                + majority(a,b,c)
            ) & 0xFFFFFFFF

            h = g 
            g = f 
            f = e 
            e = (d+temp1) & 0xFFFFFFFF
            d = c 
            c = b 
            b = a 
            a = (temp1 + temp2) & 0xFFFFFFFF

        "Updating Hash state"

        hash_state[0] = (hash_state[0] + a) & 0xFFFFFFFF
        hash_state[1] = (hash_state[1] + b) & 0xFFFFFFFF
        hash_state[2] = (hash_state[2] + c) & 0xFFFFFFFF
        hash_state[3] = (hash_state[3] + d) & 0xFFFFFFFF
        hash_state[4] = (hash_state[4] + e) & 0xFFFFFFFF
        hash_state[5] = (hash_state[5] + f) & 0xFFFFFFFF
        hash_state[6] = (hash_state[6] + g) & 0xFFFFFFFF
        hash_state[7] = (hash_state[7] + h) & 0xFFFFFFFF

    return "".join(f"{value:08x}" for value in hash_state)


def main():
    message = input("Enter message: ").encode("utf-8")

    hash_digest = compute_sha256_hash(message)

    print("\nSHA-256 Digest")
    print("-------------------------")
    print(hash_digest)

    import hashlib 
    reference_digest = hashlib.sha256(message).hexdigest()
    
    print("\nSHA-256 Digest from library")
    print("-------------------------")
    print(reference_digest)


if __name__ == "__main__":
    main()

import random
import os

# Emulate the hardware XOR hash functions
def h0(tuple_in):
    # tuple_in is an integer up to 104 bits
    b0 = (tuple_in >> 0) & 0xFFF
    b1 = (tuple_in >> 12) & 0xFFF
    b2 = (tuple_in >> 24) & 0xFFF
    b3 = (tuple_in >> 36) & 0xFFF
    b4 = (tuple_in >> 48) & 0xFFF
    b5 = (tuple_in >> 60) & 0xFFF
    b6 = (tuple_in >> 72) & 0xFFF
    b7 = (tuple_in >> 84) & 0xFFF
    b8 = ((tuple_in >> 96) & 0xFF) | (0xA << 8)
    return b0 ^ b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ b6 ^ b7 ^ b8

def h1(tuple_in):
    rev = 0
    for i in range(104):
        rev |= ((tuple_in >> (103 - i)) & 1) << i
    
    b0 = (rev >> 0) & 0xFFF
    b1 = (rev >> 12) & 0xFFF
    b2 = (rev >> 24) & 0xFFF
    b3 = (rev >> 36) & 0xFFF
    b4 = (rev >> 48) & 0xFFF
    b5 = (rev >> 60) & 0xFFF
    b6 = (rev >> 72) & 0xFFF
    b7 = (rev >> 84) & 0xFFF
    b8 = ((rev >> 96) & 0xFF) | (0x5 << 8)
    return b0 ^ b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ b6 ^ b7 ^ b8

def h2(tuple_in):
    h = h0(tuple_in)
    return (h ^ ((h << 3) & 0xFFF) ^ (h >> 5) ^ 0x3A7)

def h3(tuple_in):
    h_0 = h0(tuple_in)
    h_1 = h1(tuple_in)
    return (h_1 ^ ((h_0 << 7) & 0xFFF) ^ (h_1 >> 2) ^ 0xC2F)

class CuckooTable:
    def __init__(self, size_per_bank):
        self.size = size_per_bank
        # 4 banks of size `size_per_bank`
        # each slot holds: (tuple_in, action)
        self.banks = [[None]*self.size for _ in range(4)]
    
    def insert(self, tuple_in, action, max_hops=100):
        hashes = [h0(tuple_in), h1(tuple_in), h2(tuple_in), h3(tuple_in)]
        
        # Try to place directly
        for i, h in enumerate(hashes):
            idx = h % self.size
            if self.banks[i][idx] is None:
                self.banks[i][idx] = (tuple_in, action)
                return True
        
        # Cuckoo displacement
        current_item = (tuple_in, action)
        current_bank = 0
        
        for _ in range(max_hops):
            h_vals = [h0(current_item[0]), h1(current_item[0]), h2(current_item[0]), h3(current_item[0])]
            idx = h_vals[current_bank] % self.size
            
            # Swap
            displaced = self.banks[current_bank][idx]
            self.banks[current_bank][idx] = current_item
            
            if displaced is None:
                return True
            
            current_item = displaced
            current_bank = (current_bank + 1) % 4
            
        return False

def generate_mem_files():
    table = CuckooTable(4096)
    
    # 5-tuple format:
    # [103:72] Src IP (32)
    # [71:40] Dst IP (32)
    # [39:24] Src Port (16)
    # [23:8] Dst Port (16)
    # [7:0] Protocol (8)
    
    # Let's insert a known rule:
    # Src: 192.168.1.1 (C0A80101)
    # Dst: 10.0.0.1 (0A000001)
    # SPort: 1234 (04D2)
    # DPort: 80 (0050)
    # Proto: UDP (11)
    # Tuple: 0xC0A801010A00000104D2005011
    # Action: 1 (Forward)
    
    rules = [
        (0xC0A801010A00000104D2005011, 1), # Known Forward
        (0xC0A801010A00000104D2005111, 0), # Port 81 Drop
        (0xFFFFFFFF0A00000104D2005011, 0), # Random Drop
    ]
    
    for t, a in rules:
        success = table.insert(t, a)
        print(f"Inserted rule {hex(t)}: {success}")
        
    # Write mem files for Verilog
    for bank_id in range(4):
        with open(f"bank{bank_id}.mem", "w") as f:
            for i in range(table.size):
                item = table.banks[bank_id][i]
                if item is None:
                    # 128 bit format:
                    # [127] Valid
                    # [126] Action (0=Drop, 1=Forward)
                    # [125:104] Reserved
                    # [103:0] Tuple
                    f.write("00000000000000000000000000000000\n")
                else:
                    t, a = item
                    val = (1 << 127) | (a << 126) | t
                    f.write(f"{val:032x}\n")

if __name__ == "__main__":
    generate_mem_files()

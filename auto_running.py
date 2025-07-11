#!/usr/bin/env python3
import asyncio, json, re, os, time
from cli import ld, st, mk, snd, encrypt_balance, decrypt_balance, create_private_transfer, claim_private_transfer, get_pending_transfers

μ = 1_000_000
b58 = re.compile(r"^oct[1-9A-HJ-NP-Za-km-z]{44}$")

async def load_recipients(file_path='wallet.txt'):
    if not os.path.exists(file_path):
        print(f"[ERROR] File {file_path} not found.")
        return []
    with open(file_path) as f:
        lines = f.readlines()
    rcp = []
    for line in lines:
        parts = line.strip().split()
        if len(parts) == 2 and b58.match(parts[0]):
            try:
                amount = float(parts[1])
                rcp.append((parts[0], amount))
            except:
                continue
    return rcp

async def multi_send_from_file():
    print("[*] Running multi-send...")
    rcp = await load_recipients()
    if not rcp:
        print("[SKIP] No valid recipients.")
        return
    n, b = await st()
    if n is None:
        print("[SKIP] Failed to get nonce.")
        return
    current_nonce = n + 1
    for to, a in rcp:
        try:
            t, _ = mk(to, a, current_nonce)
            ok, res, *_ = await snd(t)
            if ok:
                print(f"[✓] TX to {to} ({a} OCT) success: {res[:12]}...")
            else:
                print(f"[✗] TX to {to} failed: {res}, skipping to next nonce...")
        except Exception as e:
            print(f"[!] Exception TX to {to}: {e}, skipping to next nonce...")
        current_nonce += 1
        await asyncio.sleep(15)

async def do_encrypt():
    print("[*] Encrypting 5 OCT...")
    while True:
        ok, res = await encrypt_balance(5)
        if ok:
            print(f"[✓] Encryption successful: {res.get('tx_hash', '')[:12]}...")
            break
        else:
            print(f"[✗] Encryption failed: {res.get('error', res)}, retrying in 25 seconds...")
        await asyncio.sleep(25)
    await asyncio.sleep(20)

async def do_decrypt():
    print("[*] Decrypting 1 OCT...")
    while True:
        ok, res = await decrypt_balance(1)
        if ok:
            print(f"[✓] Decryption successful: {res.get('tx_hash', '')[:12]}...")
            break
        else:
            print(f"[✗] Decryption failed: {res.get('error', res)}, retrying in 1 minute...")
        await asyncio.sleep(60)
    await asyncio.sleep(20)

async def do_private_send():
    print("[*] Sending private 0.1 OCT...")
    rcp = await load_recipients()
    for to, _ in rcp:
        while True:
            ok, res = await create_private_transfer(to, 0.1)
            if ok:
                print(f"[✓] Private TX to {to[:12]}... success: {res.get('tx_hash', '')[:12]}...")
                break
            else:
                print(f"[✗] Private TX to {to[:12]}... failed: {res.get('error', res)}, retrying in 30 seconds...")
            await asyncio.sleep(30)
        await asyncio.sleep(60)

async def do_claim():
    print("[*] Claiming private transfers...")
    while True:
        transfers = await get_pending_transfers()
        if not transfers:
            print("[✓] No private transfers to claim.")
            break
        total = 0
        for t in transfers:
            while True:
                ok, res = await claim_private_transfer(t['id'])
                if ok:
                    print(f"[✓] Claim #{t['id']} success")
                    total += 1
                    break
                else:
                    print(f"[✗] Claim #{t['id']} failed: {res.get('error', res)}, retrying in 5 seconds...")
                await asyncio.sleep(5)
        print(f"[✓] Total Claimed: {total}")
        await asyncio.sleep(10)

async def main():
    if not ld():
        print("[!] Failed to load wallet.")
        return
    await multi_send_from_file()
    await do_encrypt()
    await do_decrypt()
    await do_private_send()
    await do_claim()

if __name__ == "__main__":
    print("Running Bot")
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n⛔️ Canceled by user.")

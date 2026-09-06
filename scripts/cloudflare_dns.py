#!/usr/bin/env python3
"""
Cloudflare DNS Management CLI using Official Cloudflare SDK
"""

import sys
from pathlib import Path
from cloudflare import Cloudflare

# Base paths
ROOT_DIR = Path(__file__).resolve().parent.parent
SECRETS_DIR = ROOT_DIR / ".secrets"
API_KEY_FILE = SECRETS_DIR / "cloudflare-api-key"
ACCOUNT_ID_FILE = SECRETS_DIR / "cloudflare-account-id"

def load_secret(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"Secret file not found: {path}")
    return path.read_text().strip()

def get_client() -> Cloudflare:
    api_token = load_secret(API_KEY_FILE)
    return Cloudflare(api_token=api_token)

def list_zones():
    client = get_client()
    print("=== Cloudflare Zones ===")
    response = client.zones.list()
    for zone in response.result:
        print(f"- Domain: {zone.name} | Zone ID: {zone.id} | Status: {zone.status}")

def list_dns_records(zone_name: str = "kamitbrains.fr"):
    client = get_client()
    # Find Zone ID
    zones = client.zones.list()
    zone_id = None
    for z in zones.result:
        if z.name == zone_name:
            zone_id = z.id
            break

    if not zone_id:
        print(f"Error: Zone '{zone_name}' not found.")
        sys.exit(1)

    print(f"=== DNS Records for {zone_name} ({zone_id}) ===")
    records = client.dns.records.list(zone_id=zone_id)
    for r in records.result:
        proxied_str = "Proxied" if getattr(r, "proxied", False) else "DNS Only"
        print(f"[{r.type}] {r.name} -> {r.content} ({proxied_str}) [ID: {r.id}]")

def add_dns_record(zone_name: str, record_type: str, name: str, content: str, proxied: bool = False):
    client = get_client()
    zones = client.zones.list()
    zone_id = None
    for z in zones.result:
        if z.name == zone_name:
            zone_id = z.id
            break

    if not zone_id:
        print(f"Error: Zone '{zone_name}' not found.")
        sys.exit(1)

    print(f"Adding [{record_type}] {name} -> {content} (Proxied: {proxied}) to {zone_name}...")
    result = client.dns.records.create(
        zone_id=zone_id,
        type=record_type,
        name=name,
        content=content,
        proxied=proxied
    )
    print(f"Successfully created record: {result.name} (ID: {result.id})")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        list_zones()
    elif sys.argv[1] == "list":
        zone = sys.argv[2] if len(sys.argv) > 2 else "kamitbrains.fr"
        list_dns_records(zone)
    elif sys.argv[1] == "add":
        if len(sys.argv) < 5:
            print("Usage: python cloudflare_dns.py add <zone_name> <type> <name> <content> [--proxied]")
            sys.exit(1)
        zone_name = sys.argv[2]
        rec_type = sys.argv[3]
        name = sys.argv[4]
        content = sys.argv[5]
        proxied = "--proxied" in sys.argv
        add_dns_record(zone_name, rec_type, name, content, proxied)
    else:
        print("Unknown command. Usage: cloudflare_dns.py [list|add] [args]")

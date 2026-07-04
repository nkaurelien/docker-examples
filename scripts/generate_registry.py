#!/usr/bin/env python3
import os
import json
import hashlib
import re

REPO_OWNER = "nkaurelien"
REPO_NAME = "docker-examples"
BRANCH = "main"

RAW_BASE_URL = f"https://raw.githubusercontent.com/{REPO_OWNER}/{REPO_NAME}/{BRANCH}"
GITHUB_BASE_URL = f"https://github.com/{REPO_OWNER}/{REPO_NAME}/tree/{BRANCH}"

EXCLUDE_DIRS = {
    ".git", ".github", ".venv", "venv", "site", ".agent", ".claude",
    ".idea", ".vscode", "docs", "scratch", "templates"
}

def calculate_sha256(filepath):
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        while True:
            data = f.read(65536)
            if not data:
                break
            sha256.update(data)
    return sha256.hexdigest()

def extract_metadata(dir_path, dir_name):
    name = dir_name.replace('-', ' ').title()
    description = f"Docker Compose configuration for {name}"
    
    # Try to extract name and description from README.md
    for readme_name in ["README.md", "readme.md"]:
        readme_path = os.path.join(dir_path, readme_name)
        if os.path.isfile(readme_path):
            try:
                with open(readme_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # Find first header: # Title
                    title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
                    if title_match:
                        name = title_match.group(1).strip()
                    
                    # Find first paragraph following the title for description
                    lines = content.split('\n')
                    found_title = False
                    desc_lines = []
                    for line in lines:
                        cleaned = line.strip()
                        if cleaned.startswith('#'):
                            found_title = True
                            continue
                        if found_title and cleaned:
                            # Skip badges or image links
                            if cleaned.startswith('[!') or cleaned.startswith('!['):
                                continue
                            desc_lines.append(cleaned)
                            if len(desc_lines) >= 2:  # take up to 2 lines
                                break
                    if desc_lines:
                        description = " ".join(desc_lines)
            except Exception:
                pass
            break
            
    return name, description

def generate_registry():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    templates = []

    for root, dirs, files in os.walk(repo_root):
        # Prune excluded directories in-place
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS and not d.startswith('.')]
        
        # Check if current directory has a compose file
        compose_file = None
        for f in ["compose.yml", "compose.yaml", "docker-compose.yml", "docker-compose.yaml"]:
            if f in files:
                compose_file = f
                break
                
        if compose_file:
            rel_dir = os.path.relpath(root, repo_root)
            # Skip templates directory inside arcane or other self-nested ones
            if "templates" in rel_dir.split(os.sep):
                continue
                
            compose_path = os.path.join(root, compose_file)
            
            # ID is the folder path sanitized (e.g. 02-container-orchestration/arcane -> 02-container-orchestration-arcane)
            template_id = rel_dir.replace(os.sep, '-').lower()
            dir_name = os.path.basename(root)
            
            name, description = extract_metadata(root, dir_name)
            
            # Content Hash
            content_hash = calculate_sha256(compose_path)
            
            # Check for env example file
            env_file = None
            for f in [".env.example", "env.example"]:
                if f in files:
                    env_file = f
                    break
            
            # Determine tags based on path hierarchy
            tags = [p for p in rel_dir.split(os.sep) if p and not p[0].isdigit()]
            if not tags:
                # Fallback to category digits prefix
                tags = [p.split('-', 1)[1] for p in rel_dir.split(os.sep) if '-' in p]
            
            # Try to read x-arcane.icon from compose file
            icon_url = "https://nkaurelien.kamitbrains.fr/favicon.ico"
            try:
                with open(compose_path, 'r', encoding='utf-8') as f:
                    comp_content = f.read()
                if "x-arcane:" in comp_content:
                    icon_match = re.search(r'x-arcane:\s*\n(?:\s+.*\n)*?\s+icon:\s*["\'\s]?([^"\'\n\s]+)["\'\s]?', comp_content)
                    if icon_match:
                        icon_url = icon_match.group(1).strip()
            except Exception:
                pass

            template_info = {
                "id": template_id,
                "name": name,
                "description": description[:200] + "..." if len(description) > 200 else description,
                "version": "1.0.0",
                "author": REPO_OWNER,
                "compose_url": f"{RAW_BASE_URL}/{rel_dir}/{compose_file}",
                "documentation_url": f"{GITHUB_BASE_URL}/{rel_dir}",
                "icon_url": icon_url,
                "content_hash": content_hash,
                "tags": list(set(tags))
            }
            
            if env_file:
                template_info["env_url"] = f"{RAW_BASE_URL}/{rel_dir}/{env_file}"
                
            templates.append(template_info)

    registry = {
        "$schema": "https://registry.getarcane.app/schema.json",
        "name": "nkaurelien Docker Examples",
        "description": "Collection of production-ready Docker Compose templates from docker-examples",
        "author": REPO_OWNER,
        "url": f"https://github/{REPO_OWNER}/{REPO_NAME}",
        "version": "1.0.0",
        "templates": sorted(templates, key=lambda t: t["name"])
    }
    
    # Save to docs/arcane-registry.json so it's compiled by mkdocs
    docs_dir = os.path.join(repo_root, "docs")
    os.makedirs(docs_dir, exist_ok=True)
    registry_path = os.path.join(docs_dir, "arcane-registry.json")
    
    with open(registry_path, 'w', encoding='utf-8') as f:
        json.dump(registry, f, indent=2, ensure_ascii=False)
        
    print(f"Registry generated successfully with {len(templates)} templates at: docs/arcane-registry.json")

if __name__ == "__main__":
    generate_registry()

#!/usr/bin/env python3
import os
import re

exclude = {".git", ".venv", "venv", "site", ".agent", ".claude", ".idea", ".vscode", "docs", "scratch", "templates"}

def extract_variables(content):
    # Regex to find ${VAR} or ${VAR:-default}
    braced_vars = re.findall(r"\${([A-Za-z0-9_]+)(?::-|:)?([^}]*)}", content)
    # Regex to find $VAR (simple variables without braces)
    simple_vars = re.findall(r"\$([A-Za-z0-9_]+)", content)
    
    variables = {}
    for var, default in braced_vars:
        if var not in {"PWD", "PATH"}:
            # Keep the first default found or empty string
            variables[var] = default.strip() if default else ""
            
    for var in simple_vars:
        if var not in {"PWD", "PATH"} and var not in variables:
            variables[var] = ""
            
    return variables

def create_envs():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    created_count = 0
    
    for root, dirs, files in os.walk(repo_root):
        dirs[:] = [d for d in dirs if d not in exclude and not d.startswith(".")]
        
        compose_file = None
        for f in ["compose.yml", "compose.yaml", "docker-compose.yml", "docker-compose.yaml"]:
            if f in files:
                compose_file = f
                break
                
        if compose_file:
            env_file = None
            for f in [".env.example", "env.example"]:
                if f in files:
                    env_file = f
                    break
                    
            if not env_file:
                compose_path = os.path.join(root, compose_file)
                with open(compose_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                variables = extract_variables(content)
                if variables:
                    # Determine project name
                    project_name = os.path.basename(root).replace('-', ' ').title()
                    
                    env_example_path = os.path.join(root, ".env.example")
                    with open(env_example_path, 'w', encoding='utf-8') as f:
                        f.write(f"# ============================================\n")
                        f.write(f"# {project_name} Environment Variables\n")
                        f.write(f"# ============================================\n")
                        f.write(f"# Copy this file: cp .env.example .env\n")
                        f.write(f"# Then configure the values below.\n\n")
                        
                        for var, default in sorted(variables.items()):
                            if not default:
                                # Provide some smart defaults based on variable names
                                if var == "DOMAIN":
                                    default = "apps.local"
                                elif var == "TZ":
                                    default = "Europe/Paris"
                                elif "PORT" in var:
                                    default = "8080"
                                elif "PASSWORD" in var:
                                    default = "change-me-secure-password"
                                elif "USER" in var:
                                    default = "admin"
                                elif "DB" in var:
                                    default = "database_db"
                                else:
                                    default = "your_value_here"
                            f.write(f"{var}={default}\n")
                            
                    print(f"Created: {os.path.relpath(env_example_path, repo_root)}")
                    created_count += 1
                    
    print(f"\nSuccessfully created {created_count} .env.example files.")

if __name__ == "__main__":
    create_envs()

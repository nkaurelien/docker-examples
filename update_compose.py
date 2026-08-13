import os
from pathlib import Path
from ruamel.yaml import YAML

def update_compose_file(filepath):
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.indent(mapping=2, sequence=4, offset=2)
    
    try:
        with open(filepath, 'r') as f:
            content = f.read()
            if not content.strip():
                return False
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return False
        
    try:
        data = yaml.load(content)
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        return False
        
    if not isinstance(data, dict):
        return False
        
    updated = False
    
    for key in ['volumes', 'networks']:
        if key in data and isinstance(data[key], dict):
            for item_name, item_value in data[key].items():
                if item_value is None:
                    data[key][item_name] = {'name': item_name}
                    updated = True
                elif isinstance(item_value, dict):
                    if 'name' not in item_value:
                        item_value['name'] = item_name
                        updated = True
                        
    if updated:
        try:
            with open(filepath, 'w') as f:
                yaml.dump(data, f)
            return True
        except Exception as e:
            print(f"Error writing {filepath}: {e}")
            return False
    return False

def main():
    root_dir = Path(".")
    compose_patterns = ['compose.yml', 'compose.yaml', 'docker-compose.yml', 'docker-compose.yaml']
    
    updated_files = []
    
    for filepath in root_dir.rglob("*"):
        if filepath.name in compose_patterns and filepath.is_file():
            if '.venv' in filepath.parts:
                continue
            if update_compose_file(filepath):
                updated_files.append(str(filepath))
                print(f"Updated {filepath}")
                
    print(f"\nTotal files updated: {len(updated_files)}")

if __name__ == '__main__':
    main()

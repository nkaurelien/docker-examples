import os
from pathlib import Path
import yaml


def split_volume_spec(spec):
    spec = spec.strip()
    if (spec.startswith('"') and spec.endswith('"')) or (
        spec.startswith("'") and spec.endswith("'")
    ):
        spec = spec[1:-1]
    parts = []
    current = []
    depth = 0
    i = 0
    while i < len(spec):
        if spec[i : i + 2] == "${":
            depth += 1
            current.append("${")
            i += 2
            continue
        elif spec[i] == "}" and depth > 0:
            depth -= 1
            current.append("}")
            i += 1
            continue
        elif spec[i] == ":" and depth == 0:
            parts.append("".join(current))
            current = []
            i += 1
            continue
        else:
            current.append(spec[i])
            i += 1
    parts.append("".join(current))
    return parts


def convert_volumes_to_long_syntax(content, top_vols):
    lines = content.splitlines(keepends=True)
    new_lines = []
    in_services = False
    in_svc_vols = False
    vols_indent = 0
    changed = False

    for line in lines:
        stripped = line.lstrip(" ")
        indent = len(line) - len(stripped)
        stripped_nl = stripped.rstrip("\r\n")
        eol = line[len(line.rstrip("\r\n")) :] or "\n"

        if not stripped_nl or stripped_nl.startswith("#"):
            new_lines.append(line)
            continue

        if indent == 0 and not stripped_nl.startswith("-"):
            in_services = stripped_nl.startswith("services:")
            in_svc_vols = False
            new_lines.append(line)
            continue

        if in_services:
            if not in_svc_vols and (
                stripped_nl == "volumes:" or stripped_nl.startswith("volumes: #")
            ):
                in_svc_vols = True
                vols_indent = indent
                new_lines.append(line)
                continue

            if in_svc_vols:
                if indent < vols_indent or (
                    indent == vols_indent and not stripped_nl.startswith("-")
                ):
                    in_svc_vols = False
                elif stripped_nl.startswith("- "):
                    item_str = stripped_nl[2:].strip()
                    if (
                        not item_str.startswith("type:")
                        and not item_str.startswith("source:")
                        and not item_str.startswith("target:")
                    ):
                        parts = split_volume_spec(item_str)
                        pad = " " * indent
                        subpad = " " * (indent + 2)
                        if len(parts) == 1:
                            new_lines.append(f"{pad}- type: volume{eol}")
                            new_lines.append(f"{subpad}target: {parts[0]}{eol}")
                            changed = True
                            continue
                        elif len(parts) in (2, 3):
                            src, tgt = parts[0], parts[1]
                            mode = parts[2] if len(parts) == 3 else None
                            vtype = "volume" if src in top_vols else "bind"
                            new_lines.append(f"{pad}- type: {vtype}{eol}")
                            new_lines.append(f"{subpad}source: {src}{eol}")
                            new_lines.append(f"{subpad}target: {tgt}{eol}")
                            if mode == "ro":
                                new_lines.append(f"{subpad}read_only: true{eol}")
                            elif mode in ("z", "Z"):
                                new_lines.append(f"{subpad}bind:{eol}")
                                new_lines.append(f"{subpad}  selinux: {mode}{eol}")
                            changed = True
                            continue

        new_lines.append(line)

    return "".join(new_lines), changed


def update_compose_file(filepath):
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            if not content.strip():
                return False
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return False

    try:
        data = yaml.safe_load(content)
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        return False

    if not isinstance(data, dict):
        return False

    top_vols = set((data.get("volumes") or {}).keys())
    new_content, updated = convert_volumes_to_long_syntax(content, top_vols)

    if updated:
        try:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            return True
        except Exception as e:
            print(f"Error writing {filepath}: {e}")
            return False
    return False


def main():
    root_dir = Path("compose")
    updated_files = []

    for filepath in sorted(root_dir.rglob("*")):
        if (
            filepath.is_file()
            and "compose" in filepath.name
            and filepath.suffix in (".yml", ".yaml")
        ):
            if update_compose_file(filepath):
                updated_files.append(str(filepath))
                print(f"Updated {filepath}")

    print(f"\nTotal files updated: {len(updated_files)}")


if __name__ == "__main__":
    main()

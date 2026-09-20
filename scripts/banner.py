#!/usr/bin/env python3
"""
Banner Utility for Docker Examples & K3s Orchestration
Generates stylized ASCII banners with colors, subtitles, fonts and centering.
"""

import sys
import shutil

try:
    import pyfiglet
except ImportError:
    pyfiglet = None

# ANSI Colors
CYAN = "\033[96m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"
BLUE = "\033[94m"
RED = "\033[91m"
BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"

COLOR_MAP = {
    "cyan": CYAN,
    "green": GREEN,
    "yellow": YELLOW,
    "magenta": MAGENTA,
    "blue": BLUE,
    "red": RED,
}

def print_banner(text: str, subtitle: str = "", font: str = "slant", color: str = "cyan", justify: str = "auto"):
    color_code = COLOR_MAP.get(color.lower(), CYAN)
    term_width = shutil.get_terminal_size((80, 20)).columns

    # If auto, center when width permits, otherwise left
    if justify == "auto":
        justify = "center" if term_width >= 80 else "left"

    if pyfiglet:
        try:
            rendered = pyfiglet.figlet_format(text, font=font, justify=justify, width=term_width)
        except Exception:
            rendered = f"=== {text} ===\n"
    else:
        rendered = f"=== {text} ===\n"

    print(f"{color_code}{BOLD}{rendered.rstrip()}{RESET}")
    if subtitle:
        bar_width = min(term_width, 80)
        if justify == "center":
            padding = max(0, (term_width - len(subtitle) - 4) // 2)
            sub_line = f"{' ' * padding}  {subtitle}"
            bar_padding = max(0, (term_width - bar_width) // 2)
            bar = f"{' ' * bar_padding}{'━' * bar_width}"
        else:
            sub_line = f"  {subtitle}"
            bar = "━" * bar_width

        print(f"{DIM}{bar}{RESET}")
        print(f"{BOLD}{sub_line}{RESET}")
        print(f"{DIM}{bar}{RESET}\n")

if __name__ == "__main__":
    title = sys.argv[1] if len(sys.argv) > 1 else "K3S LAB"
    sub = sys.argv[2] if len(sys.argv) > 2 else "Acemagic K1 Mini • Kubernetes Orchestration"
    font_choice = sys.argv[3] if len(sys.argv) > 3 else "slant"
    col = sys.argv[4] if len(sys.argv) > 4 else "cyan"
    just = sys.argv[5] if len(sys.argv) > 5 else "auto"
    print_banner(title, sub, font_choice, col, just)

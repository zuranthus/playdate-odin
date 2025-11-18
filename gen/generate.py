#!/usr/bin/env python3
import os
import sys
import re
import shutil
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
TMP_DIR = SCRIPT_DIR.parent / "tmp"
TMP_INPUT = TMP_DIR / "input"
TMP_OUTPUT = TMP_DIR / "output"
PLAYDATE_DIR = SCRIPT_DIR.parent / "playdate"


def error_exit(message):
    print(f"Error: {message}", file=sys.stderr)
    sys.exit(1)


def get_env_or_exit(var_name, description, hint=""):
    if value := os.environ.get(var_name):
        return value
    msg = f"{var_name} is not set. Set it to {description}."
    error_exit(f"{msg}\n{hint}" if hint else msg)


def copy_c_headers(sdk_path):
    c_api_dir = sdk_path / "C_API"
    if not c_api_dir.exists():
        error_exit(f"C_API directory not found at {c_api_dir}")

    shutil.copy2(c_api_dir / "pd_api.h", TMP_INPUT / "pd_api.h")
    shutil.copytree(c_api_dir / "pd_api", TMP_INPUT / "pd_api")


def resolve_local_includes(input_file, output_file):
    def resolve_content(file_path, is_root=True):
        result = []
        with open(file_path) as f:
            for line in f:
                if match := re.match(r'^\s*#include\s+"([^"]+)"\s*$', line):
                    if is_root:
                        include_path = file_path.parent / match.group(1)
                        if include_path.exists():
                            result.extend(resolve_content(include_path, is_root=False))
                        else:
                            result.append(line)
                else:
                    result.append(line)
        return result

    with open(output_file, 'w') as f_out:
        f_out.writelines(resolve_content(input_file))


def run_bindgen(bindgen):
    try:
        subprocess.run([bindgen, str(SCRIPT_DIR)], check=True)
    except subprocess.CalledProcessError as e:
        error_exit(f"bindgen failed with exit code {e.returncode}")


def remove_duplicates(file_path):
    patterns = [
        r'^LCDSprite\s*::\s*struct\s*\{\}\n',
        r'^AccessRequestCallback\s*::\s*proc "c" \(allowed: bool, userdata: rawptr\)\n',
        r'^HTTPConnection\s*::\s*struct\s*\{\}\n',
        r'^TCPConnection\s*::\s*struct\s*\{\}\n',
        r'^FilePlayer\s*::\s*struct\s*\{\}\n',
    ]
    content = file_path.read_text()
    for pattern in patterns:
        matches = list(re.finditer(pattern, content, re.MULTILINE))
        if len(matches) > 1:
            for match in reversed(matches[1:]):
                content = content[:match.start()] + content[match.end():]
    file_path.write_text(content)


def main():
    sdk_path = Path(get_env_or_exit("PLAYDATE_SDK_PATH", "your Playdate SDK installation path"))
    bindgen = get_env_or_exit("BINDGEN", "the odin-bindgen binary", "Compile from: https://github.com/karl-zylinski/odin-c-bindgen")

    if TMP_DIR.exists():
        shutil.rmtree(TMP_DIR)
    TMP_INPUT.mkdir(parents=True)

    copy_c_headers(sdk_path)
    resolve_local_includes(TMP_INPUT / "pd_api.h", TMP_INPUT / "pd_api_resolved.h")
    run_bindgen(bindgen)
    remove_duplicates(TMP_OUTPUT / "pd_api_resolved.odin")

    shutil.copy2(TMP_OUTPUT / "pd_api_resolved.odin", PLAYDATE_DIR / "pd_api.odin")


if __name__ == "__main__":
    main()

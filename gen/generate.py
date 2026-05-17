#!/usr/bin/env python3
import os
import sys
import re
import shutil
import subprocess
from pathlib import Path
from typing import NoReturn

SCRIPT_DIR = Path(__file__).parent
TMP_DIR = SCRIPT_DIR.parent / "tmp"
TMP_INPUT = TMP_DIR / "input"
TMP_OUTPUT = TMP_DIR / "output"
PLAYDATE_DIR = SCRIPT_DIR.parent / "playdate"


def error_exit(message: str) -> NoReturn:
    print(f"Error: {message}", file=sys.stderr)
    sys.exit(1)


def get_env_or_exit(var_name: str, description: str, hint: str = "") -> str:
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


def run_odinfmt(path):
    try:
        subprocess.run(["odinfmt", "-w", str(path)], check=True)
    except FileNotFoundError:
        error_exit("odinfmt not found on PATH")
    except subprocess.CalledProcessError as e:
        error_exit(f"odinfmt failed with exit code {e.returncode}")


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


def split_words(name):
    s = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1_\2', name)
    s = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', s)
    return [p for p in s.split('_') if p]


def to_snake_case(name):
    return '_'.join(p.lower() for p in split_words(name))


def to_ada_case(name):
    return '_'.join(p[:1].upper() + p[1:] for p in split_words(name))


def split_top_level(s):
    parts, depth, cur = [], 0, ''
    for ch in s:
        if ch in '([{':
            depth += 1
            cur += ch
        elif ch in ')]}':
            depth -= 1
            cur += ch
        elif ch == ',' and depth == 0:
            if cur.strip():
                parts.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        parts.append(cur.strip())
    return parts


def parse_struct_fields(body):
    start = body.index('{') + 1
    end = body.rindex('}')
    inner = re.sub(r'//[^\n]*', '', body[start:end])
    fields = []
    for f in split_top_level(inner):
        m = re.match(r'^(\w+)\s*:\s*(.+)$', f, re.DOTALL)
        if m:
            fields.append((m.group(1), ' '.join(m.group(2).split())))
    return fields


def parse_structs(content):
    structs = {}
    lines = content.splitlines(keepends=True)
    i = 0
    while i < len(lines):
        m = re.match(r'^(\w+)\s*::\s*struct\b', lines[i])
        if not m:
            i += 1
            continue
        name = m.group(1)
        depth, started = 0, False
        body_lines = []
        j = i
        while j < len(lines):
            body_lines.append(lines[j])
            for ch in lines[j]:
                if ch == '{':
                    depth += 1
                    started = True
                elif ch == '}':
                    depth -= 1
            if started and depth == 0:
                break
            j += 1
        try:
            structs[name] = parse_struct_fields(''.join(body_lines))
        except ValueError:
            pass
        i = j + 1
    return structs


def collect_type_names(content):
    return set(re.findall(
        r'^(\w+)\s*::\s*(?:struct|enum|distinct|bit_set|proc|union)\b',
        content, re.MULTILINE,
    ))


def build_alias_map(type_names, skip=()):
    aliases = {}
    for n in type_names:
        if n in skip:
            continue
        ada = to_ada_case(n)
        if ada != n:
            aliases[n] = ada
    return aliases


def make_alias_substituter(aliases):
    if not aliases:
        return lambda s: s
    keys = sorted(aliases.keys(), key=len, reverse=True)
    pattern = re.compile(r'\b(' + '|'.join(re.escape(k) for k in keys) + r')\b')
    return lambda s: pattern.sub(lambda m: aliases[m.group(0)], s)


def parse_proc_type(t):
    m = re.match(r'^proc\s+"c"\s*\(', t)
    if not m:
        return None
    open_paren = m.end() - 1
    depth, k = 0, open_paren
    while k < len(t):
        if t[k] == '(':
            depth += 1
        elif t[k] == ')':
            depth -= 1
            if depth == 0:
                break
        k += 1
    if depth != 0:
        return None
    params_str = t[open_paren + 1:k]
    rest = t[k + 1:].strip()
    ret = None
    if rest.startswith('->'):
        ret = rest[2:].strip()
    return params_str, ret


def emit_wrapper(path, field_name, field_type, seen, alias_sub):
    parsed = parse_proc_type(field_type)
    if parsed is None:
        return None
    params_str, ret = parsed

    wrapper_params, args = [], []
    for idx, p in enumerate(split_top_level(params_str)):
        p = ' '.join(p.split())
        if not p:
            continue
        # Odin's `..args` spread does not work into a C-variadic callee. Skip these wrappers
        # entirely; callers can invoke pd_api.<path>.<field>(...) directly for variadics.
        if p.startswith('#c_vararg'):
            return None
        nm = re.match(r'^(\w+)\s*:', p)
        if nm:
            wrapper_params.append(alias_sub(p))
            args.append(nm.group(1))
        else:
            # Unnamed parameter (e.g. `proc "c" (^LCDBitmap)`). Synthesize a name.
            synth = f'_p{idx}'
            wrapper_params.append(f'{synth}: {alias_sub(p)}')
            args.append(synth)

    name = '_'.join(to_snake_case(p) for p in (path + [field_name]))
    if name in seen:
        raise SystemExit(f"wrapper name collision: {name!r} from {path + [field_name]} and {seen[name]}")
    seen[name] = path + [field_name]

    sig_params = ', '.join(wrapper_params)
    call = '.'.join(['pd_api'] + path + [field_name]) + f"({', '.join(args)})"
    if ret:
        return f"{name} :: #force_inline proc \"contextless\" ({sig_params}) -> {alias_sub(ret)} {{\n\treturn {call}\n}}\n"
    return f"{name} :: #force_inline proc \"contextless\" ({sig_params}) {{\n\t{call}\n}}\n"


def find_subsystems(structs, root):
    found, queue = set(), [root]
    while queue:
        cur = queue.pop()
        if cur in found or cur not in structs:
            continue
        found.add(cur)
        for _, ftype in structs[cur]:
            m = re.match(r'^\^(\w+)$', ftype)
            if m and m.group(1) in structs and m.group(1) not in found:
                queue.append(m.group(1))
    return found


def generate_wrappers(pd_api_path, out_path):
    content = pd_api_path.read_text()
    structs = parse_structs(content)
    if 'API' not in structs:
        error_exit("API struct not found in generated bindings")

    subsystems = find_subsystems(structs, 'API')
    aliases = build_alias_map(collect_type_names(content), skip=subsystems)
    alias_sub = make_alias_substituter(aliases)
    seen, wrappers = {}, []

    def walk(struct_name, path):
        for field_name, field_type in structs[struct_name]:
            m = re.match(r'^\^(\w+)$', field_type)
            if m and m.group(1) in subsystems:
                walk(m.group(1), path + [field_name])
                continue
            if field_type.startswith('proc'):
                w = emit_wrapper(path, field_name, field_type, seen, alias_sub)
                if w:
                    wrappers.append(w)

    walk('API', [])

    alias_lines = [f"{ada} :: {orig}" for orig, ada in sorted(aliases.items(), key=lambda kv: kv[1])]

    out_path.write_text(
        "// Code generated by gen/generate.py. DO NOT EDIT.\n"
        "package playdate\n\n"
        'import "core:c"\n\n'
        + '\n'.join(alias_lines)
        + '\n\n'
        + '\n'.join(wrappers)
    )


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

    pd_api_path = PLAYDATE_DIR / "pd_api.odin"
    wrappers_path = PLAYDATE_DIR / "pd_api_wrappers.odin"
    shutil.copy2(TMP_OUTPUT / "pd_api_resolved.odin", pd_api_path)
    generate_wrappers(pd_api_path, wrappers_path)
    run_odinfmt(pd_api_path)
    run_odinfmt(wrappers_path)


if __name__ == "__main__":
    main()

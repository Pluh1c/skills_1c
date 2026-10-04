#!/usr/bin/env python3
# cfe-dump v1.0 — Dump 1C configuration extension (CFE) to XML sources
# Uses ibcmd config export with standalone-server temp database
# Source: https://github.com/Nikolay-Shirokov/cc-1c-skills

import argparse
import glob
import os
import subprocess
import sys


def resolve_v8path(v8path):
    """Resolve path to 1C platform bin directory."""
    if not v8path:
        candidates = glob.glob(r"C:\Program Files\1cv8\*\bin\1cv8.exe")
        if candidates:
            candidates.sort()
            return os.path.dirname(candidates[-1])
        else:
            print("Error: 1cv8.exe not found. Specify -V8Path", file=sys.stderr)
            sys.exit(1)
    elif os.path.isfile(v8path):
        return os.path.dirname(v8path)
    return v8path


def find_ibcmd(bin_dir):
    """Find ibcmd executable in bin directory."""
    for name in ("ibcmd.exe", "ibcmd"):
        path = os.path.join(bin_dir, name)
        if os.path.isfile(path):
            return path
    print(f"Error: ibcmd not found in {bin_dir}", file=sys.stderr)
    sys.exit(1)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(
        description="Dump 1C configuration extension (CFE) to XML sources",
        allow_abbrev=False,
    )
    parser.add_argument("-V8Path", default="", help="Path to 1cv8.exe or its bin directory")
    parser.add_argument("-InputFile", required=True, help="Path to CFE file")
    parser.add_argument("-OutputDir", required=True, help="Directory for dumped XML sources")
    args = parser.parse_args()

    # --- Resolve V8Path ---
    bin_dir = resolve_v8path(args.V8Path)
    ibcmd = find_ibcmd(bin_dir)

    # --- Validate input file ---
    if not os.path.isfile(args.InputFile):
        print(f"Error: input file not found: {args.InputFile}", file=sys.stderr)
        sys.exit(1)

    # --- Ensure output directory exists ---
    os.makedirs(args.OutputDir, exist_ok=True)

    # --- Standalone server data dir ---
    standalone_data = os.path.join(os.environ.get("LOCALAPPDATA", ""), r"1C\1cv8\standalone-server")
    db_data = os.path.join(standalone_data, "db-data")
    db_file = os.path.join(db_data, "1Cv8.1CD")

    temp_db_created = False

    try:
        # --- Ensure database exists ---
        if not os.path.isfile(db_file):
            print("Creating temporary database for export...")
            os.makedirs(db_data, exist_ok=True)
            create_args = [ibcmd, "infobase", "create", "--data", standalone_data]
            result = subprocess.run(create_args, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error creating temporary database: {result.stderr}", file=sys.stderr)
                sys.exit(1)
            temp_db_created = True
        else:
            print("Using existing database in standalone-server")

        # --- Export ---
        print(f"Exporting CFE to XML: {args.InputFile} -> {args.OutputDir}")
        export_args = [ibcmd, "config", "export", "--data", standalone_data, "-f", args.InputFile, args.OutputDir]
        result = subprocess.run(export_args, capture_output=True, text=True)

        if result.returncode == 0:
            file_count = sum(1 for _ in os.walk(args.OutputDir) for f in _[2])
            print(f"Export completed: {file_count} files written to {args.OutputDir}")
        else:
            print(f"Error exporting CFE (code: {result.returncode})", file=sys.stderr)
            if result.stderr:
                print(result.stderr, file=sys.stderr)
            if result.stdout:
                print(result.stdout, file=sys.stderr)

        sys.exit(result.returncode)

    finally:
        # --- Cleanup temp DB ---
        if temp_db_created:
            print("Cleaning up temporary database...")
            for name in ("1Cv8.1CD", "1Cv8.cgr.cfl"):
                path = os.path.join(db_data, name)
                if os.path.isfile(path):
                    os.remove(path)


if __name__ == "__main__":
    main()

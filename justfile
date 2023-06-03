# regex to match recipe names and their comments:
# ^    (?P<recipe>\S+)(?P<args>(?:\s[^#\s]+)*)(?:\s+# (?P<docs>.+))*

# Constants
purple_msg := '\e[38;2;151;120;211m%s\e[0m'
time_msg := '\e[38;2;151;120;211m%s\e[0m: %.2fs\n'

# Derived Constants
system_python := if os_family() == "windows" { "py.exe -3.10" } else { "python3.10" }
pyenv_dir := if os_family() == "windows" { ".\\\\pyenv" } else { "./pyenv" }
pyenv_bin_dir := pyenv_dir + if os_family() == "windows" { "\\\\Scripts" } else { "/bin" }
python := pyenv_bin_dir + if os_family() == "windows" { "\\\\python.exe" } else { "/python3" }
pyenv_activate := pyenv_bin_dir + (if os_family() == "windows" { "\\\\Activate.ps1" } else { "/activate" })
pyenv_activate_cmd := (if os_family() == "windows" { "" } else { "source " }) + pyenv_activate

# Program Arguments
set windows-shell := ["powershell.exe", "-Command"]

# Choose recipes
default:
    @ just -lu; printf '%s ' press Enter to continue; read; just --choose

# n1 - n2
[private]
minus n1 n2:
    @ python -c 'print(round({{n1}} - {{n2}}, 2))'

# Time commands
[private]
time msg err *cmd:
    #!/usr/bin/env bash
    printf '{{purple_msg}}: ' 'cmd'; printf '%s ' {{cmd}}; echo
    cs=$(date +%s.%N)
    if {{cmd}}; then
        printf '{{time_msg}}' '{{msg}}' "$(just minus $(date +%s.%N) $cs)"
    else
        printf '{{time_msg}}' '{{err}}' "$(just minus $(date +%s.%N) $cs)"
    fi

# Time commands without saying command name
[private]
time_nc msg err *cmd:
    #!/usr/bin/env bash
    cs=$(date +%s.%N)
    if {{cmd}}; then
        printf '{{time_msg}}' '{{msg}}' "$(just minus $(date +%s.%N) $cs)"
    else
        printf '{{time_msg}}' '{{err}}' "$(just minus $(date +%s.%N) $cs)"
    fi

[private]
[unix]
b64e file:
    base64 -w0 {{file}}

# Set up development environment
[linux]
[macos]
[unix]
bootstrap:
    #!/usr/bin/env bash
    echo 'Nothing to do'

# Set up development environment
[windows]
bootstrap:
    #!powershell.exe
    echo 'Nothing to do'

scale:
    #!/bin/bash
    input_file="to-be-scaled.txt"

    # Read the input file line by line
    while IFS= read -r image_path; do
        # Extract the filename and extension from the image path
        extension="${image_path##*.}"
        filename="${image_path%.*}"

        mkdir -p "$(dirname "$image_path")"
        convert "$image_path" -resize 1080x "$filename""-1080x.$extension"

    done < "$input_file"


push msg='push':
    git add .
    git commit -m '{{ msg }}'
    git push

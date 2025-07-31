#! /usr/bin/env bash

set -eo pipefail

# Ищем все Dockerfile* файлы рекурсивно
mapfile -d '' dockerfiles < <(find . -type f -name "Dockerfile*" -print0 2>/dev/null)

if [ ${#dockerfiles[@]} -eq 0 ]; then
    echo '{"error":"No Dockerfile* files found in the directory tree"}' >&2
    exit 1
fi

declare -A all_images
declare -A args

process_dockerfile() {
    local file="$1"
    args=()

    # Обработка ARG
    while read -r line; do
        [[ "$line" =~ ^ARG[[:space:]]+([^=]+)(=([^[:space:]]+))? ]] && \
        args["${BASH_REMATCH[1]}"]="${BASH_REMATCH[3]}"
    done < <(awk '{if (/\\$/) {sub(/\\$/, ""); printf "%s", $0; next} else {print}}' "$file")

    # Обработка FROM
    grep -oP '^FROM[[:space:]]+\K[^[:space:]]+' < <(awk '{if (/\\$/) {sub(/\\$/, ""); printf "%s", $0; next} else {print}}' "$file") | \
    while read -r image; do
        while [[ "$image" =~ \$\{([^}]+)\} ]]; do
            local arg_name="${BASH_REMATCH[1]}"
            [ -n "${args["$arg_name"]}" ] && \
            image="${image//\$\{$arg_name\}/${args["$arg_name"]}}" || \
            { echo "{\"warning\":\"ARG $arg_name has no default value in $file\"}" >&2; break; }
        done
        all_images["$image"]=1
    done
}

for dockerfile in "${dockerfiles[@]}"; do
    process_dockerfile "$dockerfile"
done

# Формируем однострочный JSON
json_output=$(printf '{"found_files":[%s],"unique_base_images":[%s]}' \
  "$(printf '"%s",' "${dockerfiles[@]}" | sed 's/,$//')" \
  "$(printf '"%s",' "${!all_images[@]}" | sort -u | sed 's/,$//')")

echo "$json_output"

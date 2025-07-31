#!/bin/bash
set -eo pipefail

# Ищем все Dockerfile в проекте
dockerfiles=($(find . -name "Dockerfile*" -type f))

if [ ${#dockerfiles[@]} -eq 0 ]; then
  echo '{"error":"No Dockerfile files found"}' >&2
  exit 1
fi

declare -A base_images
declare -A args_cache

process_dockerfile() {
  local file=$1
  local in_from_section=0
  local from_line=""
  
  # Читаем файл построчно, объединяя многострочные инструкции
  while IFS= read -r line || [ -n "$line" ]; do
    # Обрабатываем ARG
    if [[ $line =~ ^ARG[[:space:]]+([^=]+)=?(.*) ]]; then
      arg_name=${BASH_REMATCH[1]}
      arg_value=${BASH_REMATCH[2]#\"}
      arg_value=${arg_value%\"}
      args_cache[$arg_name]=$arg_value
      continue
    fi
    
    # Обрабатываем FROM
    if [[ $line =~ ^FROM[[:space:]]+(.*) ]]; then
      from_line=${BASH_REMATCH[1]}
      in_from_section=1
    elif [ $in_from_section -eq 1 ] && [[ $line =~ \\$ ]]; then
      from_line+=" ${line%\\}"
    else
      if [ $in_from_section -eq 1 ]; then
        from_line+=" $line"
        process_from_line "$file" "$from_line"
        in_from_section=0
        from_line=""
      fi
    fi
  done < "$file"
}

process_from_line() {
  local file=$1
  local line=$2
  
  # Удаляем комментарии
  line=${line%%#*}
  
  # Извлекаем базовый образ (до первого пробела или AS)
  local base_image=$(echo "$line" | awk '{print $1}')
  
  # Заменяем переменные ARG
  while [[ $base_image =~ \$\{?([a-zA-Z_][a-zA-Z0-9_]*)\}? ]]; do
    local arg_name=${BASH_REMATCH[1]}
    if [ -n "${args_cache[$arg_name]}" ]; then
      base_image=${base_image//\$\{$arg_name\}/${args_cache[$arg_name]}}
      base_image=${base_image//$arg_name/${args_cache[$arg_name]}}
    else
      echo "{\"warning\":\"ARG $arg_name not defined in $file\"}" >&2
      return
    fi
  done
  
  # Добавляем в результат, если не пустой и не AS
  if [ -n "$base_image" ] && [[ "$base_image" != "AS" ]] && [[ "$base_image" != "scratch" ]]; then
    base_images["$base_image"]=1
  fi
}

# Обрабатываем все Dockerfile
for dockerfile in "${dockerfiles[@]}"; do
  process_dockerfile "$dockerfile"
done

# Формируем JSON результат
result_files=$(printf '"%s",' "${dockerfiles[@]}" | sed 's/,$//')
result_images=$(printf '"%s",' "${!base_images[@]}" | sed 's/,$//')

echo "{\"found_files\":[$result_files],\"unique_base_images\":[$result_images]}"

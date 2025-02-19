#!/bin/bash
port="$1"
temp_file="$2"
save_dir="$3"
backup_dir="${save_dir}/backup_$(date +'%Y%m%d_%H%M%S')"
socat - TCP4-LISTEN:$port | {
    read -r filetype
    echo "$filetype" >>"${temp_file}"
    read -r filename
    echo "$filename" >>"${temp_file}"
    read -r filesize
    if [[ -e "${save_dir}/${filename}" ]]; then
        mkdir -p "$backup_dir"
        mv "${save_dir}/${filename}" "$backup_dir"
        echo "${save_dir}/${filename}存在，已将它们移动至$backup_dir"
    fi
    pv -s "$filesize" >"${save_dir}/${filename}"
}

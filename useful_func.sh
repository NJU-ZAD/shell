#!/bin/bash
validate_ip() {
    local ip="$1"
    local valid=1
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r -a octets <<<"$ip"
        if [[ ${#octets[@]} -eq 4 ]]; then
            for octet in "${octets[@]}"; do
                if ((octet < 0 || octet > 255)); then
                    valid=0
                    break
                fi
            done
        else
            valid=0
        fi
    else
        valid=0
    fi
    echo $valid
}
git_push() {
    local add_path="$1"
    local commit="$2"
    local Gitemail="$3"
    local Gituser="$4"
    local Gitpass"$5"
    git config --global user.email "$Gitemail"
    git config --global user.name "$Gituser"
    git status
    git add $add_path
    git commit -m $commit
    expect <<EOF
spawn git push
expect "Username"
send "$Gituser\n"
expect "Password"
send "$Gitpass\n"
expect eof
EOF
}

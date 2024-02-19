#!/usr/bin/sh

display_info() {
    echo "Users:\n"
    while IFS= read -r line
    do
        val=$(echo $line | cut -d ":" -f7)
        user=$(echo $line | cut -d ":" -f1)
        if [ "$val" != "/bin/false" -a "$val" != "/usr/sbin/nologin" ]; then 
            echo "$user has $val"
        fi
    done < "/etc/passwd"

    echo "\n\nPasswords:\n"
    while IFS= read -r line
    do
        val=$(echo $line | cut -d ":" -f2)
        user=$(echo $line | cut -d ":" -f1)
        if [ ${#val} != "1" ]; then 
            echo "$user has a password"
        fi
    done < "/etc/shadow"

    echo "\nSudo Permissions:\n"
    grep -E '^[%a-zA-Z]' /etc/sudoers | grep -v '^#' | while IFS= read -r line
    do
        if echo "$line" | grep -q '^%'; then
            echo "Group $(echo $line | cut -d ' ' -f1) has sudo access"
        elif echo "$line" | grep -q '^Defaults'; then
            continue
        else
            echo "User $(echo $line | cut -d ' ' -f1) has sudo access"
        fi
    done

    echo "\nUsers in the sudo group:\n"
    if getent group sudo > /dev/null; then
        sudo_members=$(getent group sudo | cut -d ':' -f4)
        if [ -n "$sudo_members" ]; then
            echo "$sudo_members" | tr ',' '\n' | while IFS= read -r member; do
                echo "- $member"
            done
        else
            echo "No members found in the sudo group."
        fi
    else
        echo "The sudo group does not exist on this system."
    fi
}

# Initial checksums
passwd_checksum=$(md5sum /etc/passwd)
shadow_checksum=$(md5sum /etc/shadow)
sudoers_checksum=$(md5sum /etc/sudoers)
sudo_group_checksum=$(getent group sudo)

while true; do
    # Check for changes
    new_passwd_checksum=$(md5sum /etc/passwd)
    new_shadow_checksum=$(md5sum /etc/shadow)
    new_sudoers_checksum=$(md5sum /etc/sudoers)
    new_sudo_group_checksum=$(getent group sudo)

    # If changes are detected in any monitored item
    if [ "$passwd_checksum" != "$new_passwd_checksum" ] || [ "$shadow_checksum" != "$new_shadow_checksum" ] || [ "$sudoers_checksum" != "$new_sudoers_checksum" ] || [ "$sudo_group_checksum" != "$new_sudo_group_checksum" ]; then
        # Update checksums
        passwd_checksum=$new_passwd_checksum
        shadow_checksum=$new_shadow_checksum
        sudoers_checksum=$new_sudoers_checksum
        sudo_group_checksum=$new_sudo_group_checksum

        clear

        display_info
    fi

    sleep 10
done

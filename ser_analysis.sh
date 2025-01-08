





update_system() {
    echo "===== Updating System =====" >> "$output_file"
    if command -v apt &> /dev/null; then
        echo "Updating using apt..." >> "$output_file"
        sudo apt update && sudo apt upgrade -y >> "$output_file"
    elif command -v yum &> /dev/null; then
        echo "Updating using yum..." >> "$output_file"
        sudo yum update -y >> "$output_file"
    else
        echo "Unsupported package manager. Please update manually." >> "$output_file"
    fi
    echo >> "$output_file"
}


check_firewall() {
    echo "===== Checking Firewall  =====" >> "$output_file"
    if command -v ufw &> /dev/null; then
        ufw_status=$(sudo ufw status | grep "Status: active")
        if [ -n "$ufw_status" ]; then
            echo "Firewall is active." >> "$output_file"
        else
            echo "Firewall is not active." >> "$output_file"
        fi
    else
        echo "UFW is not installed. Please install it first." >> "$output_file"
    fi
    echo >> "$output_file"
}














update_system
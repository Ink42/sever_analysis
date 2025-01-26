output_file="/server_check_report.txt"

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


configure_fail2ban() {
    echo "===== Installing and Configuring Fail2Ban =====" >> "$output_file"
    if ! command -v fail2ban-client &> /dev/null; then
        echo "Fail2Ban is not installed. Installing..." >> "$output_file"
        if command -v apt &> /dev/null; then
            sudo apt install fail2ban -y >> "$output_file"
        elif command -v yum &> /dev/null; then
            sudo yum install fail2ban -y >> "$output_file"
        else
            echo "Unsupported package manager. Please install Fail2Ban manually." >> "$output_file"
            return
        fi
    fi

    echo "Fail2Ban is installed." >> "$output_file"
    echo "Starting Fail2Ban service..." >> "$output_file"
    sudo systemctl start fail2ban >> "$output_file"
    sudo systemctl enable fail2ban >> "$output_file"

    echo "Top 3 failed login attempts:" >> "$output_file"
    sudo grep "Failed password" /var/log/auth.log | awk '{print $1, $2, $3, $9}' | sort | uniq -c | sort -nr | head -n 3 >> "$output_file"
    echo >> "$output_file"
}



check_system_resources() {
    echo "===== Checking System Resources =====" >> "$output_file"
    echo "CPU Usage:" >> "$output_file"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}' >> "$output_file"
    echo >> "$output_file"

    echo "RAM Usage:" >> "$output_file"
    free -h | grep "Mem" | awk '{print "Total: " $2, "Used: " $3, "Free: " $4}' >> "$output_file"
    echo >> "$output_file"

    echo "Disk Usage:" >> "$output_file"
    df -h | grep -v "tmpfs" | grep -v "udev" >> "$output_file"
    echo >> "$output_file"
}


check_system_logs() {
    echo "===== Checking System Logs =====" >> "$output_file"
    if [ -f /var/log/syslog ]; then
        echo "Last 10 lines of /var/log/syslog:" >> "$output_file"
        sudo tail -n 10 /var/log/syslog >> "$output_file"
    elif [ -f /var/log/messages ]; then
        echo "Last 10 lines of /var/log/messages:" >> "$output_file"
        sudo tail -n 10 /var/log/messages >> "$output_file"
    else
        echo "System log file not found." >> "$output_file"
    fi
    echo >> "$output_file"
}
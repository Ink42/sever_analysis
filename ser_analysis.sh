update_system() {
    if command -v apt &> /dev/null; then
        echo "Updating using apt..." >> "$output_file"
    fi
    echo >> "$output_file"
}


update_system
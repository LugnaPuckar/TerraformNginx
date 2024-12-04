#!/bin/bash

# Function to change to a specific menu
change_menu() {
    menu=$1
    echo "Changing to $menu..."
    source "$menu"
}

# Display the menu
while true; do
    echo "-------------"
    echo "Select an option to deploy:"
    echo "1) Create - Deploy"
    echo "2) Remove - Destroy"
    echo "9) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            change_menu "./deploy_menu.sh"
            ;;
        2)
            change_menu "./destroy_menu.sh"
            ;;
        9)
            echo "Exiting the script. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done

#!/bin/bash

# Function to destroy a specific cloudplatform directory
destroy() {
    dir=$1
    destroyPath="./cloudplatforms/$1"
    # Check if directory exists before trying to run terraform destroy
    if [ -d $destroyPath ]; then
        echo "Destroying resources in $dir..."
        (cd $destroyPath && terraform init && terraform destroy -auto-approve)
        echo "Finished destroying resources in $dir."
    else
        echo "Directory $dir does not exist."
    fi
}

# Display the menu
while true; do
    echo "-------------"
    echo "Select an option to REMOVE - destroy:"
    echo "1) AWS"
    echo "2) Azure"
    echo "3) GCP"
    echo "4) All"
    echo "8) Return to main menu"
    echo "9) Exit the script"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            destroy "aws"
            ;;
        2)
            destroy "azure"
            ;;
        3)
            destroy "gcp"
            ;;
        4)
            for dir in aws azure gcp; do
                destroy "$dir"
            done
            ;;
        8)
            echo "Returning to main menu..."
            break
            ;;
        9)
            echo "Exiting the script..."
            exit
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done

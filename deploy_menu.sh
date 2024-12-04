#!/bin/bash

# Function to deploy a specific cloudplatform directory
deploy() {
    dir=$1
    deployPath="./cloudplatforms/$1"

    # Check if directory exists before trying to run terraform apply
    if [ -d $deployPath ]; then
        echo "Deploying resources in $dir..."
        (cd $deployPath && terraform init && terraform apply -auto-approve)
        echo "Finished deploying resources in $dir."
    else
        echo "Directory $dir does not exist."
    fi
}

# Display the menu
while true; do
    echo "-------------"
    echo "Select an option to CREATE - deploy:"
    echo "1) AWS"
    echo "2) Azure"
    echo "3) GCP"
    echo "4) All"
    echo "8) Return to main menu"
    echo "9) Exit the script"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            deploy "aws"
            ;;
        2)
            deploy "azure"
            ;;
        3)
            deploy "gcp"
            ;;
        4)
            for dir in aws azure gcp; do
                deploy "$dir"
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

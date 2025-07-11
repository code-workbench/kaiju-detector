#!/bin/bash

# Dev Container Setup Script
# This script installs all necessary dependencies for the kaiju-detector project

set -e  # Exit on any error

# Default settings
DEBUG=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                DEBUG=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [--debug] [--help]"
                echo "  --debug    Enable debug mode with verbose output"
                echo "  --help     Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Function to print colored output
print_status() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show progress in non-debug mode
show_progress() {
    local task_name="$1"
    echo -ne "${BLUE}[PROGRESS]${NC} $task_name... "
}

# Function to show completion in non-debug mode
show_completed() {
    echo -e "${GREEN}completed${NC}"
}

# Function to run command with appropriate output handling
run_with_output() {
    local task_name="$1"
    shift
    
    if [[ "$DEBUG" == "true" ]]; then
        "$@"
    else
        show_progress "$task_name"
        if "$@" > /dev/null 2>&1; then
            show_completed
        else
            echo -e "${RED}failed${NC}"
            return 1
        fi
    fi
}

# Function to update package lists
update_package_lists() {
    print_status "Updating package lists..."
    if run_with_output "Updating package lists" apt-get update; then
        print_status "Package lists updated successfully"
    else
        print_error "Failed to update package lists"
        exit 1
    fi
}

# Function to install basic dependencies
install_basic_dependencies() {
    print_status "Installing basic dependencies (docker.io, jq, bc, imagemagick, wget, gpg)..."
    if run_with_output "Installing basic dependencies" apt-get install -y docker.io jq bc imagemagick wget gpg; then
        print_status "Basic dependencies installed successfully"
    else
        print_error "Failed to install basic dependencies"
        exit 1
    fi
}

# Function to add HashiCorp GPG key
add_hashicorp_gpg_key() {
    print_status "Adding HashiCorp GPG key..."
    if run_with_output "Adding HashiCorp GPG key" wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg; then
        print_status "HashiCorp GPG key added successfully"
    else
        print_error "Failed to add HashiCorp GPG key"
        exit 1
    fi
}

# Function to add HashiCorp repository
add_hashicorp_repository() {
    print_status "Adding HashiCorp repository..."
    local repo_line="deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    if run_with_output "Adding HashiCorp repository" bash -c "echo '$repo_line' | tee /etc/apt/sources.list.d/hashicorp.list"; then
        print_status "HashiCorp repository added successfully"
    else
        print_error "Failed to add HashiCorp repository"
        exit 1
    fi
}

# Function to update package lists after adding new repository
update_package_lists_post_repo() {
    print_status "Updating package lists after adding HashiCorp repository..."
    if run_with_output "Updating package lists (post-repo)" apt-get update; then
        print_status "Package lists updated successfully"
    else
        print_error "Failed to update package lists after adding repository"
        exit 1
    fi
}

# Function to install Terraform
install_terraform() {
    print_status "Installing Terraform..."
    if run_with_output "Installing Terraform" apt-get install -y terraform; then
        print_status "Terraform installed successfully"
        # Verify installation
        if [[ "$DEBUG" == "true" ]]; then
            if terraform version > /dev/null 2>&1; then
                print_status "Terraform installation verified: $(terraform version | head -n1)"
            else
                print_warning "Terraform installed but version check failed"
            fi
        else
            show_progress "Verifying Terraform installation"
            if terraform version > /dev/null 2>&1; then
                show_completed
            else
                echo -e "${YELLOW}warning: version check failed${NC}"
            fi
        fi
    else
        print_error "Failed to install Terraform"
        exit 1
    fi
}

# Main execution function
main() {
    # Parse command line arguments
    parse_args "$@"
    
    print_status "Starting dev container setup..."
    
    update_package_lists
    install_basic_dependencies
    add_hashicorp_gpg_key
    add_hashicorp_repository
    update_package_lists_post_repo
    install_terraform
    
    echo -e "${GREEN}[SUCCESS]${NC} Dev container setup completed successfully!"
}

# Execute main function
main "$@"

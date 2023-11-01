#!/bin/bash

# Function to check if a command is installed
check_command() {
  command -v "$1" &> /dev/null
}

# Function to install a package using pip
install_package() {
  if ! check_command pip; then
    echo "Pip is not installed. Installing pip..."
    sudo easy_install pip
  fi
  echo "Installing $1..."
  pip3 install "$1"
}

# Check if Homebrew is installed and install it if necessary
if ! check_command brew; then
	export HOMEBREW_NO_INSTALL_FROM_API=1
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/yevheniiparasochka/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check if Python is installed
if ! check_command python3; then
  echo "Python is not installed. Installing Python..."
  brew install python
fi

# Check if pip is installed and install it if necessary
if ! check_command pip; then
  python3 -m pip install --upgrade setuptools
fi

# Check if Ansible is installed and install it if necessary
if ! check_command ansible; then
  brew install ansible
fi

# Run the Ansible playbook
if [ -f "main.yml" ]; then
  echo "Running Ansible playbook..."
  ansible-playbook main.yml
  status=$?
  if [ $status -eq 0 ]; then
    echo "Ansible playbook ran successfully."
  else
    echo "Error: Ansible playbook failed with exit code $status."
  fi
else
  echo "Error: main.yaml playbook file not found in the current directory."
  status=1
fi

exit $status


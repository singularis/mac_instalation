#!/bin/bash

# Identify the MacBook model
model=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}')

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
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
# Determine which playbook to run based on the model
if [[ "$model" == *"MacBookPro"* ]]; then
  playbook="main.yml"
elif [[ "$model" == *"Mac16,13"* ]]; then
  playbook="air.yml"
else
  echo "Error: Unknown MacBook model."
  exit 1
fi

# Run the Ansible playbook
# Check if the playbook file exists and run it
if [ -f "$playbook" ]; then
  echo "Running Ansible playbook ($playbook)..."
  ansible-playbook "$playbook"
  status=$?
  if [ $status -eq 0 ]; then
    echo "Ansible playbook ran successfully."
  else
    echo "Error: Ansible playbook failed with exit code $status."
  fi
else
  echo "Error: $playbook playbook file not found in the current directory."
  status=1
fi

exit $status
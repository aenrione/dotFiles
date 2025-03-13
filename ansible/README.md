# Ansible Playbook Collection

This repository contains a collection of Ansible playbooks to set up and configure various environments. The playbooks are organized into three directories: `desktop`, `dev`, and `required-tools`.

## Directories

- **desktop**: Playbooks for setting up a desktop environment.
- **dev**: Playbooks for setting up a development environment.
- **required-tools**: Playbooks for installing required tools and dependencies.

## Requirements

- **git**: Ensure you have Git installed to clone this repository.
- **ansible**: Ensure you have Ansible installed to run the playbooks.
- **sudo**: Ensure you have sudo privileges to run the playbooks.
- ubuntu: Ensure you are running the playbooks on an Ubuntu-based system. The playbooks may work on other distributions, but they have only been tested on Ubuntu.

## Installation

1. Clone the repository:

```bash
    git clone https://github.com/aenrione/dotFiles.git
```

2. Install Ansible:

```sh
    sudo apt-get install ansible
```

## Usage

Navigate to the desired directory and run the playbook:

```sh
cd dotFiles/ansible
ansible-playbook main.yml --ask-become-pass
```

Replace `main.yml` with the appropriate playbook file for your needs. Each file in its subdirectories is a playbook that can be run independently.


## License

This project is licensed under the MIT License.

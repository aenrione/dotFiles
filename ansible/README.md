# Ansible Playbook Collection

This repository contains a collection of Ansible playbooks to set up and configure various environments. The playbooks are organized into three directories: `desktop`, `dev`, and `required-tools`.

## Directories

- **desktop**: Playbooks for setting up a desktop environment.
- **dev**: Playbooks for setting up a development environment.
- **required-tools**: Playbooks for installing required tools and dependencies.

## Requirements

- **git**: Ensure you have Git installed to clone this repository.
- **ansible**: Ensure you have Ansible installed to run the playbooks.

## Installation

1. Clone the repository:

```sh
    git clone https://github.com/yourusername/ansible-playbook-collection.git
    cd ansible-playbook-collection
```

2. Install Ansible:

```sh
    sudo apt-get install ansible
```

## Usage

Navigate to the desired directory and run the playbook:

```sh
cd required-tools
ansible-playbook setup.yml --ask-become-pass
```

Replace `setup-desktop.yml` with the appropriate playbook file for your needs.

## Contributing

Feel free to submit issues or pull requests if you have any improvements or suggestions.

## License

This project is licensed under the MIT License.

#! /bin/zsh

# Run Macible in check mode
ansible-playbook playbooks/main.yml --check --diff "$@"

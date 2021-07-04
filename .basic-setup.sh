#!/bin/bash
echo "Updating repositories"
sudo apt-get update -y %% sudo apt-get upgrade

echo "Checking for Zsh install"
sudo apt-get install zsh && sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Getting PowerLevel10k"
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

echo "Getting Zsh Tools"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Getting Ruby setup"
sudo apt-get install ruby-dev rbenv postgresql cmake
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
cd ~/ && rbenv install 2.7.3 --verbose

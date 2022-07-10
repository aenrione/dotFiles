# Dotfiles

This is my collection of [configuration files](http://dotfiles.github.io/).

## Usage

Pull the repository, and then create the symbolic links [using GNU
stow](https://www.gnu.org/software/stow/).

```shell
$ git clone git@github.com:aenrione/dotFiles.git ~/.dotfiles
$ cd ~/.dotfiles
$ git submodule init # for things such as plugins
$ git submodule update
$ stow lunarvim neovim tmux zsh# plus whatever else you'd like
```



## License

[MIT](http://opensource.org/licenses/MIT).

[neovim]: https://neovim.io/
[lunarvim]: https://www.lunarvim.org/

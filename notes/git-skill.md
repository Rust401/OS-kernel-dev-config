# Useful git routines
## Use upstream to update forked repo
Add upstream repo
```
git remote add upstream git@dude.com:dude007/dude_repo.git
```
A remote git repo was linked with a tag `upstream`.
Actually you could use other fancy name to substitute the boring `upstream`
use `git remote -v` to check the remote repo linked

Pull upstream changes to local repo
```
git pull upstream [branch]
```
User `tab` to choose available branch
## check diff of files have been added
```
git diff --cached
```

## fix slow response for large git repo when zsh enabled
```sh
git config --global --add oh-my-zsh.hide-dirty 1
git config --global --add oh-my-zsh.hide-status 1
```
global config is here
```sh
~/.gitconfig
```

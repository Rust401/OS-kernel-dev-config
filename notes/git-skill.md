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


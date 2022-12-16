# Revert Uncommited Changes
git reset --hard; git clean -fd

# Remove branch: local and remote
git branch -D exampleBranch; git push origin --delete exampleBranch

# Checkout remote branch
git branch -a; git checkout origin/exampleBranch; git checkout exampleBranch

# Checkout remote PR
git fetch exampleRemote pull/PR_ID/head:exampleBranch; git checkout exampleBranch

# Go back to the previous commit, and check what it breaks
git checkout HEAD~

# Overwrite changes from a file in one branch to another
git checkout origin/master -- "My example File.md"

# Merge changes from one master (remotely) to feat-1
## Sync fork
git checkout master; git pull upstream master
## Then you have different options after moving to your branch
git checkout feat-1
## a. Overwrite changes from the upstream to local master. Local changes will be lost
git reset --hard upstream/feat-1 ; git push origin feat-1 --force
## b.Rebase master onto topSlowRequest
git rebase -i master
# deal with conflicts: git rebase --continue or git rebase --skip
git push -f
## c. Merge master changes in this branch: feat-1
git merge master

# untrack files after being indexed https://stackoverflow.com/questions/1274057
## It will remain the current version in the remote repository
git update-index --skip-worktree path/to/file.sh # for modified tracked files that the user don't want to commit anymore
git update-index --assume-unchanged path/to/file.sh # performance to prevent git to check status of big tracked files.
## Remove from the remote repository and move to .gitignore
git rm --cached file-example.txt
git rm -r --cached folder-example

# compare two branches
git diff --name-status master..develop

# Remove unwanted changes from a file in a PR
git checkout upstream/master "path/to/file.ext"
git commit -m "Reverted content of file"
git push origin pr-branch -f

# Tags
## Creates
git tag my-tag # it creates it locally
git push origin my-tag # it uploades it remotelly
## Delete
git tag -d my-tag # it deletes it locally
git push --delete origin my-tag # it deletes it remotely

# Git Submodules: https://gist.github.com/gitaarik/8735255
git submodule add git@github.com:org-example/repo-example.git libs/submodule-example
# How do I remove a submodule?
# https://stackoverflow.com/a/16162000
git submodule deinit -f libs/example-repo
rm -rf .git/modules/libs/example-repo
git rm -f libs/example-repo

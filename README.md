
# KIT301 Ears

KIT301 EARS Project in Flutter.

## Setup
#### CLI
1. Generate a temporary [access key](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
2. `git clone https://github.com/jofb/KIT301_Ears`
3. Enter username and generated key
4. Open folder in Android Studio or VSCode
#### Github Desktop
1. File > Clone Repository. You can either use the Github.com tab if the repo shows up under your account, or use the URL tab with `https://github.com/jofb/KIT301_Ears`.
2. Open folder in Android Studio or VSCode

## Feature Branching 
For this project we will try to adopt a feature-branch approach for development. What this means is that we have one master branch as expected, and any features that are developed will be on short-lived branches that will be merged back into this master branch.
When you begin developing some part of the app, open up a 
branch locally for you to work on.
Try and keep branches fairly isolated and atomic (i.e instead of developing an entire page all on one branch, treat each part of the page as a feature).

### Branch Creation and Management
#### Github Desktop
1. Ensure you are currently on the master branch.
2. Go current branch > New Branch and give it a name.
3. Github Desktop will automatically switch you to that branch, and you can begin working.

#### CLI
1. Ensure you are currently on the master branch (`git branch` shows all branches and additionally which one you are checked into)
2. `git checkout -b <branch-name` will create a new branch and check you into it.

Remember to commit your changes regularly on your branch. When you have finished your feature, it is time to merge the branch back into the master branch.

Merging into the master branch involves switching back to the master branch, and merging your feature branch into it.

#### Github Desktop
1. Ensure you have no pending changes (i.e commit all your changes)
2. Switch back into master branch
3. Go current branch > Choose a branch to merge into master
4. Merge your branch into the master branch
5. If there are merge conflicts then Github Desktop will provide a way to try and resolve them
6. Once successful, push to origin using the push changes button
7. Finally, delete your feature branch by right-clicking on it and deleting.
#### CLI
1. Ensure you have no pending changes.
2. Checkout into the master branch `git checkout master`
3. Merge your feature branch `git merge <branch-name>`
4. Resolve conflicts if needed 
5. Push to origin `git push origin`
6. Delete the branch `git branch -d <branch-name`

### Notes
Before pushing any changes, ensure that everything is working after a merge or changes.

If the feature you are working on is quite big and takes several development sessions, or if you need to collaborate on the feature, you can consider pushing it onto the remote repository.

If for whatever reason you must keep a branch up for a long time (i.e longer than a 5-7 days) remember to periodically fetch from the master branch and merge master into your feature branch. This may help prevent nasty merges in the future.
To do this you can follow the steps in the previous section, but noting that you are merging the other way (**master** -> **feature-branch**, instead of **feature-branch** -> **master**)


  # Git Setup for Private GitHub Repos

  Steps for initializing a local git repo and syncing with a new private
  GitHub repo.

  ## Prerequisites

  - GitHub CLI installed: `brew install gh`
  - A private repo already created on GitHub (can be empty)

  ## Steps

  ### 1. Initialize and Commit Locally

  ```bash
  git add .
  git commit -m "Initial commit"

  2. Add Remote

  git remote add origin https://github.com/USERNAME/REPO.git

  If remote already exists, update it:
  git remote set-url origin https://github.com/USERNAME/REPO.git

  3. Authenticate with GitHub CLI

  gh auth login -h github.com -p https -w

  This opens your browser for secure OAuth authentication - no credentials
  are entered in the terminal.

  4. Fix Large Push Buffer Issue

  If you get HTTP 400 errors when pushing, increase the git buffer:

  git config --global http.postBuffer 524288000

  5. Push to GitHub

  git push -u origin master

  Troubleshooting

  | Error                         | Solution
                              |
  |-------------------------------|----------------------------------------
  ----------------------------|
  | HTTP 400 curl 22              | Run the buffer fix in step 4
                              |
  | Permission denied (publickey) | Use HTTPS with gh auth login, not SSH
                              |
  | Authentication prompt         | Use gh auth login first, or enter
  username + personal access token |
  | ```                           |
                              |
                              
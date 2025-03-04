#!/usr/bin/env bash

# Some env variables
BRANCH="main"
REPO="contrib"
REPO_URL="github.com/gofiber/docs.git"
AUTHOR_EMAIL="github-actions[bot]@users.noreply.github.com"
AUTHOR_USERNAME="github-actions[bot]"

# Set commit author
git config --global user.email "${AUTHOR_EMAIL}"
git config --global user.name "${AUTHOR_USERNAME}"

# Exit if event is not PUSH
if [ "$EVENT" != "push" ]; then
  exit 0
fi

latest_commit=$(git rev-parse --short HEAD)

git clone https://${TOKEN}@${REPO_URL} fiber-docs
for f in $(find . -type f -name "*.md"); do
  log_output=$(git log --oneline "${BRANCH}" HEAD~1..HEAD --name-status -- "${f}README.md")
  
  if [[ $log_output != "" || ! -f "fiber-docs/$f" ]]; then
    mkdir -p fiber-docs/$(dirname $f)
    cp "${f}" fiber-docs/$f
  fi
done

# Push changes for contrib instance docs
cd fiber-docs/ || return
git add .
git commit -m "Add docs from https://github.com/gofiber/contrib/commit/${latest_commit}"
git push https://${TOKEN}@${REPO_URL}
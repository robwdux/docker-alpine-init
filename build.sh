#!/bin/bash

# work around limitations of docker-compose build

if [[ $(id -u) != 0 ]] || [[ -z ${SUDO_COMMAND+x} ]]; then
  echo "
  **must run $(basename $0) as root or use 'sudo $(basename $0)'
  "
  exit
fi

export GIT_COMMIT=$(git show -s --format=%H)
export GIT_COMMIT_DATE=$(git show -s --format=%cI)
export GIT_COMMIT_AUTHOR=$(git show -s --format="%an %ae")
export GIT_REPO_URL=$(git ls-remote --get-url | sed -e "s|:|/|" -e "s|git@|https://|")

docker-compose build $1

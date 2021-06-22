#!/bin/bash
set -eu
set -o pipefail

# get_version: extract the current version number.
get_version() {
  local version
  [[ -f JHEP-mod.bst ]] || abort 'JHEP-mod.bst not found'
  version=$(grep JHEP-mod.bst JHEP-mod.bst | head -1 | sed 's/^[^0-9]*//' | sed 's/).*$//')
  [[ $version != '' ]] || abort 'version not found'
  echo $version
}

# version_bump <version_number>: a hook function to bump the version.
version_bump() {
  dev_version_bump $1
  # NOTE: the "-i" option of sed is a GNU extension.
  sed -i 's|tueda/JHEP-mod.bst/.*/JHEP-mod.bst|tueda/JHEP-mod.bst/v'"$1"'/JHEP-mod.bst|' README.md
}

# dev_version_bump <version_number_dev>: a hook function to bump to a dev-version.
dev_version_bump() {
  # NOTE: the "-i" option of sed is a GNU extension.
  sed -i 's/(JHEP-mod.bst v.*)/(JHEP-mod.bst v'"$1"')/' JHEP-mod.bst
}

# abort <message>: aborts the program with the given message.
abort() {
  echo "error: $@" 1>&2
  exit 1
}

# check_proceed <message>: checks if the user want to proceed.
check_proceed() {
  local answer
  while :; do
    read -p 'ok? (yes/no): ' answer
    case "$answer" in
      [yY]*)
        break
        ;;
      [nN]*)
        echo 'aborted' 1>&2
        exit 1
        ;;
      *)
        ;;
    esac
  done
}

# Suffix for development version.
DEV_SUFFIX=-dev

# Require the git command.
command -v git >/dev/null || abort "git not available"

# Check if there is no changes not staged.
if [[ -n $(git diff --name-only) ]]; then
  git status
  abort "changes not staged"
fi

# If the working repository is dirty (including untracking files),
# then check if the user want to proceed.
if [[ -n $(git status --porcelain) ]]; then
  git status
  check_proceed
fi

# Extract the version.
version=$(get_version)

# Checks if the current version ends with DEV_SUFFIX.
[[ $version = *$DEV_SUFFIX ]] || abort "current version $version doesn't end with $DEV_SUFFIX"

# Determine the next versions.
next_version=patch
next_dev_version=prepatch
if [[ $# -ge 2 ]]; then
  next_version=$1
  next_dev_version=$2$DEV_SUFFIX
elif [[ $# -eq 1 ]]; then
  next_version=$1
fi
if [[ $next_version = patch ]]; then
  next_version=${version%$DEV_SUFFIX}
fi
if [[ $next_dev_version = prepatch ]]; then
  # The next version should be MAJOR.MINOR.MICRO.
  a=( ${next_version//./ } )
  [[ ${#a[@]} == 3 ]] || abort "next version $next_version should be X.Y.Z"
  # Get the next dev-version by incrementing MICRO.
  ((a[2]++)) || :
  next_dev_version="${a[0]}.${a[1]}.${a[2]}$DEV_SUFFIX"
fi

# Print the versions and confirm if they are fine.
echo "current commit      : $(git rev-parse --short HEAD)"
echo "current dev-version : $version"
echo "next version        : $next_version"
echo "next dev-version    : $next_dev_version"
check_proceed

# Make commits and a release tag.
version_bump $next_version
git commit -a -m "chore(version): prepare for release $next_version"
git tag "v$next_version"
dev_version_bump $next_dev_version
git commit -a -m "chore(version): new version commit $next_dev_version"

echo done

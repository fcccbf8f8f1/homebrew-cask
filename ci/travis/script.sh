#!/usr/bin/env bash
#
# script.sh
#
# This file is meant to be sourced during the `script` phase of the Travis
# build. Do not attempt to source or run it locally.
#
# shellcheck disable=SC1090
. "${TRAVIS_BUILD_DIR}/ci/travis/helpers.sh"

header 'Running script.sh...'

commit_range="${TRAVIS_COMMIT_RANGE/.../..}" # See https://github.com/travis-ci/travis-ci/issues/4596 (still open at time of writting)

modified_casks=($(git diff --name-only --diff-filter=AM "${commit_range}" -- Casks/*.rb))
ruby_files_added_outside_casks_dir=($(git diff --name-only --diff-filter=A "${commit_range}" -- *.rb))

if [[ ${#ruby_files_added_outside_casks_dir[@]} -gt 0 ]]; then
  odie "Casks added outside Casks directory: ${ruby_files_added_outside_casks_dir[@]}"
elif [[ ${#modified_casks[@]} -gt 0 ]]; then
  run brew cask _audit_modified_casks "${commit_range}"
  run brew cask style "${modified_casks[@]}"
else
  ohai 'No casks modified, skipping'
fi

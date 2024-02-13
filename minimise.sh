#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s inherit_errexit

readarray -td '' packageNames < <(printf '%s\0' "$@" | sort -uz || :)
for packageName in "${packageNames[@]}"; do
  echo "${packageName}" >&2
  dependencies=$(
    apt-cache depends "${packageName}" | gawk -- '/^ *[|]?Depends:/ {if (substr(prev,0,1)!="|")print $2;prev=$1}'
  )
  for dependency in ${dependencies}; do
    echo "${dependency}"
    [[ ! "${dependency}" =~ ^\<([^:]+):[^:]+\>$ ]] || dependency=${BASH_REMATCH[1]}
    # Check if dep has already been seen.
    # remove this from top list
    # check children.
  done

#<python3:any>
done

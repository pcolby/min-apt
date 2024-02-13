#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s inherit_errexit

declare -A seen

function getDeps {
  echo "Getting deps for $1" >&2
  dependencies=$(
    apt-cache depends "$1" | gawk -- '/^ *[|]?Depends:/ {if (substr(prev,0,1)!="|")print $2;prev=$1}'
  )
  for dependency in ${dependencies}; do
    [[ ! "${dependency}" =~ ^\<([^:]+)(:[^:]+)?\>$ ]] || dependency=${BASH_REMATCH[1]}
    if [[ -v seen[${dependency}] ]]; then (( seen[${dependency}]++ ))
    else
      echo "Found dep: ${dependency}" >&2
      seen[${dependency}]=1
      getDeps "${dependency}"
    fi
  done
}

for packageName in "$@"; do
  getDeps "$packageName"
done

for dep in "${!seen[@]}"; do
  echo "$dep: ${seen[$dep]}" >&2
done

echo 'Minimal set:' >&2
for pkg in "$@"; do
  [[ -v seen[$pkg] ]] || echo "$pkg"
done

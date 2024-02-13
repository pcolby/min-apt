#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s inherit_errexit

declare -A seen

function getDeps {
  echo "Getting deps for $1" >&2
  local -a deps
  deps=$(apt-cache depends "$1" | gawk -- '/^ *[|]?Depends:/ {if (substr(prev,0,1)!="|")print $2;prev=$1}')
  for dep in ${deps}; do
    [[ ! "${dep}" =~ ^\<([^:]+)(:[^:]+)?\>$ ]] || dep=${BASH_REMATCH[1]}
    if [[ -v seen[${dep}] ]]; then (( seen[${dep}]++ ))
    else
      echo "Found dep: ${dep}" >&2
      seen[${dep}]=1
      getDeps "${dep}"
    fi
  done
}

for pkg in "$@"; do
  getDeps "${pkg}"
done

echo -n 'apt install' >&2
for pkg in "$@"; do
  [[ -v seen["${pkg}"] ]] || echo "${pkg}"
done | sort | tr '\n' ' '
echo

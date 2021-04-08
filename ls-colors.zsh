#!/usr/bin/env zsh
SCRIPT_DIR="$( cd "$( dirname "${(%):-%N}" )" >/dev/null 2>&1 && pwd )"

# First setup a cache dir
if [[ "$(uname)" == "Darwin" ]]; then
  CACHE_DIR="${HOME}/Library/Caches"
  MACOS=1
elif [[ "$(uname)" == "Linux" ]]; then
  CACHE_DIR="${HOME}/.cache"
  LINUX=1
fi

CACHE="${CACHE_DIR}/ls-colors-zsh"

if [[ ! -d "${CACHE}" ]]; then
  mkdir -p "${CACHE}"
fi

# Next clone or pull the repo
REPO=https://github.com/trapd00r/LS_COLORS.git
LOCAL_REPO_PATH="${CACHE}/LS_COLORS"
LS_COLORS_COMP_HASH="${CACHE}/compiled_hash"
LS_COLORS_COMPILED="${CACHE}/ls_colors.sh"
if [[ ! -d "${CACHE}/LS_COLORS" ]]; then
  git clone "${REPO}" "${LOCAL_REPO_PATH}"
  RECOMPILE_NEEDED=1
else
  CURRENT_HASH="$(git -C ${LOCAL_REPO_PATH} rev-parse HEAD)"
  if [[ "${CURRENT_HASH}" != "$(cat ${LS_COLORS_COMP_HASH})" ]]; then
    RECOMPILE_NEEDED=1
  fi
fi

# Early Exit
if [[ ! -n $RECOMPILE_NEEDED && -s "${LS_COLORS_COMPILED}" ]]; then
  exit 0
fi

# Check if we need dircolors
if [[ -n $MACOS ]]; then
  DIRCOLORS="gdircolors"
elif [[ -n $LINUX ]]; then
  DIRCOLORS="dircolors"
fi

if ! command -v $DIRCOLORS &> /dev/null; then
  if [[ -n $MACOS ]]; then
    brew install coreutils
  fi
fi

# Build the LS_COLORS string
if [[ -n ${RECOMPILE_NEEDED} || ! -s "${LS_COLORS_COMPILED}" ]]; then
  git -C "${LOCAL_REPO_PATH}" rev-parse HEAD > "${LS_COLORS_COMP_HASH}"
  $DIRCOLORS -b "${LOCAL_REPO_PATH}/LS_COLORS" > "${LS_COLORS_COMPILED}"
fi

export CLICOLOR=true
export LSCOLORS="Gxfxcxdxbxegedabagacab"
source "${LS_COLORS_COMPILED}"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

if [[ -n $LINUX ]]; then
  alias ls='ls --color=auto'
fi

# Queue up a git pull in the background to see if there are updates to be had
nohup "git" "-C ${LOCAL_REPO_PATH} pull -q" &> /dev/null &

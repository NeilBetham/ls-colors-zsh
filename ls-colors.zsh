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
if [[ ! -d "${CACHE}/LS_COLORS" ]]; then
  git clone "${REPO}" "${LOCAL_REPO_PATH}"
  RECOMPILE_NEEDED=1
else
  CURRENT_HASH="$(git -C ${LOCAL_REPO_PATH} rev-parse HEAD)"
  git -C "${LOCAL_REPO_PATH}" pull
  if [[ "${CURRENT_HASH}" != "$(git -C ${LOCAL_REPO_PATH} rev-parse HEAD)" ]]; then
    RECOMPILE_NEEDED=1
  fi
fi

# Check if we need dircolors
if ! command -v dircolors &> /dev/null; then
  if [[ -n MACOS ]]; then
    brew install coreutils
  fi
fi

# Build the LS_COLORS string
LS_COLORS_COMPILED="${CACHE}/ls_colors.sh"
if [[ -n ${RECOMPILE_NEEDED} ]]; then
  dircolors -b "${LOCAL_REPO_PATH}/LS_COLORS" > "${LS_COLORS_COMPILED}"
fi

export CLICOLOR=true
export LSCOLORS="Gxfxcxdxbxegedabagacab"
source "${LS_COLORS_COMPILED}"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
alias ls='ls --color=auto'

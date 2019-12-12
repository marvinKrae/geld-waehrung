#!/usr/bin/env bash
# Hard coded variables
LATEX_TEMPLATE_HTTPS_GIT=https://git.dhbw-stuttgart.de/wi-lab/latex-template.git

# Colors
RESET=$(tput sgr0)
BU=$(tput smul)
AQUA=$(tput setaf 14)
DARK_AQUA=$(tput setaf 6)
LIGHT_RED=$(tput setaf 9)
GREEN=$(tput setaf 82)
DARK_GREEN=$(tput setaf 2)
GRAY=$(tput setaf 247)
BOLD=$(tput bold)
GOLD=$(tput setaf 11)

# Utility methods
function cecho() {
  output_string=""
  for var in "$@"; do
    output_string+=${var}${RESET}
  done
  echo -en "$output_string"
}

function cecho_yes_no() {
  cecho "$@"
  answer=""
  read answer
  if [[ ${answer} =~ ^[Yy]$ || -z ${answer} ]]; then
    return 0
  fi
  return 1
}

function new_topic() {
    local TOTAL_PRINTING_CHARACTERS=$(($(tput cols) * 2 / 5 ))
    local TOTAL_SEPARATORS=$((TOTAL_PRINTING_CHARACTERS - ${#2}))
    local SEPARATOR_AMOUNT=$((TOTAL_SEPARATORS / 2))

    printf ${BOLD}
    for (( i = 0; i < ${SEPARATOR_AMOUNT}; ++i )); do
        printf "-"
    done
    cecho "$1$2"
    printf ${BOLD}
    for (( i = 0; i < ${SEPARATOR_AMOUNT}; ++i )); do
        printf "-"
    done
    if [[ ! $((TOTAL_SEPARATORS%2)) -eq 0 ]]; then
        printf "-"
    fi
    echo -e "${RESET}"
}

new_topic "${AQUA}" "[DHBW LaTeX Template Generator]"

# Checking for the required tools on the machine, mostly git
if ! hash git 2>/dev/null; then
  cecho "Could not find ${LIGHT_RED}git" " on your machine\n"
  exit 1
fi

# Request remote git repository in which the project will live
REMOTE_GIT_REPOSITORY=$1
if [[ -z ${REMOTE_GIT_REPOSITORY} ]]; then
  cecho "${GRAY}Keep the following empty, if you do not plan on hosting the project on a remote.\n"
  cecho "Please provide the projects remote ${AQUA}${BU}git repository url" ": "
  read -r REMOTE_GIT_REPOSITORY
fi
if [[ -z ${REMOTE_GIT_REPOSITORY} ]]; then
    cecho "The project will ${LIGHT_RED}not" " be hosted at any repository.\n"
else
    cecho "The project will be hosted at: " "${AQUA}${BU}${REMOTE_GIT_REPOSITORY}.\n"
fi

new_topic "${GREEN}" "[Project Name]"
PROJECT_NAME=$(echo "${REMOTE_GIT_REPOSITORY:=latex-template.git}" | rev | cut -d '/' -f 1 | cut -c 5- | rev)
while ! (cecho_yes_no "Do you want to use ${GREEN}${BU}${PROJECT_NAME}" " as your project name" " ${DARK_GREEN}[y/n]" "? "); do
  cecho "Please provide the ${GREEN}${BU}project name" ": ${DARK_AQUA}"
  read -r PROJECT_NAME
done

new_topic "${GOLD}" "Cloning up the project"
cecho "${GOLD}Cloning" " the latest latex template to ${GOLD}${BU}${PROJECT_NAME}.\n"
if ! git config credential.helper>/dev/null; then
    cecho " ┏ You do not have the git ${GOLD}credential helper"  " enabled!\n"
    cecho " ┃ The ${GOLD}credential helper" " allows you to ${GOLD}store" " your ${GOLD}git remote credentials" ".\n"
    if cecho_yes_no " ┃ Do you want to enabled it" " ${DARK_GREEN}[y/n]" "? "; then
        git config --global credential.helper store
        cecho " ┗ ${DARK_GREEN}Enabled" " the git ${GOLD}credential helper" " globally!\n"
    else
        cecho " ┗ Did not enable git credential helper.\n"
    fi
fi
git clone ${LATEX_TEMPLATE_HTTPS_GIT} ${PROJECT_NAME}

cd ${PROJECT_NAME}
git remote add upstream ${LATEX_TEMPLATE_HTTPS_GIT}
if [[ -z ${REMOTE_GIT_REPOSITORY} ]]; then
    git remote remove origin
else
    git remote set-url origin ${REMOTE_GIT_REPOSITORY}
fi
cecho "${GOLD}${BU}Done!\n"


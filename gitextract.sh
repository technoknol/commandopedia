#!/bin/bash

# Extract changed files from Git and prepare a deployment (Bash script) 
# SRC: http://blog.angeloff.name/post/2010/11/05/extract-changed-files-from-git-and-prepare-a-deployment/
# Modified by: Shyam Makwana

BOLD="\033[1m"
_BOLD="\033[22m"
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
RESET="\033[39m"

range=$1
if [ -z "$range" ]; then
  echo -e "${BOLD}${RED}You must specify a '<since>..<until>' argument.${RESET}${_BOLD}"
  exit 1
fi

if [ -z "$2" ]; then
  target="$( pwd )/.deployments"
else
  target=$( echo "$2" | sed -e 's#/\+$##g' )
fi

if [ -d "$target" ]; then
  echo -ne "Do you wish to remove '$target' first? [Y/n] "
  read prompt
  if [ -z "$prompt" ] || [ "$prompt" == "Y" ] || [ "$prompt" == "y" ]; then
    echo -e "  ${YELLOW}Purging '$target'...${RESET}"
    if [ -d "$target" ]; then
      rm -Rf "$target"
    fi
    echo -e "  ${GREEN}Done.${RESET}"
  fi
fi

mkdir -p "$target"

LOG=$( git whatchanged --oneline "$range" | awk '{
  if ($1 ~ /^:/) {
    print $5 ":" $6
  }
}' | tac )

length=$( echo "$LOG" | wc -l )
manual=''

index=0
for command in $LOG; do
  operation=${command:0:1}
  filepath=${command:2}
  case $operation in
    "A" | "M")
      if [ -f "$filepath" ]; then
        destination=$( dirname "$target/$filepath" )
        filename=$( basename "$filepath" )
        mkdir -p "$destination"
        cp -f "$filepath" "$target/$filepath"
      fi
    ;;
    "D")
      manual="$manual\n$filepath"
    ;;
    *)
    echo -e "${BOLD}${RED}Unknown operation $operation on file $filepath.${RESET}${_BOLD}"
    exit 4
    ;;
  esac
  let "index++"
  echo -ne "\r${YELLOW}Processing ${length} files...${RESET} ${GREEN} ${filepath} ${RESET} $( echo "scale=2; ( $index / $length ) * 100.00" | bc )%"
done
echo

if [ ! -z "$manual" ]; then
  echo $( echo -e "$manual" | sed -e 's/^\s\+//g' | sort -u ) > "$target/.delete"
  echo -e "[WARN] Please manually delete the files listed in '${BOLD}.delete${_BOLD}'"
fi

echo -e "${GREEN}Done.${RESET}"

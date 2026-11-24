#!/usr/bin/env bash

encode() {
  local string="$1"
  if [[ -z "$string" ]]; then
    echo ""
    return 0
  fi
  local length="${#string}" encoded_str="" cnt=1 char
  for (( i = 0; i < length - 1; i++ )); do
    char="${string:i:1}"
    if [[ "$char" == "${string:i + 1:1}" ]]; then
      (( cnt++ ))
    else
      if (( cnt > 1 )); then
        encoded_str+="$cnt"
      fi
      encoded_str+="$char"
      cnt=1
    fi
  done
  if (( cnt > 1 )); then
    encoded_str+="$cnt"
  fi
  encoded_str+="${string:length - 1:1}"

  echo "$encoded_str"
}

decode() {
  local string="$1"
  if [[ -z "$string" ]]; then
    echo ""
    return 0
  fi
  local length plain_str="" count="" char
  length="${#string}"
  for (( i = 0; i < length; i++ )); do
    char="${string:i:1}"
    if [[ "$char" =~ [0-9] ]]; then
      count+="$char"
    else
      if [[ -n "$count" ]]; then
        if [[ "${string:i - 1:1}" =~ [0-9] ]]; then
          local k
          for (( k = 0; k < count; k++ )); do
            plain_str+="$char"
          done
          count=""
        fi
      else
        plain_str+="$char"
        count=""
      fi
    fi
  done
  
  echo "$plain_str" 
}

main() {
  local cmd="$1" input="$2"
  case "$cmd" in
    encode|decode) "$cmd" "$input" ;;
    *) echo "Invalid command." ;;
  esac
}

main "$@"

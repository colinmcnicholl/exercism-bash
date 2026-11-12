#!/usr/bin/env bash

readonly m=26

normalise() {
  local text="$1"
  local output=""

  for ((i = 0; i < ${#text}; i++)); do
    if [[ "${text:i:1}" =~ [a-z0-9] ]]; then
      output+="${text:i:1}"
    fi
  done

  echo "$output"
}

gcd() {
  local a="$1"
  local b="$2"
  local temp

  while (( b != 0 )); do
    temp=$(( a % b ))
    a="$b"
    b="$temp"
  done

  echo"$a"
}

main() {
  local a="$1"
  local b="$2"
  local plaintext="$3"

  if [[ $(gcd "$a" "$m") != 1 ]]; then
    echo "a and m must be coprime" >&2
    return 1
  fi

  plaintext="${plaintext,,}"
  plaintext=$(normalise "$plaintext")

}

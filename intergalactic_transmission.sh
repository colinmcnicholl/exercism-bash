#!/usr/bin/env bash

chunk() {
  local n="$1"
  local text="$2"
  local output=""

  for ((i = 0; i < "${#text}"; i++)); do
    if (( i != 0 && i % n == 0 )); then    
      output+=$' '
      output+="${text:i:1}"
    else
      output+="${text:i:1}"
    fi
  done
  
  echo "$output"
}

main () {
  local cmd="$1"
  IFS=" " read -ra transmission_elements <<< "$2"
  local bin bin8 hex
  local binary_elements=()

  for element in "${transmission_elements[@]}"; do
    hex="${element#0x}"
    hex="${hex^^}"
    bin=$(bc <<< "ibase=16; obase=2; $hex")
    bin8=$(printf '%08d' "$bin")
    binary_elements+=("$bin8")
  done

  local s=""
  for el in "${binary_elements[@]}"; do
    s+="$el"
  done

  local one_bits one_bit_count data_bits
  s=$(chunk 7 "$s")
  echo "after chunking: s = $s" | cat -A
  mapfile -d ' ' chunks < <(printf '%s' "$s")
  for el in "${chunks[@]}"; do
    el=${el//[$' \t\t\n']}
    echo "loop over chunks: el = $el"
    if (( "${#el}" < 7 )); then
      echo "if: element size < 7, el size = ${#el}"
      echo "if: el = $el" | cat -A
      while (( "${#el}" < 7 )); do
        el+="0"
      done
      echo "after pad to right with zeros: el = $el" | cat -A
    fi
    one_bits=${el//[0 ]}
    echo "one_bits = $one_bits" | cat -A
    one_bit_count="${#one_bits}"
    echo "one_bit_count = $one_bit_count"
    if (( one_bit_count % 2 == 0 )); then
      el+="0"
      data_bits+=("$el")
    else
      el+="1"
      data_bits+=("$el")
    fi
  done

  for data in "${data_bits[@]}"; do
    echo "data = $data"
    hex=$(bc <<< "obase=16; ibase=2; $data")
    echo "hex = $hex"
  done

}

main "$@"

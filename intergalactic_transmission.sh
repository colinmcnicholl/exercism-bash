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
  
  if [[ -z "$2" ]]; then
    echo ""
  fi

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
  mapfile -d ' ' chunks < <(printf '%s' "$s")
  for el in "${chunks[@]}"; do
    el=${el//[$' \t\t\n']}
    if (( "${#el}" < 7 )); then
      while (( "${#el}" < 7 )); do
        el+="0"
      done
    fi
    one_bits=${el//[0 ]}
    one_bit_count="${#one_bits}"
    if (( one_bit_count % 2 == 0 )); then
      el+="0"
      data_bits+=("$el")
    else
      el+="1"
      data_bits+=("$el")
    fi
  done

  local output
  for data in "${data_bits[@]}"; do
    hex=$(bc <<< "obase=16; ibase=2; $data")
    hex="${hex,,}"
    if (( "${#hex}" == 2 )); then
      hex="0x$hex"
      output+="$hex"
      output+=" "
    else
      hex="0x0$hex"
      output+="$hex"
      output+=" "
    fi
  done
  local msg_size length
  msg_size="${#output}"
  length=$(( msg_size - 1 ))
  echo "output = ${output:0:length}" | cat -A
}

main "$@"

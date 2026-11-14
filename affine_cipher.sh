#!/usr/bin/env bash

readonly m=26
declare -Ar letter_indices=(
  [a]=0 [b]=1 [c]=2 [d]=3 [e]=4 [f]=5 [g]=6 [h]=7 [i]=8 [j]=9 [k]=10
  [l]=11 [m]=12 [n]=13 [o]=14 [p]=15 [q]=16 [r]=17 [s]=18 [t]=19
  [u]=20 [v]=21 [w]=22 [x]=23 [y]=24 [z]=25
)
declare -Ar index_to_letter=(
  [0]=a [1]=b [2]=c [3]=d [4]=e [5]=f [6]=g [7]=h [8]=i [9]=j [10]=k
  [11]=l [12]=m [13]=n [14]=o [15]=p [16]=q [17]=r [18]=s [19]=t
  [20]=u [21]=v [22]=w [23]=x [24]=y [25]=z
)

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

  echo "$a"
}

chunk() {
  local n="$1"
  local text="$2"
  local output=""

  for ((i = 0; i < ${#text}; i++)); do
    if (( i != 0 && i % n == 0 )); then    
      output+=" ${text:i:1}"
    else
      output+="${text:i:1}"
    fi
  done
  
  echo "$output"
}

mmi_naive() {
  local a="$1"

  for ((b = 0; b < m; b++)); do
    if (( (a * b) % m == 1 )); then
      echo "$b"
      return 0
    fi
  done

  echo ""
}

translate() {
  local direction="$1"
  local a="$2"
  local b="$3"
  local text="$4"
  local i x translated

  for ((j = 0; j < ${#text}; j++)); do
    if [[ "${plaintext:j:1}" =~ [a-z] ]]; then
      i=${letter_indices[${text:j:1}]}
      x=$(( (a * i + b) % m ))
      translated+="${index_to_letter[$x]}"
    elif [[ "${text:j:1}" =~ [0-9] ]]; then
      translated+="${text:j:1}"
    fi
  done

  chunk 5 "$translated"
}

encode() {
  local a="$1"
  local b="$2"
  local plaintext="$3"
  local i x encoded

  for ((j = 0; j < ${#plaintext}; j++)); do
    if [[ "${plaintext:j:1}" =~ [a-z] ]]; then
      i=${letter_indices[${plaintext:j:1}]}
      x=$(( (a * i + b) % m ))
      encoded+="${index_to_letter[$x]}"
    elif [[ "${plaintext:j:1}" =~ [0-9] ]]; then
      encoded+="${plaintext:j:1}"
    fi
  done

  chunk 5 "$encoded"
}

decode() {
  local a="$1"
  local b="$2"
  local text="$3"
  local i x decoded inv
  inv=$(mmi_naive "$a")
  text=$(normalise "$text")

  for ((j = 0; j < ${#text}; j++)); do
    if [[ "${text:j:1}" =~ [a-z] ]]; then
      i=${letter_indices[${text:j:1}]}
      index=$(( (((inv * (i - b)) % m) + m) % m ))
      decoded+="${index_to_letter[$index]}"
    elif [[ "${text:j:1}" =~ [0-9] ]]; then
      decoded+="${text:j:1}"
    fi
  done

  echo "$decoded"
}

main() {
  local cmd="$1"
  local a="$2"
  local b="$3"
  local text="$4"

  if [[ $(gcd "$a" "$m") != 1 ]]; then
    echo "a and m must be coprime." >&2
    return 1
  fi

  text="${text,,}"
  text=$(normalise "$text")

  if [[ "$cmd" == "encode" ]]; then
    encode "$a" "$b" "$text"
  else
    decode "$a" "$b" "$text"
  fi
}

main "$@"

#!/usr/bin/env bash

# Generate a key which consists of at least 100 random 
# letters from the Latin alphabet
create_key() {
  declare -a alphabet
  alphabet=({a..z})
  local index cipher_key
  cipher_key=""

  for ((i=0; i<102; i++)); do
    index=$(( $RANDOM % 26 ))
    cipher_key+="${alphabet[$index]}"
  done

  echo "$cipher_key"
}

encode() {
  local key="$1"
  local plaintext="$2"
  local ciphertext plaintext_chr key_chr key_size plaintext_size shift_dist
  local pos shifted_pos
  key_size="${#key}"
  plaintext_size="${#plaintext}"
  declare -a letters
  letters=({a..z})
  declare -A letter_indices
  letter_indices=([a]=0 [b]=1 [c]=2 [d]=3 [e]=4 [f]=5 [g]=6 [h]=7 [i]=8 [j]=9 [k]=10
            [l]=11 [m]=12 [n]=13 [o]=14 [p]=15 [q]=16 [r]=17 [s]=18 [t]=19
            [u]=20 [v]=21 [w]=22 [x]=23 [y]=24 [z]=25)

  for ((i = 0; i < plaintext_size; i++ )); do
    if (( key_size < plaintext_size )); then
      key_index=$(( i % key_size ))
    else
      key_index="$i"
    fi

    key_chr="${key:key_index:1}"
    plaintext_chr="${plaintext:i:1}"
    pos="${letter_indices[$plaintext_chr]}"
    shift_dist="${letter_indices[$key_chr]}"
    shifted_pos=$(( (pos + shift_dist) % 26 ))

    # echo "i = $i, key_chr = $key_chr, plaintext_chr = $plaintext_chr"
    ciphertext+="${letters[$shifted_pos]}"
    echo "i = $i, letters[shifted_pos] = ${letters[$shifted_pos]}, ciphertext = $ciphertext"

  done

  echo "$ciphertext"
}

decode() {
  local key="$1"
  local ciphertext="$2"
  local plaintext ciphertext_chr key_chr key_size ciphertext_size shift_dist
  local pos shifted_pos
  key_size="${#key}"
  ciphertext_size="${#ciphertext}"
  declare -a letters
  letters=({a..z})
  declare -A letter_indices
  letter_indices=([a]=0 [b]=1 [c]=2 [d]=3 [e]=4 [f]=5 [g]=6 [h]=7 [i]=8 [j]=9 [k]=10
            [l]=11 [m]=12 [n]=13 [o]=14 [p]=15 [q]=16 [r]=17 [s]=18 [t]=19
            [u]=20 [v]=21 [w]=22 [x]=23 [y]=24 [z]=25)

  for ((i = 0; i < ciphertext_size; i++ )); do
    if (( key_size < ciphertext_size )); then
      key_index=$(( i % key_size ))
    else
      key_index="$i"
    fi

    key_chr="${key:key_index:1}"
    plaintext_chr="${ciphertext:i:1}"
    pos="${letter_indices[$plaintext_chr]}"
    shift_dist="${letter_indices[$key_chr]}"
    shifted_pos=$(( (pos - shift_dist) % 26 ))

    plaintext+="${letters[shifted_pos]}"

  done

  echo "$plaintext"
}

die() {
  printf '%s\n' "invalid key" >&2
  exit 1
}

cipher_key=
plaintext=
cmd=
opt=

simple_cipher () {
  while :; do
    case $1 in
      key)
        create_key
        return 0
        ;;
      -k)
        if [[ "$2" ]]; then
          if [[ "$2" == "b" ]]; then
            opt=$2
            shift 
          else
            cipher_key=$2
            shift 
          fi
        else
          die 
        fi
        ;; 
      b)
        if [[ "$2" ]]; then
          cmd=$2
          shift 
        else
          die
        fi
        ;;
      encode)
        if [[ "$2" ]]; then
          cmd=encode
          plaintext=$2
          shift
        fi
        ;;
      decode)
        if [[ "$2" ]]; then
          cmd=decode
          plaintext=$2
          shift
        fi
        ;;
      *)
        break
    esac

    shift
  done

  if [[ "$op" == "b" ]]; then
    local size
    size="${#plaintext}"
    local cipher_key

    for ((i = 0; i < size; i++)); do
      cipher_key+="b"
    done

    plaintext="${plaintext,,}"

  fi

  if ! [[ "$cipher_key" =~ ^[[:lower:]]+$ ]]; then
    die
  fi

  "$cmd" "$cipher_key" "$plaintext"
}

simple_cipher "$@"

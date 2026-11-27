#!/usr/bin/env bash

integer_sqrt() {
  local n="$1" r=0
  local -n out="$2"

  while (( (r + 1) * (r + 1) <= n )); do
    (( r++ ))
  done

  out="$r"
}

reverse_str() {
  local s="$1"
  local -n out="$2"
  local rev="" i

  for (( i = ${#s} - 1; i >= 0; i-- )); do
    rev+="${s:i:1}"
  done

  out="$rev"
}

 make_palindrome() {
  local half="$1"
  local len="$2"
  local -n out="$3"
  local rev=""

  if (( len % 2 == 0 )); then
    reverse_str "$half" rev
  else
    reverse_str "${half:0:${#half}-1}" rev
  fi

  out="${half}${rev}"
}

factors() {
  local -n arr="$1"
  local begin="$2" end="$3" target="$4"
  local i j to min_i start

  arr=()
  integer_sqrt "$target" to

  min_i=$(( (target + end - 1) / end ))
  start=$(( begin > min_i ? begin : min_i ))

  for (( i = start; i <= to; i++ )); do
    if (( target % i == 0 )); then
      j=$(( target / i ))
      if (( j >= begin && j <= end )); then
        arr+=("[$i, $j]")
      fi
    fi
  done

  (( ${#arr[@]} > 0 ))
}

search_palindromes() {
  local mode="$1" from="$2" to="$3"
  local lo=$(( from * from ))
  local hi=$(( to * to ))
  local min_len="${#lo}"
  local max_len="${#hi}"
  local len half_len half_start half_end half cand
  local -a found_factors

  if [[ "$mode" == "largest" ]]; then
    for (( len = max_len; len >= min_len; len-- )); do
      half_len=$(( (len + 1) / 2 ))
      half_start=$(( 10 ** (half_len - 1) ))
      half_end=$(( 10 ** half_len - 1 ))

      for (( half = half_end; half >= half_start; half-- )); do
        make_palindrome "$half" "$len" cand
        if (( cand > hi || cand < lo )); then
          continue
        fi
        if factors found_factors "$from" "$to" "$cand"; then
          echo "$cand: ${found_factors[*]}"
          return 0
        fi
      done
    done
  else
    for (( len = min_len; len <= max_len; len++ )); do
      half_len=$(( (len + 1) / 2 ))
      half_start=$(( 10 ** (half_len - 1) ))
      half_end=$(( 10 ** half_len - 1 ))
      
      for (( half = half_start; half <= half_end; half++ )); do
        make_palindrome "$half" "$len" cand
        if (( cand > hi || cand < lo )); then
          continue
        fi
        if factors found_factors "$from" "$to" "$cand"; then
          echo "$cand: ${found_factors[*]}"
          return 0
        fi
      done
    done
  fi

  printf "no palindrome with factors in the range %d to %d\n" "$from" "$to"
}

main () {
  local action="$1" min="$2" max="$3"

  if (( min > max )); then
    echo "min must be <= max" >&2
    return 1
  fi

  case $action in
    smallest|largest)
      "$action" "$min" "$max"
      ;;
    *) echo "first arg should be 'smallest' or 'largest'" >&2
       return 1
       ;;
  esac
}

main "$@"

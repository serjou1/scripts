_serjou() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local MANIFEST="/usr/local/lib/serjou/manifest.sh"
  [[ ! -f "$MANIFEST" ]] && return

  # shellcheck source=/dev/null
  source "$MANIFEST"

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "install set" -- "$cur") )
    return
  fi

  if [[ $COMP_CWORD -eq 2 && $prev == "install" ]]; then
    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${INSTALLERS[@]}" | cut -d: -f1)" -- "$cur") )
    return
  fi

  if [[ $COMP_CWORD -eq 2 && $prev == "set" ]]; then
    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${SET_COMMANDS[@]}" | cut -d: -f1)" -- "$cur") )
    return
  fi

  if [[ "${COMP_WORDS[1]}" == "set" && "${COMP_WORDS[2]}" == "loki" ]]; then
    COMPREPLY=( $(compgen -W "${SET_FLAGS_loki[*]}" -- "$cur") )
    return
  fi
}

complete -F _serjou serjou

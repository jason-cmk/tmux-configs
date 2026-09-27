#!/bin/sh

set -eu

marker='@window_sidebar'

find_sidebar() {
  tmux list-panes -t "$1" -F "#{pane_id}:#{${marker}}" |
    while IFS=: read -r pane_id is_sidebar; do
      if [ "$is_sidebar" = '1' ]; then
        printf '%s\n' "$pane_id"
        break
      fi
    done
}

render() {
  sidebar_width=$1
  name_width=$((sidebar_width - 7))
  format="#{window_active}|#{window_index}|#{=${name_width}:window_name}"
  pane_id=${TMUX_PANE:?}

  trap 'printf "\033[?25h"; exit 0' HUP INT TERM
  printf '\033[?25l'

  while pane_state=$(tmux display-message -p -t "$pane_id" '#{session_id}|#{window_panes}' 2>/dev/null); do
    session_id=${pane_state%%|*}
    pane_count=${pane_state##*|}
    [ "$pane_count" -gt 1 ] || break

    printf '\033[2J\033[H\033[1m Windows\033[0m\n\n'
    tmux list-windows -t "$session_id" -F "$format" |
      while IFS='|' read -r active index name; do
        if [ "$active" = '1' ]; then
          printf '\033[7m %s: %s\033[0m\n' "$index" "$name"
        else
          printf '  %s: %s\n' "$index" "$name"
        fi
      done
    sleep 1
  done

  printf '\033[?25h'
}

toggle() {
  window_id=$1
  sidebar_pane=$(find_sidebar "$window_id")

  if [ -n "$sidebar_pane" ]; then
    tmux kill-pane -t "$sidebar_pane"
    exit 0
  fi

  sidebar_width=$(tmux show-options -gv @window_sidebar_width 2>/dev/null || true)
  case $sidebar_width in
    ''|*[!0-9]*) sidebar_width=28 ;;
  esac

  window_width=$(tmux display-message -p -t "$window_id" '#{window_width}')
  if [ "$sidebar_width" -lt 12 ] || [ "$window_width" -le $((sidebar_width + 2)) ]; then
    tmux display-message 'Window is too narrow for the tmux sidebar'
    exit 0
  fi

  sidebar_pane=$(
    tmux split-window -bdfh -l "$sidebar_width" -t "$window_id" -P -F '#{pane_id}' \
      "$HOME/.config/tmux/sidebar.sh render '$sidebar_width'"
  )
  tmux set-option -p -t "$sidebar_pane" "$marker" 1
  tmux select-pane -t "$sidebar_pane" -T 'Windows'
}

case ${1:-} in
  toggle)
    [ "$#" -eq 2 ] || exit 2
    toggle "$2"
    ;;
  render)
    [ "$#" -eq 2 ] || exit 2
    render "$2"
    ;;
  *)
    printf 'Usage: %s {toggle WINDOW_ID|render WIDTH}\n' "$0" >&2
    exit 2
    ;;
esac

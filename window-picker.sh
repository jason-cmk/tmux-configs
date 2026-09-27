#!/bin/sh

selection=$(
  tmux list-windows -F '#{window_id} #{window_index}: #{window_name}#{?window_active, *,}' |
    fzf --reverse \
      --header='switch window' \
      --delimiter=' ' \
      --with-nth=2.. \
      --preview="while :; do tmux capture-pane -ep -t {1}; sleep 1; done" \
      --preview-window='right:70%,follow'
) || exit 0

target=${selection%% *}
[ -n "$target" ] && tmux select-window -t "$target"

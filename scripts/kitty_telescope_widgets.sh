#!/usr/bin/env bash
# eval "$(pyenv init -)"
# >> VARIABLES

export LESS="-r"
# export FAVORITE_FOLDERS=("Programação" "Pictures" "Notes" "opt" "Downloads" "Documents")
export dutst=0
export FZF_KITTY_SHORTCUTS="alt-a,\
  alt-A,\
  alt-b,\
  alt-e,\
  alt-f,\
  alt-h,\
  alt-l,\
  alt-p,\
  alt-m,\
  alt-n,\
  alt-N,\
  alt-r,\
  alt-s,\
  alt-t,\
  alt-x,\
  ?,\
  ctrl-r,\
  alt-u,\
  ctrl-s"

# >> FUNCTIONS

## >> Shortcuts Displaying Function
fzfkitty_keys() {
	echo KEY  $'\t\t'  Action
	echo ===  $'\t\t'  ======
	echo Alt-l$'\t\t'"Select/Confirm"
	echo Alt-h$'\t\t'"Cd .."
	echo Alt-a$'\t\t'"Create File"
	echo Alt-A$'\t\t'"Create Dir"
	echo Alt-r$'\t\t'"Remove File/Dir"
	echo Alt-u$'\t\t'"Preview Up"
	echo Alt-d$'\t\t'"Preview Down"
	echo Alt-U$'\t\t'"Page Up"
	echo Alt-D$'\t\t'"Page Down"
	echo Alt-b$'\t\t'"Bookmarks"
	echo Alt-f$'\t\t'"File Grep"
	echo Alt-n$'\t\t'"Markdown Notes"
	echo Alt-N$'\t\t'"LaTeX Notes"
	echo Alt-t$'\t\t'"Todo Widget"
	echo Alt-s$'\t\t'"Session Widget"
	echo Alt-m$'\t\t'"Process Manager"
	echo Ctr-s$'\t\t'"Toggle Sorting"
  echo Ctr-r$'\t\t'"Reload"
	echo Alt-x/Ctr-c$'\t'"Exit"
	echo F5   $'\t\t'"Reload"
	echo ?    $'\t\t'"Show keys"
  exit 0
}


## >> Open Folder
fzfkitty_open_folder() {
  local choice=$(echo "$dir_and_files" | tail -n +2 | sed 's/^[[:digit:]]\+: //')
  if [[ -d $choice && $choice != "." ]]; then
    cd "$choice" || return
  elif [[ -f $choice && $choice != "." ]]; then
    nvim  "$choice" || return
  fi
}

## >> Add Folder
fzfkitty_add_folder() {
  echo -e "\n"
  vared -p 'Enter new directory name: ' -c dir_name 2>/dev/null
  mkdir -p "$dir_name"
  echo -e "\e[1;35m${dir_name}\e[0m Created\n"
}

## >> Add File
fzfkitty_add_file() {
  echo -e "\n"
  vared -p 'Enter new file name: ' -c file_name 2>/dev/null
  touch "$file_name"
  echo -e "\e[1;35m${file_name}\e[0m Created\n"
}

## >> Remove Folder
fzfkitty_remove_folder() {
  local choice=$(echo "$dir_and_files" | tail -n +2 | sed 's/^[[:digit:]]\+: //')
  if [[ -n $choice && $choice != "." ]]; then
    echo -e "\n"
    vared -p 'Delete "$choice" (y/n)? ' -c delete_choice 2>/dev/null
    if [[ $delete_choice == "y" ]]; then
      rm -rf "$choice"
      echo -e "\e[1;31m${choice}\e[0m Deleted\n"
    fi
  fi
}

# - TODO: Add a way to add bookmarks through FZF
## >> Bookmark Navigator
fzfkitty_bookmark_navigator() {
    # Ensure the bookmarks file exists
    if [[ ! -f $BOOKMARKS_FILE ]]; then
        echo "Bookmark file not found. Please create $BOOKMARKS_FILE"
        return
    fi
    # Use fzf to select a bookmark
    # local selected=$(cat "$BOOKMARKS_FILE" | fzf -m +s --with-nth=1  --reverse)
    local selected=$(sed 's#: # -> #' "/home/eduardotc/kitty_telescope_bookmarks" | nl | column -t |  fzf -m +s --with-nth=1,2  --reverse)
    # Check if a selection was made
    if [[ -n $selected ]]; then
        # Change to the selected directory
        cd "$selected" || echo "Failed to change directory to $selected"
    else
        echo "No selection made."
    fi
}

# List all marks
kitty_telescope_lmarks() {
    sed 's#: # -> #' "/home/eduardotc/kitty_telescope_bookmarks"| nl| column -t
}

kitty_telescope_pathmarks_colorize() {
    local field='\(\S\+\s*\)'
    local esc=$(printf '\033')
    local N="${esc}[0m"
    local R="${esc}[31m"
    local G="${esc}[32m"
    local Y="${esc}[33m"
    local B="${esc}[34m"
    local pattern="s#^${field}${field}${field}${field}#$Y\1$R\2$N\3$B\4$N#"
    # Use GNU sed if possible
    # BSD sed(default sed on mac) can not display color by this pattern
    (( $+commands[gsed] )) && gsed "$pattern" || sed "$pattern"
}
kitty_telescope_marks() {
    kitty_telescope_lmarks | kitty_telescope_pathmarks_colorize
}
zle -N kitty_telescope_marks
# -TODO: Add a configuration option for automatic definition of this html port
## >> Note Edition
fzfkitty_notes() {
  cd /home/eduardotc/Notes
  if [ -n "$(netstat -na | grep :8228 | grep LISTEN)" ]; then
    npx kill-port 8228
  fi
  while true; do

    local md=$(\
    fd -t f -e md . | \
    fzf +m +s --no-mouse --sync --with-nth=1 \
    --preview="kitty_telescope_preview.sh {}" \
    --expect='alt-a,alt-x,alt-l,alt-r,alt-A,alt-h'\
  )

    key_pressed=$(head -1 <<< "$md")
    case $key_pressed in
      alt-l)
        nvim +'setfiletype markdown' +MarkdownPreview  -n -- "${md}"
        ;;
      alt-a)
        fzfkitty_add_file
        ;;
      alt-A)
        fzfkitty_add_folder
        ;;
      alt-h)
        cd ..
        ;;
      alt-r)
        fzfkitty_remove_folder
        ;;
      alt-x)
        break
        ;;
    esac
  done
}

## >> Manage Neovim Sessions
# -TODO: Add a configuration to define this sessions folder automatic
fzfkitty_session_manager() {
  cd "/home/eduardotc/Programação/vim"
  local sess
  # sess=$(find . -type f  | fzfkitty_basic_exec -m --with-nth=1 --bind=\
  sess=$(fd -t f . | fzf -m --with-nth=1 --preview="kitty_telescope_preview.sh {}")
  if [ -f "$sess" ]; then
    nvim -n -S "$sess" --listen unix:@nvim
  fi
}

## >> Latex Management
fzfkitty_latex() {
  cd '/home/eduardotc/Programação/LaTeX'
  selected_file=$(find '.' -type f -name '*.tex' 2>/dev/null | fzf +s --tiebreak "length","chunk","end" --preview="kitty_telescope_preview.sh {}")
  if [[ -f $selected_file ]]; then
    nvim "$selected_file"
  fi
}

## >> File Grep
fzfkitty_file_grep() {
  selected_file=$(find '.' -type f | fzf +s +m --preview="kitty_telescope_preview.sh {}")
  if [[ -f $selected_file ]]; then
    xdg-open "$selected_file"
  fi
}


## >> Process Manager
# -TODO: Add a shortcut to toggle recursive search at current search
# -TODO: Add necessary shortcuts from this widget in the others invoked widgets
fzfkitty_ps_manage() {
  (date; ps -ef) |
    fzf --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
        --preview='echo {}' --preview-window=down,3,wrap \
        --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
}

## >> Marker
_fzf_marker_main_widget() {
  if echo "$BUFFER" | grep -q -P "{{"; then
    _fzf_marker_placeholder
  else
    local selected
    if selected=$(cat ${FZF_MARKER_CONF_DIR:-~/.config/marker}/*.txt |
      sed -e "s/\(^[a-zA-Z0-9_-]\+\)\s/${FZF_MARKER_COMMAND_COLOR:-\x1b[38;5;255m}\1\x1b[0m /" \
          -e "s/\s*\(#\+\)\(.*\)/${FZF_MARKER_COMMENT_COLOR:-\x1b[38;5;8m}  \1\2\x1b[0m/" |
      fzf --bind 'tab:down,btab:up' --height=80% --ansi -q "$LBUFFER"); then
      LBUFFER=$(echo $selected | sed 's/\s*#.*//')
    fi
    zle redisplay
  fi
}
read_until_blank() {
  local target_line="$1"
  local file_path="$2"
  local start_reading=false

  while IFS= read -r line; do
    # If we've started reading and encounter a blank line, stop.
    if [[ $start_reading == true && -z $line ]]; then
      break
    fi

    # If we find the target line, start reading from the next line.
    if [[ $line == $target_line ]]; then
      start_reading=true
      continue
    fi

    # Read the lines after the target line until a blank line.
    if [[ $start_reading == true ]]; then
      echo "$line"
    fi
  done < "$file_path"
}

_fzf_marker_placeholder() {
  local strp pos placeholder
  strp=$(echo $BUFFER | grep -Z -P -b -o "\{\{[\w]+\}\}")
  strp=$(echo "$strp" | head -1)
  pos=$(echo $strp | cut -d ":" -f1)
  placeholder=$(echo $strp | cut -d ":" -f2)
  if [[ -n "$1" ]]; then
    BUFFER=$(echo $BUFFER | sed -e "s/{{//" -e "s/}}//")
    CURSOR=$(($pos + ${placeholder} - 4))
  else
    BUFFER=$(echo $BUFFER | sed "s/$placeholder//")
    CURSOR=pos
  fi
}

_fzf_marker_placeholder_widget() { _fzf_marker_placeholder "defval" }



fzf-mamba-activate () {
  choice=(
    $(
       mamba env list |
       sed 's/\*/ /;1,2d' |
       xargs -I {} zsh -c '
       name_path=( {} );
       py_version=( $(${name_path[1]}/bin/python --version) );
       echo ${name_path[0]} ${py_version[1]} ${name_path[1]}
       ' |
       column -t |
       fzf --layout=reverse \
         --info=inline \
         --border=rounded \
         --height=40 \
         --preview-window="right:30%" \
         --preview-label=" mamba tree leaves " \
         --preview=$'
           mamba info {} |
           perl -F\'[^\\w-_]\' -lae \'print for grep /./, @F;\' |
           sort
           '
        )
    )
    [[ -n "$choice" ]] && mamba activate "$choice"
}

## >> Man Browser
fzfkitty_man_widget() {
  batman="man {1} | col -bx | bat --language=man --plain --color always --theme=\"Monokai Extended\""
   man -k . | sort \
   | awk -v cyan=$(tput setaf 6) -v blue=$(tput setaf 4) -v res=$(tput sgr0) -v bld=$(tput bold) '{ $1=cyan bld $1; $2=res blue;} 1' \
   | fzf  \
      -q "$1" \
      --ansi \
      --tiebreak=begin \
      --prompt=' Man > '  \
      --preview-window '50%,rounded,<50(up,85%,border-bottom)' \
      --preview "${batman}" \
      --bind "enter:execute(man {1})" \
      --bind "alt-c:+change-preview(cht.sh {1})+change-prompt(ﯽ Cheat > )" \
      --bind "alt-m:+change-preview(${batman})+change-prompt( Man > )" \
      --bind "alt-t:+change-preview(tldr --color=always {1})+change-prompt(ﳁ TLDR > )"
  zle reset-prompt
}

du-mambaa() {
  declare -A icons
  icons[base]="🌍"
  icons[sioyek]="🐍"
  icons[nvim]="🔥"
  envs=$(mamba env list | awk '{print $1 " " $2}' | sed -n '1!p')
  fzf_list=()
  while read -r line; do
    env_name=$(echo $line | awk '{print $1}')
    env_path=$(echo $line | awk '{print $2}')
    icon=${icons[$env_name]:-"❓"} # Default icon if not specified in the array
    fzf_list+=("$icon $env_name" "$env_path")
  done <<< "$envs"
  selected_env=$(printf "%s\n" "${fzf_list[@]}" | fzf --with-nth 1 --delimiter ' ' --preview 'env_name=$(echo {2} | awk "{print \$2}"); env_path=$(echo {2} | cut -d" " -f3-); python_version=$(mamba run -n $env_name python --version 2>&1); env_size=$(du -sh $env_path 2>&1 | cut -f1); echo "Python Version: $python_version\nTotal Size: $env_size"' --preview-window=down:3:wrap)
  selected_env_name=$(echo $selected_env | awk '{print $2}')
  echo "Selected environment: $selected_env_name"
}

fzfkitty_bibtex_widget() {
  python bibtex_parser.py your_bibtex_file.bib > titles.txt
  fzf < titles.txt --preview 'grep -A 10 -i "{}" /tmp/bibtex_details.txt' --preview-window down:50%
}

# >> MAIN FUNCTION
# -TODO: Add Reload in  ctr-r
# -TODO: See a way of passing my default configured shortcut keys to fzf installation
fzfkitty_main_widget() {
  # local predefined_folders="$FAVORITE_FOLDERS"
  local predefined_folders=("Programação":"Pictures":"Notes":"opt":"Downloads":"Documents")
  local existing_predefined_folders=()
  local all_folders
  local dir
  while true; do
    # Clear existing predefined folders list
    existing_predefined_folders=()

    # Check each predefined folder and add it to the list if it exists in the current directory
    for folder in "${predefined_folders[@]}"; do
      if [[ -d "$folder" ]]; then
        existing_predefined_folders+=("$folder")
      fi
    done
    all_folders=$(find . -type d -maxdepth 1 ! -name '.*' -exec basename {} \; 2>/dev/null )
    all_files=$(find . -type f -maxdepth 1 ! -name '.*' -exec basename {} \; 2>/dev/null )
    dir_and_files=$(
      printf \
      "%b" "\e[1;36m${existing_predefined_folders[@]}\e[0m" \
      "${all_folders}" \
      "\n" \
      "\n\e[1;36m-------------------------------\e[0m\n" \
      "\n" \
      "$all_files" | \
      uniq | nl \
      -w1 \
      -bt \
      -s ': ' | \
      fzf \
      --no-mouse \
      --height 85% \
      +s \
      +m \
      --reverse \
      --sync \
      --header-lines=0 \
      --bind 'ctrl-s:reload-sync(fzf)+toggle-sort' \
      --bind 'f5:reload-sync(fzf)' \
      --expect="alt-a,alt-A,alt-b,alt-e,alt-f,alt-h,alt-l,alt-p,,alt-m,alt-n,alt-N,alt-r,alt-s,alt-t,alt-x,?,ctrl-r,alt-u,ctrl-s,alt-B" \
          --ansi \
          --preview="kitty_telescope_preview.sh {-1}")
    key_pressed=$(head -1 <<< "$dir_and_files")
    case $key_pressed in
      alt-a)
        fzfkitty_add_folder "${dir_and_files}"
        ;;
      alt-A)
        fzfkitty_add_file "${dir_and_files}"
        ;;
      alt-b)
        fzfkitty_bookmark_navigator
        ;;
      alt-B)
        kitty_telescope_marks
        ;;
      alt-e)
        /home/eduardotc/.local/neovim/_build/bin/nvim -n -S {} --listen unix:@nvim
        ;;
      alt-f)
        fzfkitty_file_grep
        ;;
      alt-h)
        cd ..
        ;;
      alt-u)
        # echo "Key: ${mdwg_key}   File: ${Key}"
        # echo "File: ${string_b}"
        # echo "${@}"
        ;;
      ctrl-o|alt-l)
        fzfkitty_open_folder $1
        ;;
      alt-m)
        fzfkitty_ps_manage
        ;;
      alt-n)
        fzfkitty_notes
        ;;
      alt-N)
        fzfkitty_latex
        ;;
      alt-r)
        fzfkitty_remove_folder
        ;;
      alt-s)
        fzfkitty_session_manager
        ;;
      alt-t)
        todofzf ~/Notes/todo/todo.txt
        ;;
      ?)
        fzfkitty_keys | fzf --reverse --print-query --disabled --no-mouse > /dev/tty | cat  > /dev/tty
        # fzfkitty_keys | fzf --reverse --bind "f1:execute(vim {} < /dev/tty > /dev/tty 2>&1)"
        # fzfkitty_keys | fzf --reverse --print-query --disabled --no-mouse -0  > /dev/tty | less --no-search-headers --no-keypad 2>/dev/tty
        ;;
      alt-x)
        break
        ;;
    esac
  done
}
bindkey -r '\e '
bindkey -r '\e[j'
bindkey -r '\e[k'
# >> ZLE LOADING WIDGETS

zle -N fzfkitty_open_folder
zle -N fzfkitty_add_folder
zle -N fzfkitty_remove_folder
zle -N fzfkitty_file_grep
zle -N fzfkitty_notes
zle -N fzfkitty_bookmark_navigator
zle -N fzfkitty_ps_manage
zle -N fzfkitty_keys
zle -N _fzf_marker_main_widget
zle -N _fzf_marker_placeholder_widget
zle -N fzfkitty_man_widget
zle -N fzfkitty_main_widget

# >> BINDKEYS



bindkey -s '\e '          'fzfkitty_main_widget\n'     # A-Spc
bindkey '^h' fzfkitty_man_widget
bindkey "${FZF_MARKER_MAIN_KEY:-\C-@}" _fzf_marker_main_widget
bindkey "${FZF_MARKER_PLACEHOLDER_KEY:-\C-v}" _fzf_marker_placeholder_widget

# vim:ft=sh

#!/usr/bin/env zsh

# Make all less invocations interpret ANSI colors
export LESS="-r"

# Add preferred folders here
FAVORITE_FOLDERS=("Programação" "Pictures" "Notes" "opt" "Downloads" "Documents")

# FZF shortcuts help header definition
DEFAULT_FZF_WIDGET_HEADERS="\
CTRL-O       Select          ALT-H        Cd ..
ALT-L        Select          CTRL-X       Exit
CTRL-A       Create Dir      CTRL-R       Remove Dir
CTRL-B       Bookmarks       CTRL-S       Toggle Sort
ALT-SHIFT-U  Page Up         ALT-SHIFT-D  Page Down
CTRL-F       File Grep       CTRL-M       Markdown Searching
CTRL-E       Explore         ALT-D        Preview Down
ALT-U        Preview Up      CTRL-C       Exit
F1           Toggle Header   F5           Reload
"


# Shortcuts Displaying function, toggled with '?'
if [ "${_TASKFZF_SHOW}" = "keys" ]; then
	echo KEY $'\t'Action
	echo === $'\t'======
	echo D$'\t\t'"Mark tasks as Done"
	echo X$'\t\t'"Delete tasks"
	echo U$'\t\t'"Undo last action"
	echo E$'\t\t'"Edit selected tasks with \$EDITOR"
	echo T$'\t\t'"Add a new task"
	echo I$'\t\t'"Add a new task, with context of the currently highlighted task"
	echo A$'\t\t'"Append to first selected task"
	echo N$'\t\t'"Annotate the first selected task"
	echo M$'\t\t'"Modify the first selected task"
	echo R$'\t\t'"Change report"
	echo C$'\t\t'"Change context"
	echo CTRL-R$'\t'"Reload the current report"
	echo S$'\t\t'"Start task"
	echo P$'\t\t'"Stop task"
	echo ?$'\t\t'"Show keys"
	exit 0
fi

# Navigate between pre defined folders and paths in the BOOKMARKS_FILE text file
# - TODO: Add a way to add bookmarks through FZF
bookmark_navigator() {
    # Ensure the bookmarks file exists
    if [[ ! -f $BOOKMARKS_FILE ]]; then
        echo "Bookmark file not found. Please create $BOOKMARKS_FILE"
        return
    fi

    # Use fzf to select a bookmark
    local selected=$(cat "$BOOKMARKS_FILE" | fzf --height=70% --reverse --preview="kitty_telescope_preview.sh {}")

    # Check if a selection was made
    if [[ -n $selected ]]; then
        # Change to the selected directory
        cd "$selected" || echo "Failed to change directory to $selected"
    else
        echo "No selection made."
    fi
}

# Markdown edition FZF function
# -TODO: Add a configuration option for automatic definition of this html port
markdown_du() {
  cd /home/eduardotc/Programação/markdown
  if [ -n "$(netstat -na | grep :8228 | grep LISTEN)" ]; then
    npx kill-port 8228
  fi
  md=$(fd -t f -e md . | fzf -m --with-nth=1 --bind "ctrl-e:execute(nvim {})+abort" --preview="kitty_telescope_preview.sh {}")
  if [ -f "$md" ]; then
    #floorp --new-tab
    nvim +'setfiletype markdown' +MarkdownPreview  -n -- "${md}"
  fi
}

# Manage neovim sessions containing folder
# -TODO: Add a configuration to define this sessions folder automatic
fzf_session_manager() {
  cd "/home/eduardotc/Programação/vim"
  local sess
  sess=$(find . -type f  | fzf -m --reverse --sync +s --bind=\
"ctrl-e:\
become(/home/eduardotc/.local/neovim/_build/bin/nvim -n -S {} --listen unix:@nvim),\
ctrl-x:\
execute(rm -i {})+accept,\
ctrl-r:\
execute(vared -p 'Enter new Session Name: ' -c sess_new_name && mv {} \"./\$sess_new_name\" )+accept" \
--preview="kitty_telescope_preview.sh {}" \
--header="CTRL-E Edit    CTRL-X Delete    CTRL-R Rename" \
--header-lines=0)
}

# Latex projects management function
latex_du() {
  cd '/home/eduardotc/Programação/LaTeX'
  local du_bind1="ctrl-a:execute(vared -p 'Enter new directory name: ' -c dir_name &&  mkdir -p \"./\$dir_name\" )"
  local du_bind2="ctrl-x:execute(rm -rf {} && echo -e \"Removed {}\" )"
  local du_bind3="ctrl-r:reload(find '.' -type f -name '*.tex' 2>/dev/null)"
  local du_bind4="ctrl-z:become(todofzf '/home/eduardotc/Notes/todo/todo.txt')"
  local du_bind="${du_bind1},${du_bind2},${du_bind3},${du_bind4}"

  local du_preview="kitty_telescope_preview.sh {}"

  local du_header="CTRL-R to reload  CTRL-A to add folder  CTRL-X to remove"

  selected_file=$(find '.' -type f -name '*.tex' 2>/dev/null | fzf +s --tiebreak "length","chunk","end" --bind "$du_bind" --header "$du_header" --preview "$du_preview")
  if [[ -f $selected_file ]]; then
    nvim "$selected_file"
  fi
}

file_grep() {
  selected_file=$(find '.' -type f | fzf +s +m --preview "kitty_telescope_preview.sh {}")
  if [[ -f $selected_file ]]; then
    xdg-open "$selected_file"
  fi
}

# Main files preview, directoryes surfing, and other utils
# -TODO: Add a shortcut to toggle recursive search at current search
# -TODO: Add necessary shortcuts from this widget in the others invoked widgets
dir_instant_grep() {
  local predefined_folders="$FAVORITE_FOLDERS" # Add preferred folders here
  local existing_predefined_folders=()
  local all_folders
  local dir
  bindkey -r '\e[j'
  bindkey -r '\e[k'

  while true; do
    # Clear existing predefined folders list
    existing_predefined_folders=()

    # Check each predefined folder and add it to the list if it exists in the current directory
    for folder in "${predefined_folders[@]}"; do
      if [[ -d "$folder" ]]; then
        existing_predefined_folders+=("$folder")
      fi
    done

    # Generate a list of all folders, excluding hidden ones and add existing predefined folders at the start
    all_folders=$(find . -type d -maxdepth 1 ! -name '.*' -exec basename {} \; 2>/dev/null )
    all_files=$(find . -type f -maxdepth 1 ! -name '.*' -exec basename {} \; 2>/dev/null )
    # Use fzf to select a folder, with predefined folders (if they exist) listed first
    local dir_and_files=$(printf "%b" "\e[1;36m${existing_predefined_folders[@]}\e[0m" "${all_folders}" "\n" "\n\e[1;36m-------------------------------\e[0m\n" "\n" "$all_files" | \
          uniq | nl -w1 -bt -s ': ' | \
          fzf --no-mouse --height 85% +s +m --reverse --sync \
          --bind="ctrl-x:abort,f1:reload-sync(fzf)+toggle-header,ctrl-s:reload-sync(fzf)+toggle-sort,alt-K:page-up,alt-J:page-down,f5:reload-sync(fzf),alt-d:preview-down,alt-u:preview-up,alt-U:preview-page-up,alt-D:preview-page-down" \
          --expect='ctrl-o,alt-h,alt-l,ctrl-a,ctrl-R,ctrl-B,ctrl-F,ctrl-M,ctrl-E' \
          --header="$DEFAULT_FZF_WIDGET_HEADERS" \
          --header-lines=0 \
          --header-first \
          --ansi \
          --preview="kitty_telescope_preview.sh {-1}")

    # Expecting multiple keys: ctrl-o for selecting, ctrl-x to exit, and ctrl-h to go up a directory
    key_pressed=$(head -1 <<< "$dir_and_files") # This captures the key pressed: ctrl-o or ctrl-h
    case $key_pressed in
      ctrl-o|alt-l)
        local choice=$(echo "$dir_and_files" | tail -n +2 | sed 's/^[[:digit:]]\+: //')
        if [[ -d $choice && $choice != "." ]]; then
          cd "$choice" || return
        elif [[ -f $choice && $choice != "." ]]; then
          nvim  "$choice" || return
        fi
        ;;
      alt-h)
        cd ..
        ;;
      ctrl-a)
        echo -e "\n"
        vared -p 'Enter new directory name: ' -c dir_name 2>/dev/null
        mkdir -p "$dir_name"
        echo -e "\e[1;35m${dir_name}\e[0m Created\n"
        ;;
      ctrl-R)
        local choice=$(echo "$dir_and_files" | tail -n +2 | sed 's/^[[:digit:]]\+: //')
        if [[ -n $choice && $choice != "." ]]; then
          echo -e "\n"
          vared -p 'Delete "$choice" (y/n)? ' -c delete_choice 2>/dev/null
          if [[ $delete_choice == "y" ]]; then
            rm -rf "$choice"
            echo -e "\e[1;31m${choice}\e[0m Deleted\n"
          fi
        fi
        ;;
      ctrl-B)
        bookmark_navigator
        ;;
      ctrl-F)
        file_grep
        ;;
      ctrl-M)
        markdown_du
        ;;
      *)
        break
        ;;
    esac
  done
}

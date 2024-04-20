#!/usr/bin/env zsh

# >> INITIAL VARIABLES

declare -x TMP_FOLDER="/tmp/vimg"
mkdir -p $TMP_FOLDER

# >> PREVIEW FUNCTIONS

## >> Img Preview
kitty_telescope_img_preview() {
  local img_wh=$(identify -format '%w %h' "${1}")
  echo -e "Widht  x  Height \n"
  echo -e "\n\e[1;33m ${img_wh} \e[0m\n"
  kitty icat --transfer-mode=stream --unicode-placeholder --stdin=no --place="${2}@0x0" "${1}"
}

## >> Dir Preview
kitty_telescope_dir_preview() {
  echo -e "\e[1;36mSize\e[0m"
  echo -e "\e[1;36m----\e[0m\n"
  du -sh "${1}"
  echo -e "\n"
  echo -e "\e[1;35mFiles\e[0m"
  echo -e "\e[1;35m-----\e[0m\n"
  ls --almost-all --color=always --hide-control-chars "${filecomp}" | tail --lines=+2
}

## >> PDF Preview
kitty_telescope_pdf_preview() {
  local page_num=1
  update_preview() {
    local ktpdf="$1"
    local ktpg="$2"
    # pdftoppm "${filecomp}" "${TMP_FOLDER}/${filecomp}-${page_num}" -f "$page" -l "$page" -png
    pdftoppm "$pdf" "${TMP_FOLDER}/${ktpg}" -f "$ktpg" -l "$ktpg" -png
    # kitty icat --clear --transfer-mode=stream --unicode-placeholder --stdin=no --place="${dim}@0x0" "$temp_dir/page-1.png"
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${dim}@0x0" "${TMP_FOLDER}/${ktpg}.png"
  }

  echo -e "Loading preview..\nFile: ${filecomp}"
  echo "TEEEEEEE"
  bindkey -s '\ez' 'echo "${TMP_FOLDER}"\n'
  bindkey -s '\eg' 'echo "${TMP_FOLDER}"\n'
  bindkey '\eq' fzf-history-widget
  read -k
  # rm -rf $(find "${TMP_FOLDER}" -type f -name "*-*.png")
}

# >> MAIN FUNCTION

kitty_telescope_parse_options() {
  # Extracts the exntension part of the file full string
  local extension="${1##*.}"
  # Attributing complete file string variable
  local filecomp="${1#*: }"
  # Attributing dimensions of the screen if FZF has defined
  local dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
  # If both above FZF variables aren't defined:
  if [[ $dim = x ]]; then
    # Defines diametter by the stty command
    local dim=$(stty size  | awk '{print $2 "x" $1}')
  fi

  # Defining the preview command to execute based on file extension
  case "${extension}" in
    # Text like files
    txt | md | py | sh | json | css | desktop | tex | lua | vim | conf)
      # Simple pygmentize output from the file
      pygmentize -O style=dracula -f terminal256 -g "${filecomp}"
      ;;
    # Image like files
    jpg | png | jpeg | webp | svg)
      kitty_telescope_img_preview "${filecomp}" "${dim}"
      ;;
    # Documents like files
    pdf | epub)
      kitty_telescope_pdf_preview "{filecomp}"
      # du_live_pdf_preview "${filecomp}"
      ;;
    # Other files
    du)
      echo "teste"
      ;;
    *)
      # If file is a directory
      if [[ -d "${filecomp}" ]]; then
        kitty_telescope_dir_preview "${filecomp}"
        # return
      else
        # Check if the file is a binary
        filetype=$(file --mime "${filecomp}" | grep -oP 'charset=\K[^;]+')
        # If the file is a binary
        if [[ $filetype == binary ]]; then
          echo -e "\n"
          echo -e "\e[1;31mFile is Binary, and will not be read. \e[0m"
          echo -e "\n"
          # return
        # Other cases, a warning message about unrecognized extension will be displayed,
        #  and a simple pygmentize file output will be displayed
        else
          echo -e "\n"
          echo -e "\e[1;31mUnrecognized Extension \e[0m"
          echo -e "\n"
          pygmentize -O style=dracula -f terminal256 -g "${filecomp}"
          # return
        fi
      fi
      ;;
  esac
}

kitty_telescope_parse_options "${@}"
read -r

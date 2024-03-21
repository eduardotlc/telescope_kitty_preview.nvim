#!/usr/bin/env bash

#INITIAL VARIABLES
declare -x PREVIEW_ID="preview"
declare -x TMP_FOLDER="/tmp/vimg"
mkdir -p $TMP_FOLDER

#KITTY PREVIEW
function du_kitty_preview {
  if [[ $# -ne 1 ]]; then
    >&2 echo "usage: $0 FILENAME"
    exit 1
  fi

  file=${1/#\~\//$HOME/}

  # dim defines the fzf preview window dimensions
  dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
  if [[ $dim = x ]]; then
    dim=$(stty size < /dev/tty | awk '{print $2 "x" $1}')
  elif ! [[ $KITTY_WINDOW_ID ]] && (( FZF_PREVIEW_TOP + FZF_PREVIEW_LINES == $(stty size < /dev/tty | awk '{print $1}') )); then
    # Avoid scrolling issue when the Sixel image touches the bottom of the screen
    # * https://github.com/junegunn/fzf/issues/2544
    dim=${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))
  fi

  # 1. Use kitty icat on kitty terminal
  if [[ $KITTY_WINDOW_ID ]]; then
    # 1. 'memory' is the fastest option but if you want the image to be scrollable,
    #    you have to use 'stream'.
    #
    # 2. The last line of the output is the ANSI reset code without newline.
    #    This confuses fzf and makes it render scroll offset indicator.
    #    So we remove the last line and append the reset code to its previous line.
    kitty icat --clear --transfer-mode=stream --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed '$d' | sed $'$s/$/\e[m/'

  else
    file "$file"
  fi
}

# Directory preview function for fzf
du_dir_preview() {
  # Ensure the target is a directory
  if [[ -d "$1" ]]; then
    # Display directory size
    echo "Total size:"
    du -sh "$1" 2> /dev/null

    # List up to the first 10 files in the directory
    echo "Files:"
    ls -lAh --color=always "$1" | head -n 11
  fi
}


#DRAW PREVIEW
function du_draw_preview {
    if ! command -v pdftoppm &> /dev/null; then
      echo -e "pdftoppm could not be found in your path,\nplease install it to display media content"
      exit
    fi

    if ! command -v icat &> /dev/null; then
      echo -e "icat could not be found in your path,\nplease install it to display media content"
      exit
    fi

    if ! command -v awk &> /dev/null; then
      echo -e "awk could not be found in your path,\nplease install it to display media content"
      exit
    fi

    if [[ "$1" == "imagepreview" ]]; then
      du_kitty_preview "${2}"

    elif [[ "$1" == "pdfpreview" ]]; then
        path="${2##*/}"
        total_pages=$(pdfinfo "${2}" | grep 'Pages' | awk '{print $2}')
        echo -e "Loading preview..\nFile: $path"
        if [ "$total_pages" -le 1 ]; then
          [[ ! -f "${TMP_FOLDER}/${path}.png" ]] && pdftoppm -png -r 300 -singlefile "$2" "${TMP_FOLDER}/${path}"
        else
          [[ ! -f "${TMP_FOLDER}/${path}.png" ]] && pdftoppm -png -r 300 -f 1 -l 2 "$2" "${TMP_FOLDER}/${path}"
          if [ "$total_pages" -gt 1 ] && [ "$total_pages" -le 10 ]; then
            montage "${TMP_FOLDER}/${path}-1.png" "${TMP_FOLDER}/${path}-2.png" -tile 2x1 -geometry +0+0 "${TMP_FOLDER}/${path}.png"
          elif [ "$total_pages" -gt 10 ] && [ "$total_pages" -le 100 ]; then
            montage "${TMP_FOLDER}/${path}-01.png" "${TMP_FOLDER}/${path}-02.png" -tile 2x1 -geometry +0+0 "${TMP_FOLDER}/${path}.png"
          elif [ "$total_pages" -gt 100 ] && [ "$total_pages" -le 1000 ]; then
            montage "${TMP_FOLDER}/${path}-001.png" "${TMP_FOLDER}/${path}-002.png" -tile 2x1 -geometry +0+0 "${TMP_FOLDER}/${path}.png"
          fi
        fi
        du_kitty_preview "${TMP_FOLDER}/${path}.png"
    fi
}

#MAIN FUNCTION
function parse_options {
  extension="${1##*.}"
  case $extension in
    txt | md | py | sh | json | css | desktop | tex | lua | vim)
      pygmentize -O style=dracula -f terminal256 -g "$1"
      ;;
    jpg | png | jpeg | webp | svg)
      du_draw_preview  imagepreview "$1"
      ;;
    pdf | epub)
      du_draw_preview  pdfpreview "$1"
      ;;
    *)
      filetype=$(file --mime "$1" | grep -oP 'charset=\K[^;]+')
      if [[ -d "$1" ]]; then
        echo -e "\e[1;36mTotal size:\e[0m\n"
        du -sh "$1" 2> /dev/null
        echo -e "\n"
        echo -e "\e[1;35mFiles:\e[0m\n"
        # Uncomment following line for more detailed file listing
        #ƛ ls -F -C -o -q -h --color=always | head -n 11
        ls -F -C -h --color=always "$1" | head -n 18
        return
      elif [ "$filetype" == binary ]; then
        echo -e "\n"
        echo -e "\e[1;31mFile is Binary, and will not be read. \e[0m"
        echo -e "\n"
        return
      else
        echo -e "\n"
        echo -e "\e[1;31mUnrecognized Extension \e[0m"
        echo -e "\n"
        pygmentize -O style=dracula -f terminal256 -g "$1"
      fi
      ;;
  esac
}

parse_options "${@}"
read -r

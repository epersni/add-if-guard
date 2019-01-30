#!/bin/bash

print_usage()
{
  cat <<EOF
$(basename "$0") [-hf] file -- program to add ifndef-define guard to a header file

where:
    -h  show this help text
    -f  force action even if file is not a header file (h,hpp)
EOF
}

while getopts 'fh:' option; do
  case "$option" in
    f) FORCE=true
       ;;
    h) print_usage
       exit
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       print_usage
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       print_usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ "$1" = "" ]; then
  print_usage
	exit
fi

filename=$(basename "$1")
extension=${filename##*.}

add_ifguard()
{
    local file=$1
		sed -i "1i#ifndef $(echo $filename | tr '[:lower:]' '[:upper:]' | tr '.' "_")" ${file}
		sed -i "2i#define $(echo $filename | tr '[:lower:]' '[:upper:]' | tr '.' "_")" ${file}
		echo "#endif" >> $1
}

if [ "$extension" != "hpp" -a "$extension" != "h" ]; then
  if [ "$FORCE" == "true" ]; then
    add_ifguard $1
  else
    read -p "$1 is not a header file. Do you want to continue anyway? [y/n]" -n 1 -r
    echo    # (optional) move to a new line
	  if [[ $REPLY =~ ^[Yy]$ ]]; then
      add_ifguard $1
    fi
  fi
else
  add_ifguard $1
fi


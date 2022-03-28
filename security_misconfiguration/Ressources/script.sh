#!/bin/bash

if [ $# -ne 1 ]; then
	echo "usage: $0 IP"
	exit
fi

urls=("http://$1/.hidden/")
auto_index_time_regex="\w\+-\w\+-\w\+ \w\+:\w\+"

while [ ${#urls[@]} -ne 0 ]; do
  url=${urls[0]}
  urls=(${urls[@]:1})

  index=$(curl --silent "$url" | grep "$auto_index_time_regex" | tr --delete "\r")

  directories=($(echo "$index" | grep -- "-$" | tr "<>" "|" | cut --delimiter "|" -f 3))
  files=($(echo "$index" | grep --invert-match -- "-$" | tr "<>" "|" | cut --delimiter "|" -f 3))

  new_urls=()
  for directory in ${directories[@]}; do
    new_urls+=("$url$directory")
  done
  urls=(${new_urls[@]} ${urls[@]})

  for file in ${files[@]}; do
    echo -n "$url$file : "
    curl --silent "${url}${file}"
  done
done

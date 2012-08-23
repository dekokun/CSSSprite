#!/usr/bin/env bash

usage(){
  echo $0 directory all_icon_image
}

function is_anime(){
  local image=$1
  image_count=`identify $image | wc -l`
  if [ $image_count -gt 1 ]; then
    return 0
  else
    return 1
  fi
}

if [ -z "$1" -o -z "$2" ]; then
  usage
  exit
fi

bin_dir=`dirname $0`
result_dir=`mktemp -d $bin_dir/result/XXXXXXX`
tmp_dir=$bin_dir/tmp

directory=$1
joined_image_base=$2
joined_image=$result_dir/$joined_image_base

css_base="sprite_`basename $directory`.css"
css=$result_dir/$css_base
html="$result_dir/sprite_`basename $directory`.html"
echo "<link rel=\"stylesheet\" href=\"$css_base\" />" > $html

now_height=0
is_first=true
for new_icon in $directory/*; do
  if is_anime $new_icon; then
    echo "<img src=\"$new_icon\">" >> $html
  else
    if $is_first; then
      cp -p $new_icon $joined_image
      is_first=false
    else
      tmp_file=`mktemp $tmp_dir/temp.XXXX`
      convert -append $joined_image $new_icon $tmp_file
      mv $tmp_file $joined_image
    fi
    id_name=`basename $new_icon | sed -e's/_//' | cut -d'.' -f1`
    icon_height=`identify -format "%h" $new_icon`
    icon_width=`identify -format "%w" $new_icon`
    (echo "div.sprite-$id_name {"
    echo "      width: ${icon_height}px;"
    echo "      height: ${icon_width}px;"
    echo "      background-image: url(\"$joined_image_base\");"
    echo "      background-repeat: no-repeat;"
    echo "      background-position: 0 -${now_height}px;"
    echo "}") >> $css
    echo "<div class=\"sprite-$id_name\"></div>" >> $html
    now_height=`expr $now_height + $icon_height`
  fi
done

echo joined image : $joined_image
echo css example  : $css
echo html example : $html

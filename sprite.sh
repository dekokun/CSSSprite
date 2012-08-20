usage(){
  echo $0 directory all_icon_image_name
}

if [ -z "$1" -o -z "$2" ]; then
  usage
  exit
fi

directory=$1   
new_icon_map=$2

css="./sprite_`basename $directory`.css"  
html="./sprite_`basename $directory`.html"
rm -f $css 
rm -f $html
echo "<link rel=\"stylesheet\" href=\"$css\" />" > $html

now_height=0 
is_first=true
for new_icon in $directory/*; do
  if $is_first; then
    cp -p $new_icon $new_icon_map
    is_first=false
  else
    convert -append $new_icon_map $new_icon $new_icon_map
  fi
  id_name=`basename $new_icon | sed -e's/_//' | cut -d'.' -f1`
  icon_height=`identify -format "%h" $new_icon`
  icon_width=`identify -format "%w" $new_icon`
  (echo "div#logo$id_name {"
  echo "      width: ${icon_height}px;"
  echo "      height: ${icon_width}px;"
  echo "      background-image: url(\"$new_icon_map\");"
  echo "      background-repeat: no-repeat;"
  echo "      background-position: 0 -${now_height}px;"
  echo "}") >> $css
  echo "<div id=\"logo$id_name\"></div>" >> $html
  now_height=`expr $now_height + $icon_height`
done
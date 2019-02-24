
function get_html() {
  local html=$(curl -k -L -s $1)
  #echo $html
  echo "$html"
}

function get_score() {
  while true; 
    do 
      get_html $1 | grep -oP '(?<=<title>).*?(?=</title>)'
      sleep 1m; 
    done;
}

function list_live_matches() {
  local live_rss=http://static.cricinfo.com/rss/livescores.xml
  echo "Live rss"
  echo $live_rss
  local rss_content=$(get_html $live_rss)
#  echo $rss_content
  local rss_file_name="cricinfo_livescores.xml"

  echo "$rss_content" > $rss_file_name

  no_of_matches=$(xmllint --xpath 'count(/rss/channel/item)' $rss_file_name)

  echo "Live Cricket Matches"
  echo "--------------------"
  for ((i = 1; i <= no_of_matches; i++)); do
    title=$(xmllint --xpath '/rss/channel/item['$i']/title/text()' $rss_file_name)
    echo "$i: $title"
  done

  echo -n "Enter the match number : "
  read number
  if is_integer $number; then
    selected_title=$(xmllint --xpath '/rss/channel/item['$number']/title/text()' $rss_file_name 2>/dev/null)
    if [[ -z $selected_title ]]; then
      echo "Please give correct match number";
      rm -f $rss_file_name;
      exit 1      
    else
      echo "Selected Match is : $selected_title"
      match_link=$(xmllint --xpath '/rss/channel/item['$number']/link/text()' $rss_file_name)
      rm -f $rss_file_name
      get_score $match_link
    fi
  else
    echo "Please give number"
    rm -f $rss_file_name
    exit 1
  fi
  rm -f $rss_file_name
}

function is_integer() {
  printf "%d" $1 > /dev/null 2>&1
  return $?
}

function main() {
  
  if [[ -z $1 ]]; then
    list_live_matches
  else 
    get_score $1
  fi 

}

main $*

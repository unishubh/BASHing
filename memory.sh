MAX=$1
PART=$2
USE=`df -h |grep $PART | awk '{ print $5 }' | cut -d'%' -f1`
echo "Percent used: $USE"
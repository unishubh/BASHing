
#!/bin/bash
while getopts ":l-:" opt; do
  case $opt in
    l)
  		sleep 1;
  		xdg-screensaver lock
  		exit 1
      ;;
  	-)
		case "${OPTARG}" in
            lock)
				sleep 1;
		  		xdg-screensaver lock
		  		exit 1
            ;;
            *)
				echo "Invalid option: --$OPTARG" >&2
				exit 1
			;;
		esac;;
    \?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
      ;;
  esac
done
sleep 1; 
xset dpms force off
#!/bin/bash
#Программа вывода страницы с информацией о системе

TITLE="System Information Reort for $HOSTNAME"
CURRENT_TIME=$(date +"%x %r %Z")
TIME_STAMP="Generated $CURRENT_TIME, by $USER"
interactive=
filename=
usege () {
	echo "$PROGNAME: usage: $PROGNAME [-f file | -i]"
	return
}
report_uptime(){
	cat <<- _EOF_
		<h2>System Uptime</h2>
		<pre>$(uptime)</pre>
		_EOF_
	return
}
report_disk_space(){
	cat <<- _EOF_
		<h2> Disk Space Utilization</h2>
		<pre>$(df -h)
		_EOF_
	return
}
write_html_page () {
	cat <<- _EOF_
	<html>
		<head>
			<title>$TITLE</title>
		</head>
		<body>
			<h1>$TITLE</h1>	
			<p>$TIME_STAMP</p>
			$(report_uptime)
			$(report_disk_space)
			$(reprt_home_space)
		</body>
	</html>	
	_EOF_
	return
}
reprt_home_space(){

	local format="%8s%10s%10s\n"
	local i dir_list total_files total_dirs total_size user_name

	if [[ $(id -u) -eq 0 ]]; then
		dir_list=/home/*
		user_name="All Users"
	else
		dir_list="$HOME"
		user_name="$USER"
	fi

	echo "<h2>Home Space Utilization ($user_name)</h2>"

	for i in $dir_list; do

		total_files="$(find "$i" -type f | wc -l)"
		total_dirs="$(find "$i" -type d | wc -l)"
		total_seze="$(du -sh "$i" | cut -f 1)"
		echo "<h3>$i</h3>"
		echo "<pre>"
		printf "$format" "Dirs" "Files" "Size"
		printf "$format" "____" "_____" "____"
		printf "$format" "$total_dirs" "$total_files" "$total_size"
		echo "</pre>"
	done
	return
}

while [[ -n "$1" ]]; do
	case "$1" in 
		-f | --file) 		shift
					filename="$1"
					;;
		-i | --interactive)	interactive="$1"
					;;
		-h | --help)		usage
					exit
					;;
		*)			usage >&2
					exit 1
					;;
	esac
	shift
done	

if [[ -n "$interacrtive" ]]; then
	while true; do
		read -p "Enter name of output file: " filename
		if [[ -e "$filename" ]]; then
			read -p "'$filename' exist. Overwrite? [y/n/q] > "
			case "$REPLY" in
				Y|y)	break
					;;
				Q|q)	echo "Program terminated."
					exit
					;;
				*)	continue
					;;
			esac
		elif [[ -z "$filename" ]]; then
			continue
		else
			break
		fi
	done
fi

if [[ -n "$filename" ]]; then
	if touch "$filename" && [[ -f "$filename" ]]; then
		write_html_page > "$filename"
	else
		echo "$PROGNAME: Cannot write file '$filename'" >&2
		exit 1
	fi
else
	write_html_page
fi


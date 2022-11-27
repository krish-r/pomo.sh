#!/usr/bin/env bash

# Colors
c_cyan='\033[0;36m'
c_green='\033[0;32m'
c_red='\033[0;31m'
c_yellow='\033[0;33m'
c_bold_red='\033[1;31m'
c_bold_green='\033[1;32m'
# c_light_grey='\033[0;37m'
# c_dark_grey='\033[1;30m'
c_box_border='\033[1;36m'
c_clear='\033[0m'

# clear line
clear_line='\033[0K'

Help() {
	printf "%bpomo.sh%b\n" "$c_bold_green" "$c_clear"
	printf "A simple command-line pomodoro app.\n"
	printf "\n"
	printf "Usage: %bpomo.sh%b -[%bt%b mins|%bb%b mins|%bs%b no.|%bn%b 'note'|%be%b|%bh%b]\n" "$c_green" "$c_clear" "$c_yellow" "$c_clear" "$c_yellow" "$c_clear" "$c_yellow" "$c_clear" "$c_yellow" "$c_clear" "$c_yellow" "$c_clear" "$c_yellow" "$c_clear"
	printf "options:\n"
	printf "%bt%b  %bt%bimer (in mins).             (default: 15mins)\n" "$c_green" "$c_clear" "$c_green" "$c_clear"
	printf "%bb%b  %bb%break (in mins).             (default: 0mins)\n" "$c_green" "$c_clear" "$c_green" "$c_clear"
	printf "%bs%b  %bs%bessions (no.).              (default: 1)\n" "$c_green" "$c_clear" "$c_green" "$c_clear"
	printf "%bn%b  %bn%bote.                        (default: '')\n" "$c_green" "$c_clear" "$c_green" "$c_clear"
	printf "%be%b  %be%bnable desktop notification. (default: disabled)\n" "$c_green" "$c_clear" "$c_green" "$c_clear"
	printf "%bh%b  %bh%belp.\n" "$c_green" "$c_clear" "$c_green" "$c_clear"
	# printf "\n"
}

validate_opt() {
	re_isnum='^[0-9]+$' # Regex: match whole numbers only
	# args: $1 argument description, $2 value, $3 minimum value
	if ! [[ $2 =~ $re_isnum ]]; then
		printf "%bError%b: %b$1 must be a positive, whole number.%b\n" "$c_bold_red" "$c_clear" "$c_red" "$c_clear"
		exit 0
	elif [[ $2 -lt $3 ]]; then
		printf "%bError%b: %b$1 must be greater than zero%b.\n" "$c_bold_red" "$c_clear" "$c_red" "$c_clear"
		exit 0
	fi
}

# Defaults
completed_sessions=0
celebration=""
default_timer=15
default_break=0
default_sessions=1
notify=false

while getopts :t:b:s:n:he option; do
	case "${option}" in
	t)
		timer=${OPTARG}
		validate_opt "timer" "$timer" 1
		;;
	b)
		break=${OPTARG}
		validate_opt "break" "$break" 0
		;;
	s)
		sessions=${OPTARG}
		validate_opt "sessions" "$sessions" 1
		;;
	n) note=${OPTARG} ;;
	h)
		Help
		exit 0
		;;
	e)
		notify=true
		;;
	:)
		printf "%bError%b: %b-${OPTARG}%b %brequires an argument.%b\n" "$c_bold_red" "$c_clear" "$c_green" "$c_clear" "$c_red" "$c_clear"
		exit 0
		;;
	?)
		printf "%bError%b: %bInvalid option%b\n" "$c_bold_red" "$c_clear" "$c_red" "$c_clear"
		exit 0
		;;
	*) exit 0 ;;
	esac
done

# Set default values
timer="${timer:-$default_timer}"
break="${break:-$default_break}"
# if [[ $timer -le 1 ]]; then break=0; elif [[ $timer -le 5 ]]; then break=1; fi # set break value to 0 and 1 if -le 1 or 5 respectively
sessions="${sessions:-$default_sessions}"

# Convert to seconds
timer_in_seconds=$((timer * 60))
break_in_seconds=$((break * 60))

# Trap CTRL + C to gracefully exit
trap '{ printf "\r%b" "$clear_line"; printf "completed session(s): %b%s%b %s\n" "$c_green" "$completed_sessions" "$c_clear" "$celebration"; exit 0; }' SIGINT

# Add fillers to box drawings if note length goes beyond 20 characters
note_length=${#note}
filler=""
space_filler=""
if [[ $note_length -gt 20 ]]; then
	for ((i = 1; i <= note_length - 20; i++)); do
		filler=$filler"\u2500"
		space_filler=$space_filler" "
	done
fi

# TODO: make this DRY
# box drawings
top=$c_box_border"\u256D\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500$filler\u256E"$c_clear
title_bottom=$c_box_border"\u251C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u252C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u252C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u252C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500$filler\u2524"$c_clear
header_bottom=$c_box_border"\u251C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500$filler\u2524"$c_clear
data_bottom=$c_box_border"\u2570\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2534\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500$filler\u256F"$c_clear
pipe=$c_box_border"\u2502"$c_clear

title=$c_bold_green"pomo.sh"$c_clear
exit_cmd=$c_red"CTRL+C"$c_clear
timer_header=$c_cyan"timer"$c_clear
break_header=$c_cyan"break"$c_clear
sessions_header=$c_cyan"sessions"$c_clear
note_header=$c_cyan"note"$c_clear

timer_value=${c_cyan}"$timer"${c_clear}
break_value=$c_cyan"$break"$c_clear
sessions_value=$c_cyan"$sessions"$c_clear
note_value=$c_cyan"$note"$c_clear

# TODO: handle padding dynamically
# Print finalized values after substituting default values
printf "%b\n" "$top"
printf "%b %b (press %b to exit) %s%31b\n" "$pipe" "$title" "$exit_cmd" "$space_filler" "$pipe"
printf "%b\n" "$title_bottom"
printf "%b %-16b %b %-16b %b %-19b %b %-31b %s%b\n" "$pipe" "$timer_header" "$pipe" "$break_header" "$pipe" "$sessions_header" "$pipe" "$note_header" "$space_filler" "$pipe"
printf "%b\n" "$header_bottom"
printf "%b %-16b %b %-16b %b %-19b %b %-31b %b\n" "$pipe" "$timer_value" "$pipe" "$break_value" "$pipe" "$sessions_value" "$pipe" "$note_value" "$pipe"
printf "%b\n" "$data_bottom"

# TODO: make this DRY
## Progress bar unicodes
zero='\uEE00\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
ten='\uEE03\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
twenty='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
thirty='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
forty='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
fifty='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
sixty='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
seventy='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
eighty='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE01\uEE02'
ninety='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE01\uEE01\uEE01\uEE02'
hundred='\uEE03\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE04\uEE05'
progress_bar=("$zero" "$ten" "$twenty" "$thirty" "$forty" "$fifty" "$sixty" "$seventy" "$eighty" "$ninety" "$hundred")
percentages=("0%" "10%" "20%" "30%" "40%" "50%" "60%" "70%" "80%" "90%" "100%")
progress_length=$((${#progress_bar[@]} - 1))

# Calculate splits for progress bar
timer_split=$((timer_in_seconds / progress_length))
break_split=$((break_in_seconds / progress_length))

## NOTE: Uncomment to override splits while debugging
# timer_split=0.5
# break_split=0.5

sleep_time=0.25

if ! command -v notify-send &>/dev/null; then notify=false; fi

for ((s = 1; s <= sessions; s++)); do
	curr_time=$(date +"%I:%M %P")
	printf "\r%b" "$clear_line"
	printf "[session %b%02d%b 🍅] (%s)\n" "$c_green" "$s" "$c_clear" "$curr_time"

	printf "\r%b" "$clear_line"
	printf "Timer: %2d min(s) %b%b%b (%4s) " "$timer" "$c_green" "${progress_bar[0]}" "$c_clear" "${percentages[0]}" # display an empty progress bar at the start
	for ((i = 1; i <= progress_length; i++)); do
		sleep $timer_split
		printf "\r%b" "$clear_line"
		printf "Timer: %2d min(s) %b%b%b (%4s) " "$timer" "$c_green" "${progress_bar[$i]}" "$c_clear" "${percentages[$i]}"
	done

	sleep $sleep_time # sleep for additional $sleep_time to display 100%

	completed_sessions=$s # don't wait for the break to mark a session as completed
	celebration="🎉"

	if [[ $notify = true ]]; then notify-send "Pomodoro" "[session $s 🍅] timer ($timer min(s)) completed"; fi

	if ! [[ $break -eq 0 ]]; then
		printf "\r%b" "$clear_line"
		printf "Break: %2d min(s) %b%b%b (%4s) " "$break" "$c_yellow" "${progress_bar[0]}" "$c_clear" "${percentages[0]}" # display an empty progress bar at the start
		for ((i = 1; i <= progress_length; i++)); do
			sleep $break_split
			printf "\r%b" "$clear_line"
			printf "Break: %2d min(s) %b%b%b (%4s) " "$break" "$c_yellow" "${progress_bar[$i]}" "$c_clear" "${percentages[$i]}"
		done

		sleep $sleep_time # sleep for additional $sleep_time to display 100%

		if [[ $notify = true ]]; then notify-send "Pomodoro" "[session $s 🍅] break ($break min(s)) completed"; fi
	fi
done
printf "\r%b" "$clear_line"
printf "completed session(s): %b%s%b %s\n" "$c_green" "$completed_sessions" "$c_clear" "$celebration"

if [[ $notify = true ]]; then notify-send "Pomodoro" "completed session(s): $completed_sessions $celebration"; fi

#!/bin/zsh

# Test the problematic printf line in isolation
risk_color="\033[32m"
reset_color="\033[0m"
fg[cyan]="\033[36m"
i=1
command="test command"

printf "${fg[cyan]}  %s)${reset_color} ${risk_color}>${reset_color} ${fg[cyan]}%s${reset_color}\n" "$i" "$command"
#!/bin/bash
alias func='function' 
alias .='ls' ..='cd ../' ...='cd ../../' -='cd -'
alias rm='rm -i' mv='mv -i' cp='cp -i' mkdir='mkdir -pv'
alias ls='ls --color=auto' la='ls -A' lt='ls -lt' li='ls -li'
alias pf='ps -ef' px='ps -aux' psg='ps -ef | grep'
alias np='netstat -lntp' na='netstat -antp' est='netstat -an | grep ESTABLISHED'
alias day='date +%F' tomorrow='date -d "+1 day " +"%F %T"' yesterday='date -d "-1 day " +"%F %T"' nowtime='date +%Y-%m-%d\ %H:%M:%S'
alias mkcd='_f(){ mkdir -pv $1; cd $1; echo -e "now dir is: \033[37;34m$(pwd)\033[0m"; }; _f'
alias errlog='func _f() { echo -e "[$(date +%Y-%m-%d\ %H:%M:%S)]: \033[37;31m$@\033[0m" >&2; }; _f'
alias random='func _f(){ if [ -z "$1" ]; then echo $RANDOM; else num=$(echo "$1" | perl -ne '\''print if /^\d+$/'\'');[ -z "$num" ] && echo "syntax error" && return; eval echo $(perl -e '\''print "\$[ \$RANDOM % 10 ]"x'\''$num'\'''\''); fi }; _f'
alias bak='func _f(){ for i in $*; do cp -vr ${i%/} ${i%/}.`date +%Y%m%d.%H%M%S`.bak; done; }; _f'
alias restore='func _f(){ for i in $*; do r_f_name=${i%/}; [ -d "${r_f_name%.*.*.bak}" ] && echo -e "\033[37;31m\`${r_f_name%.*.*.bak}\`\033[0m is a directory, please del it before restore \033[37;31m\`${r_f_name}\`\033[0m" ||  mv -vf ${r_f_name} ${r_f_name%.*.*.bak}; done; }; _f'

alias k='kubectl' d='docker'

# ansible 自动补全
ansible_list=( $(perl -lne 'print $1 if /^\[(.*)\]/' /etc/ansible/hosts) all )
add_list=( -m )
module_list=( shell script )
end_list=( -a )
function _autotab() {
    local cur
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    if [ "${#COMP_WORDS[@]}" == "2" ]; then
        COMPREPLY=( $(compgen -W "${ansible_list[*]}" -- ${cur}) )
    elif [ "${#COMP_WORDS[@]}" == "3" ]; then
        COMPREPLY=( $(compgen -W "${add_list[*]}" -- ${cur}) )
    elif [ "${#COMP_WORDS[@]}" == "4" ]; then
        COMPREPLY=( $(compgen -W "${module_list[*]}" -- ${cur}) )
    elif [ "${#COMP_WORDS[@]}" == "5" ]; then
        COMPREPLY=( $(compgen -W "${end_list[*]}" -- ${cur}) )
    fi
}
complete -F _autotab ansible

export HISTSIZE=10000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "

PS1='\[\e[31;1m\]╭──( 🖳\[\e[37;10m\]| \[\e[34;10m\]\w\[\e[31;1m\] )$(__git_ps1 "──( ✥ \[\e[37;10m\]|\[\e [34;10m\] %s \[\e[31;1m\])")──$(kube_ps1)( \[\e[35;1m\]\d \t\[\e[31;1m\] )\n\[\e[31;1m\]╰──────○ \[\e[0;0m\]'
# PS1 效果: 
# ╭──( 🖳 | ~/note )──( ✥ | main )──( ⎈ | k8s-wsl:kube-ops )──( Sat Oct 23 23:44:02 )
# ╰──────○

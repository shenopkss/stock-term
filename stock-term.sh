#!/bin/bash
set -e

LANG=zh_CN.UTF-8

SYMBOLS=("$@")
COLOR_BOLD="\e[1;37m"
COLOR_GREEN="\e[32m"
COLOR_RED="\e[31m"
COLOR_RESET="\e[00m"

if [ "${#SYMBOLS[@]}" -eq 0 ]; then
    echo "Usage: ./stock-term.sh zs000977 "
    exit
fi

queryStock(){
    ret="`curl --silent http://hq.sinajs.cn/list=$1 | iconv -f gbk -t utf8`"
    stock_info=${ret#*\"}
    stock_info=${stock_info%\"*}
    IFS=","
    ret_arr=($stock_info)
    echo ${ret_arr[*]}
}

# printf "%-25s|" 'n'
# printf "%-10s|" 's'
# printf "%-10s|" 'c'
# printf "%-13s|" '%'
# printf "%-10s\n" 'diff'

display(){
    for symbol in ${SYMBOLS[@]}; do
        ret="`queryStock $symbol`"
    #    echo "----------->"
    #    echo $ret;
    #    echo "<-----------"
        ret_arr=($ret);

        stock_name=${ret_arr[0]}
        start_price=${ret_arr[2]}
        current_price=${ret_arr[3]}
        current_time=${ret_arr[31]}
        today_change=$(printf "%.3f" `echo "scale=3;${current_price} - ${start_price}"|bc`)
        today_change_rate=$( printf "%.2f" `echo "scale=4; ${today_change} / ${start_price} * 100" | bc` )

        if [ `echo "$today_change > 0" | bc` -eq 1 ]; then
            color=$COLOR_RED
        elif [ `echo "$today_change < 0" | bc` -eq 1 ]; then
            color=$COLOR_GREEN
        else
            color=''
        fi

        # printf "%-25s|" $stock_name"["$symbol"]"
        # printf "%-25s|" ${symbol:5}
        printf "%-7.2f|" $start_price
        # printf "$COLOR_BOLD%-7.2f$COLOR_RESET|" $current_price
        printf "%-7.2f|" $current_price
        printf "%-10s|" $(printf "%.2f" $today_change_rate)
        printf "%-7.2f\n" $today_change
    done;
}

#while true; do var=$(display);  sleep 1; done

display;

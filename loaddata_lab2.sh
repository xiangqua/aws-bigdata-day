#!/bin/bash
# write by Weiqiong Chen
# func: generate kds for big data day

# must provide right parameter to run this script
if [ $# != 2 ]; then
    echo "USAGE: $0 stream_name transaction_date"
    echo "Example: $0 userxx_stream 2020-11-18"
    exit 1
fi

# address: A1001 - A2084 , customer: U1001 - U2084 , product: P1001 - P1100
# get parameter
region_name="ap-southeast-1"
stream_name=$1
transaction_date=$2

# write log
function write_log() {
    echo "$(date +%FT%TZ) ## $0 ## $1" | tee -a ./logs-lab1-$(date +%F).log
}

# get random number between $1 and $2
function random_range() {
    echo $(($(($RANDOM % $(($1 - $2)))) + $1))
}

# generate next transaction id
function next_tid() {
    echo $(($1 + 1))
}

# generate next transaction no
function next_tno() {
    echo A$(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' </dev/urandom | head -c 3)$(date +%Y%m%d%H%M%S)
}

# define transaction start id
beg_tid="1"

# run forever
while true; do
    # random tranasaction this time
    write_log "----------"
    t_thistime=$(random_range 1 3)
    write_log "#### Generate ${t_thistime} Transactions this time."
    i=1
    while [[ $i -le ${t_thistime} ]]; do
        get_tid=A$(next_tid ${beg_tid})
        get_tno=$(next_tno)
        get_uno=U$(random_range 1001 2084)
        get_pno=P$(random_range 1001 1100)
        get_tnum=$(random_range 1 10)
        get_tuptime=$(date +%FT%TZ)
        data="{\"tid\":\"${get_tid}\",\"tno\":\"${get_tno}\",\"tdate\":\"${transaction_date}\",\"uno\":\"${get_uno}\",\"pno\":\"${get_pno}\",\"tnum\":${get_tnum},\"tuptime\":\"${get_tuptime}\"}"
        write_log "data: $data"
        aws kinesis put-record --stream-name ${stream_name} --data $data --partition-key ${get_tno} --region ${region_name} | tee -a ./logs-lab1-$(date +%F).log 2>&1
        beg_tid=${beg_tid}+1
        i=$i+1
    done
    # random slepp
    slp=$(random_range 1 3)
    write_log "#### Sleep $slp seconds for next time start."
    sleep $slp
done

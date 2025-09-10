get_cpu_usage(){
echo "CPU usage:"
mpstat|awk '$13~/[0-9.]+/{print 100-$13 "% used"}'
}

get_memory_usage(){
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
}

get_disk_usage(){
echo "Disk usage:"
df -h --total|awk '$0 ~ /total/ {print  "Used:"$3", Free: "$4", Total: $2"}'
}

get_top_mem_usage(){
echo "Top 5 Processes by memory usage"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
}

get_top_cpu_usage(){
echo "Top 5 Processes by cpu usage"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
}

get_extra_stats(){
echo "Uptime:"
uptime

echo "Load Avg:"
cat /proc/loadavg

echo "Logged in users:"
who
}

main(){
echo "Server Performance stats"
echo "---------------------------------------------"
get_cpu_usage
get_memory_usage
get_disk_usage
get_top_mem_usage
get_top_cpu_usage
get_extra_stats
}

main

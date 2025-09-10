# Linux Monitoring with `awk`, `mpstat`, `free`, and `ps`

A concise, practical README covering:

* Quick AWK refresher (fields, patterns, `print` vs `printf`)
* One-liners for CPU, memory, and process monitoring
* A ready‑to‑run `server-stats.sh` script
* Tips for copying files to EC2
* Common pitfalls & troubleshooting

---

## 🚀 Quick Start

```bash
# Make the script executable and run it
chmod +x server-stats.sh
./server-stats.sh
# or
bash server-stats.sh
```

**Requirements**

* Linux with Bash
* `sysstat` package for `mpstat` (Ubuntu/Debian: `sudo apt install sysstat`)

---

## 📚 AWK Refresher

**Awk model:** `awk 'pattern { action }' file`

* **Fields:** `$1, $2, …, $NF` (whole line = `$0`)
* **Built‑ins:** `NR` (line number), `NF` (#fields), `FS` (input sep), `OFS` (output sep)
* **Match:** column → `$N ~ /regex/`, whole row → `$0 ~ /regex/`
* **`print` vs `printf`:**

  * `print a, b` → quick, auto space + newline
  * `printf "x=%.2f\n", x` → formatted, **no auto newline**

**Useful snippets**

```bash
awk 'NR>1' file                  # skip header
awk '$13 > 90' file              # numeric filter on a column
awk '$0 ~ /pattern/' file        # regex on a whole row
awk '{ printf "x=%.2f\n", $3/$2*100 }'  # formatted percentage
awk '{ print $NF }'              # last field
```

---

## 🧠 Monitoring One‑Liners

### CPU used with `mpstat`

In `mpstat` output that includes time (e.g., `11:11:42 PM`), `%idle` is typically **column 13**. CPU used = `100 - %idle`.

```bash
mpstat | awk '$13 ~ /[0-9.]+/ { print 100 - $13 "% used" }'
```

> The header line is skipped because `%idle` (text) doesn’t match the numeric regex.

### Memory usage with `free -m`

* `Mem:` line columns: `$2=total`, `$3=used`, `$7=available`
* **Used MB** ≈ `$2 - $7` (practical used) or simply `$3`
* **Used %** = `$3/$2 * 100`

```bash
free -m | awk 'NR==2 { printf "Memory: %s/%sMB (%.2f%%)\n", $3, $2, $3*100/$2 }'
```

> Values change across runs because memory is dynamic (kernel caches, processes, etc.).

### Top processes by memory / CPU

```bash
# Top 5 by memory
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

# Top 5 by CPU
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
```

> First line is the header; the next 5 are the top consumers.

### Row vs Column conditions (awk)

```bash
# Column filter: idle > 90
awk '$13 > 90' dummy_mpstat.txt

# Row filter: select lines containing the word "all"
awk '$0 ~ /all/' dummy_mpstat.txt

# Combine row + column filters
awk '$0 ~ /all/ && $13 > 90' dummy_mpstat.txt
```

---

## 🧩 Script: `server-stats.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

get_cpu_usage() {
  echo "CPU usage:"
  mpstat | awk '$13 ~ /[0-9.]+/ { print 100 - $13 "% used" }'
}

get_memory_usage() {
  echo "Memory usage:"
  free -m | awk 'NR==2 { printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3, $2, $3*100/$2 }'
}

get_disk_usage() {
  echo "Disk usage:"
  df -h --total | awk '$1 == "total" { print "Used: " $3 ", Free: " $4 ", Total: " $2 }'
}

get_top_mem_usage() {
  echo "Top 5 Processes by memory usage"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
}

get_top_cpu_usage() {
  echo "Top 5 Processes by cpu usage"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
}

get_extra_stats() {
  echo "Uptime:"
  uptime

  echo "Load Avg:"
  cat /proc/loadavg

  echo "Logged in users:"
  who
}

main() {
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
```

**Install `mpstat` if missing**

```bash
sudo apt update && sudo apt install -y sysstat
```

---

## ☁️ Copying files to EC2

### SCP (publicly reachable EC2)

```bash
# file -> EC2
scp -i /path/to/key.pem ./local.file ubuntu@ec2-xx-xx-xx-xx.compute.amazonaws.com:/home/ubuntu/

# directory -> EC2
scp -i /path/to/key.pem -r ./localdir ubuntu@ec2-xx:/home/ubuntu/

# EC2 -> local
scp -i /path/to/key.pem ubuntu@ec2-xx:/home/ubuntu/remote.file ./
```

> Usernames vary: `ubuntu` (Ubuntu), `ec2-user` (Amazon Linux/RHEL), `centos` (CentOS), `admin`/`debian` (Debian).

### rsync (sync only deltas)

```bash
rsync -avz -e "ssh -i /path/to/key.pem" ./localdir ubuntu@ec2-xx:/home/ubuntu/localdir
```

### SSM (no SSH ingress / private subnets)

```bash
scp -o "ProxyCommand=aws ssm start-session --target i-0123456789abcdef0 \
 --document-name AWS-StartSSHSession --parameters 'portNumber=22'" \
 -i /path/to/key.pem ./local.file ubuntu@i-0123456789abcdef0:/home/ubuntu/
```

### S3 as a relay

```bash
aws s3 cp ./local.file s3://your-bucket/path/local.file
# on EC2
aws s3 cp s3://your-bucket/path/local.file /home/ubuntu/
```

---

## 🧰 Troubleshooting & Pitfalls

* **Smart quotes** in awk (e.g., `“ ”`, `‘ ’`) → use plain quotes `'` and `"` only.
* **`mpstat` column index**: with timestamps, `%idle` is `$13`; without, it may shift. Adjust accordingly.
* **Runaway string constant**: usually a missing closing quote in `awk`.
* **Awk concatenation**: `print x " MB"` (no `+`).
* **Defined functions never run**: remember to call `main` at the end of your script.
* **Permission denied** when copying to system paths: upload to home dir, then `sudo mv` into place.

---
project URl: https://roadmap.sh/projects/server-stats

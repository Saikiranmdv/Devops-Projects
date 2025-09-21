# 📘 Revision Notes

## Topics Covered
1. String Operators  
2. Integer Operators  
3. File Test Operators  
4. Logical Operators  
5. Conditional Examples  
6. Exit Status `$?`  
7. `tar` Basics & Options  

---

## 1. String Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| -z string | True if string is empty | `[ -z "$str" ]` |
| -n string | True if string is not empty | `[ -n "$str" ]` |
| string1 = string2 | True if strings are equal | `[ "$a" = "$b" ]` |
| string1 == string2 | Same as = (preferred inside `[[ ]]`) | `[[ "$a" == "$b" ]]` |
| string1 != string2 | True if not equal | `[ "$a" != "$b" ]` |
| string1 < string2 | Lexicographically smaller | `[[ "apple" < "banana" ]]` |
| string1 > string2 | Lexicographically greater | `[[ "zebra" > "lion" ]]` |

⚠️ `<` and `>` must be used inside `[[ ]]`.

---

## 2. Integer Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| -eq | Equal to | `[ $a -eq $b ]` |
| -ne | Not equal | `[ $a -ne $b ]` |
| -gt | Greater than | `[ $a -gt $b ]` |
| -lt | Less than | `[ $a -lt $b ]` |
| -ge | Greater or equal | `[ $a -ge $b ]` |
| -le | Less or equal | `[ $a -le $b ]` |

⚡ Arithmetic evaluation:
```bash
if (( a > b )); then
   echo "a is bigger"
fi

---

## 3. File Test Operators

| Operator        | Meaning             | Example                       |
| --------------- | ------------------- | ----------------------------- |
| -e file         | File exists         | `[ -e myfile.txt ]`           |
| -f file         | Regular file exists | `[ -f myfile.txt ]`           |
| -d file         | Directory exists    | `[ -d mydir ]`                |
| -s file         | File is not empty   | `[ -s myfile.txt ]`           |
| -r file         | Readable            | `[ -r myfile.txt ]`           |
| -w file         | Writable            | `[ -w myfile.txt ]`           |
| -x file         | Executable          | `[ -x myscript.sh ]`          |
| -L file         | Symbolic link       | `[ -L mylink ]`               |
| -b file         | Block device        | `[ -b /dev/sda ]`             |
| -c file         | Character device    | `[ -c /dev/tty ]`             |
| -p file         | Named pipe          | `[ -p /tmp/mypipe ]`          |
| -S file         | Socket              | `[ -S /var/run/docker.sock ]` |
| file1 -nt file2 | Newer than          | `[ file1 -nt file2 ]`         |
| file1 -ot file2 | Older than          | `[ file1 -ot file2 ]`         |
| file1 -ef file2 | Same inode          | `[ file1 -ef file2 ]`         |

---

## 4. Logical Operators

| Operator       | Meaning | Example                  |
| -------------- | ------- | ------------------------ |
| ! expr         | NOT     | `[ ! -f file ]`          |
| expr1 -a expr2 | AND     | `[ -f file -a -r file ]` |
| expr1 -o expr2 | OR      | `[ -d dir -o -f file ]`  |

⚡ In `[[ ]]` use `&&` and `||`:

```bash
if [[ -f file && -r file ]]; then
   echo "File exists and is readable"
fi
```

---

## 5. Conditional Examples

* **Empty Directory**

```bash
dir="testdir"
if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
    echo "Directory is empty"
else
    echo "Directory is not empty"
fi
```

* **Number in Range**

```bash
num=15
if [ $num -gt 10 ] && [ $num -lt 20 ]; then
    echo "Number is between 10 and 20"
fi
```

* **File Newer Than Another**

```bash
if [ file1.txt -nt file2.txt ]; then
    echo "file1 is newer"
fi
```

✅ Tips:

* `[ ]` for POSIX.
* `[[ ]]` for Bash/Zsh extras.
* `(( ))` for arithmetic.

---

## 6. Exit Status `$?`

```bash
if [ $? -eq 0 ]; then
   echo "Last command succeeded"
fi
```

* `$?` = exit code of last command.
* `0` = success, non-zero = failure.

---

## 7. `tar` Basics & Options

### Core

| Option | Meaning                   | Example                      |
| ------ | ------------------------- | ---------------------------- |
| c      | Create archive            | `tar -cf archive.tar files/` |
| x      | Extract archive           | `tar -xf archive.tar`        |
| t      | List contents             | `tar -tf archive.tar`        |
| f      | File name (last in flags) | `tar -cf backup.tar file1`   |

### Compression

| Option | Meaning              | Example                                   |
| ------ | -------------------- | ----------------------------------------- |
| z      | gzip (.tar.gz)       | `tar -czf archive.tar.gz folder/`         |
| j      | bzip2 (.tar.bz2)     | `tar -cjf archive.tar.bz2 folder/`        |
| J      | xz (.tar.xz)         | `tar -cJf archive.tar.xz folder/`         |
| --zstd | Zstandard (.tar.zst) | `tar --zstd -cf archive.tar.zst folder/`  |
| --lzma | lzma (.tar.lzma)     | `tar --lzma -cf archive.tar.lzma folder/` |

### Control

* `v` → verbose
* `-C dir` → change dir
* `--exclude=PATTERN` → exclude files
* `--wildcards` → wildcards in patterns
* `--remove-files` → delete after adding
* `-r` → append files (uncompressed)
* `-u` → update newer files

### Extraction

* `tar -xvf archive.tar` → extract verbose
* `tar -xf archive.tar -C /tmp/extracted` → extract to dir
* `tar -xzf archive.tar.gz --strip-components=1` → drop leading paths

### Common Combos

* Create gzipped: `tar -czvf archive.tar.gz folder/`
* Extract gzipped: `tar -xzvf archive.tar.gz`
* List: `tar -tvf archive.tar`

### Pro Tips

* Order matters → `f` must come last in flag group.
* Use pipelines:

  ```bash
  tar -czf - folder/ | ssh user@host "cat > backup.tar.gz"
  ```
* `-a` auto-detects compression by extension:

  ```bash
  tar -caf archive.tar.gz folder/
  ```

✅ Summary:

* Core: `c`, `x`, `t`, `f`, `v`
* Compression: `z`, `j`, `J`, `--zstd`
* Helpers: `-C`, `--exclude`, `--strip-components`

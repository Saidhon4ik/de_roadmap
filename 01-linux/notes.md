# Linux Cheat Sheet — Stage 1 (Final)

## Navigation
```bash
pwd                 # where am I right now (absolute path)
ls                   # list files
ls -la               # + hidden files + permissions/owner/size
cd path              # move into a folder
cd ..                # go up one level
cd ~                 # go home
cd -                 # go back to the previous directory
```

## Paths
```
/home/user/project   # absolute — starts from root /, works from anywhere
./project            # relative — relative to current folder (pwd)
../project           # relative — one level up from current position
../../project        # two levels up
```
A relative path's meaning always depends on where you currently are (`pwd`). An absolute path never changes, regardless of your current location.

## Files and folders
```bash
mkdir name           # create a folder
mkdir -p a/b/c        # create nested folders at once, no error if they already exist
touch file.txt        # create an empty file (or update the timestamp of an existing one)
rm file.txt            # delete a file
rm -r folder/           # delete a folder recursively
rm -rf folder/           # recursive + no confirmation (CAREFUL, no trash bin, no undo)
cp src dst                # copy a file
cp -r src_dir dst_dir       # copy a folder recursively
mv src dst                  # move / rename
```

## Reading files
```bash
cat file.txt           # entire file printed to stdout
less file.txt           # paginated view, arrow keys to navigate, q — quit, / — search inside
head file.txt             # first 10 lines by default
head -n 20 file.txt        # first 20 lines
tail file.txt               # last 10 lines by default
tail -n 50 file.txt           # last 50 lines
tail -f file.txt               # live tail — updates in real time (production logs)
```

## Permissions (chmod) — numeric logic

Permissions = 3 groups (owner / group / others), each = 3 bits (read/write/execute).

| Bit | Meaning | Number |
|-----|---------|--------|
| r (read) | can read | 4 |
| w (write) | can modify | 2 |
| x (execute) | can run (file) / enter (folder) | 1 |

The number for a group = sum of its bits. Examples:
```
7 = rwx  (4+2+1 — everything)
6 = rw-  (4+2 — read+write, no execute)
5 = r-x  (4+1 — read+enter, no write)
4 = r--  (4 — read only)
0 = ---  (nothing)
```

The full command = three digits in a row: owner / group / others.

```bash
chmod 644 file.txt     # rw-r--r--  owner rw, others read-only — standard for FILES
chmod 755 folder/        # rwxr-xr-x  owner full access, others read+enter — standard for FOLDERS
chmod 600 secret.json      # rw-------  owner only — for credentials/keys/tokens
chmod 700 private_folder/    # rwx------  owner only can see and enter
chmod +x script.sh             # add execute permission (alternative syntax, no numbers)
```

**Important:** for folders, `x` = permission to enter (`cd`), NOT "run a program". Without `x` you can't enter even as the owner, even if you have `r` (you'll see the file list via `ls`, but can't go inside).

## Processes
```bash
ps aux                  # all processes from all users (without aux — only yours in the current session)
ps aux | grep python      # filter processes by name
kill <PID>                  # terminate a process by ID (gracefully, SIGTERM)
kill -9 <PID>                 # force kill (SIGKILL, if it doesn't respond to a regular kill)
htop                            # live interactive CPU/RAM monitor by process (q — quit)
```

## Disk
```bash
df -h                  # free/used disk space (by partition), -h = human-readable (GB/MB)
du -sh folder/            # how much a specific folder weighs (-s = summary, -h = human-readable)
du -sh */ | sort -h         # size of every folder in the current directory, sorted ascending
```

## Pipes and redirects
```bash
command > file.txt       # write output to a file (OVERWRITES existing content)
command >> file.txt        # append to the end of a file (doesn't overwrite)
cmd1 | cmd2                  # cmd1's output becomes cmd2's input

# Examples:
find . -name "*.md" | wc -l            # find .md files → count how many
ps aux | grep python                      # all processes → filter to just python
tail -n 50 error.log | grep ERROR           # last 50 log lines → find lines with ERROR
```

## Search — find and grep

```bash
find . -name "*.md"              # find files with .md extension, starting from current folder (.)
find / -name "config.json"          # search from the system root (slower, wider scope)
find . -type f -name "*.py"           # -type f = files only (not folders)
find . -type d -name "logs"             # -type d = folders only
find . -mtime -1                          # files modified in the last 1 day
find . -size +100M                          # files bigger than 100MB

grep "error" file.txt                # find lines containing "error" in a file
grep -i "error" file.txt               # -i = case-insensitive (Error, ERROR, error — all match)
grep -r "TODO" .                         # -r = recursive search across all files in a folder
grep -n "error" file.txt                   # -n = show the line number where it matched
```

## Common mistakes (from hands-on practice)
- `cd` into a folder that doesn't exist yet → `mkdir` first, then `cd`
- `chmod 644` on a folder → can't enter it, even as the owner (you need `x` → use `755`)
- `rm -rf` without checking `pwd` first → can delete the wrong thing, no way back
- credential files (`*.json` keys, tokens) with open permissions (`644` or weaker) → always `chmod 600`
- mixing up `du` (folder weight), `df` (disk space), and `htop` (process CPU/RAM) — three different tools for three different questions

---

## ❓ Comprehension Check (with answers)

**1. What's the difference between an absolute and a relative path?**
Absolute starts from root `/` and works the same no matter where you are. Relative is counted from your current position (`pwd`), so its meaning changes depending on where you currently stand.

**2. Why do we need the pipe `|`?**
It passes one command's output as the next command's input, without intermediate files. Example: `find . -name "*.md" | wc -l` — find files and immediately count them.

**3. How do you check the last 50 lines of a huge log without opening the whole file?**
`tail -n 50 file.log` — reads only the end of the file, doesn't load the whole thing into memory.

---

## 🎤 Mini Interview Q&A

**Easy: "How do you check which processes are running?"**
`ps aux` — shows all processes from all users with PID, CPU%, MEM%. For live monitoring — `htop`.

**Medium: "What does `chmod 755` do?"**
Sets permissions: owner — rwx (full access), group and others — r-x (read + enter, no write). Standard scheme for folders and executable scripts.

**Hard: "A server isn't responding, the disk is full — how do you find what's eating the space?"**
First `df -h` — confirm which partition is full. Then `du -sh */ | sort -h` inside the suspect directory (e.g. `/var/log` or `/home`) — a size-sorted list of folders, showing the culprit immediately. `htop` won't help here — that's for CPU/RAM, not disk.
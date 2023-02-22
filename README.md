# v2rayUsrMgr
A command line Bash script tool for managing v2ray users in Linux servers

# Installation

copy usrmgr.sh and a client.json template to server.

```bash
$ chmod 777 usrmgr.sh
```

install jq package:
```bash
$ apt update
$ apt install jq
```

run the Bash Script
```bash
$ ./usrmgr.sh
```
## Commands
### add new user:
```bash
$ ./usrmgr.sh add user1
```
### delete user:
```bash
$ ./usrmgr.sh del user1
```
### view user configuration:
```bash
$ ./usrmgr.sh cfg user1
```
### list users:
```bash
$ ./usrmgr.sh ls
```
### users status:
```bash
$ ./usrmgr.sh stat
```

#!/bin/bash

# v0.1(Feb 2022)
# this script is created by 3uffer
# licensed under the GNU General Public License v3.0

cfg=/usr/local/etc/v2ray/config.json
client=./client.json
tmp=./config.tmp

red="\e[31m"
cyn="\e[36m"
ylw="\e[33m"
blu="\e[34m"
rst="\e[0m"

dpkg -s jq &> /dev/null
if [ "$?" -ne 0 ]; then
  echo -e ${red}error:${rst} jq is not installed
  echo -e ${blu}"run this command to install:${rst}
	apt install jq"
  exit 1
fi

if [ "$1" = "" ]; then
  echo -e ${red}error:${rst} no command
  echo -e "commands:
	add <username>
	  ${ylw}adds a new client to config file:
	  (after adding new clients, you should run restart command)${rst}
	  ${blu}usage:${rst} ./usrmgr.sh add client_1
	del <username>
	  ${ylw}deletes a client from config file:
	  (after deleting clients, you should run restart command)${rst}
	  ${blu}usage:${rst} ./usrmgr.sh del client_1
	cfg <username>
	  ${ylw}view an existing client config string:${rst}
	  ${blu}usage:${rst} ./usrmgr.sh cfg client_1
	ls
	  ${ylw}list current clients:${rst}
	  ${blu}usage:${rst} ./usrmgr.sh ls
	stat
	  ${ylw}view download/upload statistics:${rst}
	  ${blu}usage:${rst} ./usrmgr.sh stat
	restart
	  ${ylw}shortcut to 'systemctl restart v2ray.service':${rst}
	  ${blu}usage:${rst} ./usrmgr.sh restart
  "
  exit 1
fi
clntcfg(){
  local c1=$(jq '.outbounds[0].settings.vnext[0].users += [{"'$2'":"'$1'"}]' $client)
  c1=$(tr '\n' ' ' <<< $c1)
  c1=$(sed 's/\s*"/"/g; s/:\s*/:/g; s/\s*{/{/g; s/\s*}/}/g; s/\s*\[/\[/g; s/\s*\]/\]/g' <<< $c1)
  echo -e ${ylw}json config string for \"$2\":${rst}
  echo $c1
}
case $1 in
  add)
    if [ "$2" = "" ]; then
      echo -e ${red}error:${rst} username is required
      echo -e ${ylw}"usage:${rst}
	add <username>"
      exit 1
    fi
    cat $cfg | jq -e '. | any(.inbounds[0].settings.clients[];.email == "'$2'")' &> /dev/null
    if [ "$?" = 0 ]; then
      echo -e ${red}error:${rst} username \'${cyn}$2${rst}\' exists
      exit 1
    else
      echo -e ${ylw}adding new user${rst}
      uuid=$(sh -c "v2ray uuid")
      idserver='{"id": "'$uuid'", "email": "'$2'", "level": 0}'
      srvc=$(cat $cfg)
      cat $cfg | jq '.inbounds[0].settings.clients += [{"id":"'$uuid'",email:"'$2'","level":0}]' > $tmp
      /bin/cp $tmp $cfg; /bin/rm $tmp
      echo -e ${cyn}new user added successfully${rst}
      clntcfg $uuid $2
      exit 0
    fi
    ;;
  del)
    if [ "$2" = "" ]; then
      echo -e ${red}error:${rst} username is required
      echo -e ${ylw}"usage:${rst}
	del <username>"
      exit 1
    fi
    cat $cfg | jq -e '. | any(.inbounds[0].settings.clients[];.email == "'$2'")' &> /dev/null
    if [[ "$?" != 0 ]]; then
      echo -e ${red}error:${rst} username \"${blu}$2${rst}\" not found
      exit 1
    else
      read -p "are you sure to delete user \"$2\" [y/n]: " yn
      case $yn in
        [Yy]*)
          cat $cfg | jq '. | del(.inbounds[].settings.clients[]? | select(.email == "'$2'"))' > $tmp
          /bin/cp $tmp $cfg; /bin/rm $tmp
          echo -e ${cyn}user $2 has been deleted successfully${rst}
          exit 0
          ;;
        [Nn]*)
          echo -e ${ylw}delete aborted${rst}
          exit 1
          ;;
      esac
    fi
    ;;
  cfg)
    if [ "$2" = "" ]; then
      echo -e ${red}error:${rst} select a username
      echo -e ${ylw}"usage:${rst}
	cfg <username>"
      exit 1
    fi
    _id=$(cat $cfg | jq -e -r '. | .inbounds[].settings.clients[]? | select(.email=="'$2'") | .id')
    if [[ "$?" != 0 ]]; then
      echo -e ${red}error:${rst} user \"${blu}$2${rst}\" not found
      exit 1
    else
      clntcfg $_id $2
    fi
    exit 0
    ;;
  ls)
    ret=$(cat $cfg | jq -r '. | [.inbounds[].settings.clients[]?.email] | join(", ")')
    echo $ret
    exit 0
    ;;
  stat)
    v2ray api stats --server=127.0.0.1:10085
    exit 0
    ;;
  restart)
    systemctl restart v2ray.service
    exit 0
    ;;
  *)
    echo -e ${red}error:${rst} bad command
    exit 1
    ;;
esac

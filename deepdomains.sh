#!/bin/bash
################INFO#################
# Title: DeepDomains 
# Author: Bruno Sergio @brunosgio
################USAGE################
# Eg.: ./deepdomains.sh google.com

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
purple=`tput setaf 5`
reset=`tput sgr0`

tput civis

function ctrl_c(){
  echo -e "${red}\n[!] Ctrl + C pressed. Script ended...${reset}\n"
  tput cnorm; exit 1
}
trap ctrl_c INT

function banner(){
echo "${purple}
 __  ___ ___           _        _  ___       __  
 ) ) )_  )_   _   _ ) / ) )\/) /_)  )  )\ ) (_ \` 
/_/ (__ (__  )_) (_( (_/ (  ( / / _(_ (  ( .__)  
            (                                    
${reset}"
echo -e "${yellow}\t\t\t  Created by @brunosgio${reset}\n\n"
}

function modules(){
  echo $domain >> $tmp
  i=1

  while [ -s $tmp ];
  do
    echo "${purple}[~] Deeping in subdomains for the $i time.${reset}"
    sleep 2
    discover
    sed -i '/^$/d' $tmp2

    if [ -s $tmp2 ]; then
      echo -e "${purple}[~] $(wc -l $tmp2 | awk '{print $1}') new subdomains were found in this $i attempt,\nlet's try to find new subdomains for them!${reset}\n"
    else
      echo "${purple}[~] No more subdomains to be found.${reset}"
    fi

    cat $tmp2 | sort -u > $tmp
    echo "" > $tmp2
    i=$((i + 1))
  done

  rm -rf $tmp $tmp2
  echo
}

function discover(){
  echo "${green}[+] Using AssetFinder to find subdomains...${reset}"
  xargs -a $tmp -I@ -P5 sh -c 'assetfinder -subs-only @' 2>/dev/null | anew $subdomains >> $tmp2

  echo "${green}[+] Using Findomain to find subdomains...${reset}"
  xargs -a $tmp -I@ -P5 sh -c 'findomain -t @ -q' 2>/dev/null | anew $subdomains >> $tmp2

  echo "${green}[+] Using SubFinder to find subdomains...${reset}"
  xargs -a $tmp -I@ -P5 sh -c 'subfinder -d @ -silent' 2>/dev/null | anew $subdomains >> $tmp2
}

main(){
  if [ -f "./deep-$domain.txt" ]; then
    echo -e "${red}[!] Apparently you've already searched subdomains on this target.${reset}"
    echo -e "${red}[!] File '$(pwd)/deep-$domain.txt' exists.\n"
    tput cnorm; exit 1
  else
    touch ./deep-$domain.txt
    touch ./deep-tmp.txt
    touch ./deep-tmp2.txt
  fi

  subdomains="./deep-$domain.txt"
  tmp="./deep-tmp.txt"
  tmp2="./deep-tmp2.txt"

  modules

  echo "[~] The process was done. A total of ${yellow}$(wc -l $subdomains | awk '{print $1}')${reset} subdomains were found."
  echo "[~] You can access the results at: ${yellow}$subdomains${reset}"
  tput cnorm
  exit 0
}

banner
domain=$1
if [ $# -lt 1 ]; then
  echo -e "${red}[!] You need to enter a target domain.${reset}"
  echo "Usage: ./deepdomains.sh <domain>"
  tput cnorm; exit 1
else
  if [ $# -ge 2 ]; then
    echo -e "${red}[!] You supplied more than 2 arguments.${reset}"
    echo "Usage: ./deepdomains.sh <domain>"
    tput cnorm; exit 1
  fi
fi
main $domain

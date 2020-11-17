---
title: "HTB: Archetype"
description: "Documentation of the first HackTheBox room"
category: 'Hack The Box'
date: 2020-11-06
image:
 path: /images/htbsp/archetype/head.png
 caption: "That's a really good thumbnail"
---


So, after some time experimenting with [TryHackMe]() I decided to check [HackTheBox]() so that I could *hopefully* base my learning path on both of them and utilize their resources to the max. Here, I describe the steps I took to complete the first HackTheBox room, while providing some extra insight for those that would like to learn some more about what they're typing.

<!-- vim-markdown-toc GFM --some extra

* [Before you begin](#before-you-begin)
* [Active recon](#active-recon)
	* [Processes](#processes)
		* [Impacket](#impacket)
	* [What comes next?](#what-comes-next)
* [We are in - the last step](#we-are-in---the-last-step)
* [Summing up - a short review](#summing-up---a-short-review)

<!-- vim-markdown-toc -->

Let's start!

## Before you begin
Don't be afraid to search for the stuff you do not know. Everybody's gotta learn.

## Active recon

The room starts simple: you are given the command to scan all the ports of the machine you want to exploit and then proceed by completing a full script and version nmap scan on the open ports. 
```bash
 ports=$(nmap -p- --min-rate=1000 -T4 10.10.10.27 | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
 nmap -sC -sV -p$ports 10.10.10.27
```
The first command may look a bit frightening but after a quick look anyone with some basic linux experience can understand it. We're setting a variable called **ports**, and lo and behold: we want it to store the numbers of all the open ports out there in a format that can be used in the second command, so that we do not waste time performing script and version scans on closed ports. That is achieved by modifying the output of the nmap command. In greater detail:
 - with `grep` we choose the lines of output that contain the port numbers
 - with `cut` we select only the first field of that line (the port number)
 - with `tr` we turn the newline characters (\n) into commas so that they can be parsed into nmap and finally
 - with `sed` the interesting editor we delete the last comma

The content of the `$ports` variable is then translated by the second command into a list of active processes (*and thus, possible vulnerabilities*) running at 10.10.10.27.

### Processes

Even though there seems to be many open ports and possible ways to proceed, at least to those without much experience (*like me*), the room has a **walkthrough** character and so we're told to focus on ports 445 and 1433, that are associated with file sharing and SQL server.

We use the `smbclient` command to view the contents of the server - hoping that there is anonymous access enabled on some of the connected shares. It is.

![ohMyGod](https://live.staticflickr.com/65535/33855263628_556abaa36e_b.jpg)
<small>"OMG - Oh My God!" by Neil. Moralee is licensed with [CC BY-NC-ND 2.0](https://creativecommons.org/licenses/by-nc-nd/2.0/)</small>

We then access the backup share and upload the only file we can access from there to our own computer for further inspection. The file named `dtsConfig` has a simple format and a quick look reveals that there is a user `ARCHETYPE\sql_svc` whose password is `M3g4c0rp123`. 

Here we're about to use [Impacket's](https://github.com/SecureAuthCorp/impacket) mssqclient.py script to connect to the SQL server. However, you may encounter a problem: not having the script available.

#### Impacket
Disclaimer! This *chapter* is only to be used as reference by those who faced that problem and offers no actual information on the room

First things first, let's approach the problem methodically. Using the `locate` command we get to know whether the script exists on our distro (*I checked on both ParrotOS and Kali Linux and while the script can be found it is not usable without further configuration*). We could proceed by trying to solve the local problem right there, however, it seems better to simply download the github repo (found above) and proceed with its complete installation:

```bash
git clone https://github.com/SecureAuthCorp/impacket/tree/impacket_0_9_21
cd impacket
pip3 install .
# pip install . for python 2.x
```

That, however, should be avoided, just like the developers suggest in `README.md`. Instead we are going to download the latest release (0.9.21 at the time of writing) and then, follow the exactly same steps:

```bash
wget https://github.com/SecureAuthCorp/impacket/releases/download/impacket_0_9_21/impacket-0.9.21.tar.gz
tar -xf impacket-0.9.21.tar.gz
cd impacet-0.9.21
pip3 install .
```

After that we can freely use the command as specified in the writeup.

### What comes next?

By using `mssqlclient.py` we gain acess as the sql_svc user and following the instructions given we gain access to a cmd shell (*feel free to try the ?*). Someone with a better understanding of the windows command line interface may be able to get somewhere from there, but that wasn't the case for me. So...on we go!

We execute the given commands in order to be able to run scripts on the target machine. And then we set everythin up to gain access through a reverse shell:
- We first set up an http server on port 80 to host the shell.ps1 document that we have created
- Then we open up a netcat listener on port 443 (do not & that process!)
- We open our firewall so that only 10.10.10.27 can access the services mentioned above
- We execute a command on the target computer to gain a reverse shell
 
From there everything becomes a bit easier

## We are in - the last step

With access to the target machine we simply try to navigate in the filesystem to find the desired files. Move to `C:\`, then to Users, sql_svc and voila!
We have the flag!
- Admin flag: `b91ccec3305e98240082d4474b848528`
- sql_svc flag: `3e7b102e78218e935bf3f4951fec21a3`


## Summing up - a short review
Trying to complete it without looking at any walkthrough was quite a challenge for me - given that I do not have any experience in this field - and it took me longer than I expected. Despite that, I am quite happy for being able to complete it this way 'cause I really loved the process of searching and trying to connect the dots between the instructions and the actual implementation. I hope you guys like it as well. See you soon





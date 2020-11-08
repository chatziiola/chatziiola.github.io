---
title: 'HTB: Oopsie!'
description: "How we managed to complete the 2nd room"
category: 'Hack The Box'
date: 2020-11-08
image:
 path: '/images/htbsp/oopsie/oopsie-final.png'
 caption: "Just 2 more to go!"
---

Today we're gonna study the `Oopsie` machine of [Hack The Box](https://www.hackthebox.eu) starting point series.

<!-- vim-markdown-toc GFM -->

* [Enumeration](#enumeration)
	* [Burp Suite](#burp-suite)
* [Uploading a reverse shell](#uploading-a-reverse-shell)
* [Little *bug*](#little-bug)
* [Thoughts](#thoughts)

<!-- vim-markdown-toc -->


# Enumeration
First things first, let's study the target machine. We already know its IP address (`10.10.10.28`) and we want to learn as possible about the services used on it.
The walkthrough suggest that we simply perform a stealth scan along with -A parameter in order to get more information, however, it struck me that our approach in the previous room was giving as some more information (*what if there were other ports open as well*) so I additionally performed a quick ping scan on all ports to see which ones are open and then I scanned the *only open ports* with the -sV and -sC parameters (version and script scan).
> Disclaimer: This scan I described should be extremely noisy to be used in a real-life environment. However, since we are simply doing *CTF-like* challenges, it doesn't really matter

The first scan reveals that there are only two ports open
![portscanresults](/images/htbsp/oopsie/oopsie-portscan.png)

While the second one makes it almost obvious that `10.10.10.28` is a website server
![svscscan](/images/htbsp/oopsie/oopsie-svcscan.png)


## Burp Suite

Proceeding like that, we load the website and we understand that it is an auto manufacturer's webpage. That doesn't really matter but, exploring the homepage (the only one actually that we can access) we realize that there must be a way to login by its reference. That's where [Burp Suite](https://portswigger.net/burp) comes into play. We first need to setup a proxy so that all data associated to the webpage go through the Burp Suite for a more precise examination. It's not something terribly difficult and can be easily done by heading to your browser preferences (*for me, a firefox user, it was as easy as heading there and searching the word proxy*) where you need to insert the location of your burp suite listener (*by default it should be 127.0.0.1:8080*). There are, of course, other ways to do it, like installing addons to your browser to quicklychange your proxy settings.

Step by step, we get more information regarding the machine. It is obvious that there is a login-page, against which we try the credentials of the previous room. The administrator password is the same one we saw on the previous machine and so we get to see what other services are provided. At that point, it becomes known to us that there is a higher tier in privileges hierarchy, the `super admin` role. Obviously, we need to find a way to login as a super admin, so that we can then upload a file (*like a reverse shell*) to further examine the machine. We head back to burp suite and we notice that each user is associated with one id (and the one that is related to our user is 1). Since it looks like a small company there's a chance that we can bruteforce the webpage in order to get the `super admin` id. We do so, through burp suite, by trying the first 100 ids, and looking at the data sent back to us. The id `30` is what we needed and from that *packet* we get also get all the necessary information to **pretend** that we are the super admin to the webpage, after carefully editing the outgoing packets to have his signature. 

# Uploading a reverse shell

Then things become a lot easier, because of the fact that with the manipulation of just two packets we are able to upload the reverse shell to the server (*if you had any problems trying to find the php-reverse-shell.php, use the `locate` command to check where it is on your machine*). We open up a netcat listener on our computer so that we can *receive the reverse shell*, and we *ask* the website for the reverse shell so that the code is executed.
> **Important**: make sure to change the necessary values in the php-reverse-shell.php file before uploading so that the traffic comes back to your computer

That is how we gain access to a shell.

# Little *bug*
If you're one of the i-don't-only-follow-instructions-I-want-to-see-what's-happening type of people you may have already realized that we actually don't need to continue exploiting the machine. Of course, as it turns out, that's needed (not quite) for us to continue in the next machine but, you can get your flags at that point by simply **catting** the files

# Thoughts
Even though I liked it and followed the walkthrough to the end to learn as much as I could, I wish there wasn't that little bug there. To sum up, I could say that this was a great room in terms of exposing me to the 'Burp Suite' and to the methodology of scanning a webpage and paying attention to the detail. 

Hope you're all safe and well. See you soon!


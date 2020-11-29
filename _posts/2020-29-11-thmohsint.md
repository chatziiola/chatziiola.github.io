---
title: "THM: OHSint"
description: "Introductory room to Open Source Reconaissance"
date: 2020-11-29
image:
 path: /images/thm/ohsint/blog.png
 caption: Photo by Ricardo Gomez Angel on [Unsplash](https://unsplash.com/photos/blfhimCwxLQ)
category:
 - Try Hack Me
tag:
 - Walkthrough
---

Hello everybody ! It's Saturday evening and a great day to hone our skills! Let's launch our terminals and dive in!

{% include toc %}

# Before you begin
This room didn't take me more than 20 minutes to complete and I guess that for most of you this will be the case. However, there are interesting "leads" to follow, making it the reason why I intend to *extensively* research on steganography and cryptography over the next couple days and write an article on it. I found a study on the topic and I was amazed to learn about it, more information coming soon...

# Basic Info
If you have never heard of data being "hidden" inside images, pdfs, videos, you may feel a little strange when you see that you have to find that man's password, email, avatar, location by *using* **just an image**. It is, however, extremely easy for you to see what ther e is inside that image:
 - Unlike most regular people, my first *instinct* was to use `strings`. That wonderful little piece of software lets you "print" to your terminal all the *printable* characters in a file, so I used it on the image and piped the output to less - to filter it. The first 20 lines or so where obviously data someone had added to the image and it was there that I had to look for information. Then, one only had to notice that the *copyright* section of the metadata had a value of "OWoodflint", hint which we could easily follow.

> Backstage: To be frank, I did quite some research on the GPS elements that are embedded on the image as well, but they didn't seem to be very helpful - a dead end you could say. 

# Now what?
Ok, we have the `OWoodflint` string, but what is there to it? How can we use it? If you don't know anything about something you search for info and that's exactly what one must do in this room. By simply "googling" the string given, you will find a twitter and a github account with that username as well as a personal website. Digging just a little bit more into it, you can find even more stuff. More specifically:

### Question 1: What is this users avatar of?
The twiiter profile is all you need to look at to answer that question: a *cat*.

### Question 2: What city is this person in?
You can get that information from *at least* two sources. Github and Twitter. The simplest one is GitHub, since it is there that he plainly states he lives in *London*. It is not, though, what I did to gather this piece of information and it helped me answer faster the next question. If you view his tweets (see the one embedded below), it is understood that a Wireless Network with a given BSSID is within reach from his house. (At this point - please forgive my use of he/him and his here, it is just for practicality). By heading to [Wigle](https://wigle.net), we can search which network in the planet has this specific BSSID and that way, we find out he's in London. 

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">From my house I can get free wifi ;D<br><br>Bssid: B4:5D:50:AA:86:41 - Go nuts!</p>&mdash; 0x00000000000000000000 (@OWoodflint) <a href="https://twitter.com/OWoodflint/status/1102220421091463168?ref_src=twsrc%5Etfw">March 3, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

### Question 3: Whats the SSID of the WAP he connected to?
It is plainly written in Wigle: 'UnileverWifi'

### Questions 4,5: What is his personal email address?
By visiting the github repo you can see that:

> Project starting soon! Email me if you want to help out: OWoodflint@gmail.com <cite> OWooflint himself </cite>

### Question 6: Where has he gone on holiday?
Head to his blog and you'll see that the only post he's ever published is from New York - on holidays.

### Question 7: What is this persons password?
Now, this should be the most *difficult* question in this room but it is really easy if you think about it. You have 3 sources of information:
- **Twitter**: which you have very carefully examined right from the start and you can be sure that there isn't anything else there.
- **GitHub**: which you should now head to and check - the answer could be hidden in some older commit (!)
- **The blog**

That's where the *password* is. Simply press <kbd> Ctrl </kbd> + <kbd> Shift </kbd> + <kbd> C </kbd> to view more info on the webpage and methodically study it's content. It shouldn't take more than a minute to find it. 

```html
<p style="color:#ffffff;" class="has-text-color" data-adtags-visited="true">pennYDr0pper.!</p>
```

You're welcome!

# Summary
Hope you all enjoyed this simple walkthrough! There are many more to come and I *urge* everyone here to search some more on the techniques discussed.

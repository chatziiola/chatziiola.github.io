---
title: "HowTo: Linux BackUp"
description: "Κάνε τον δικό σου εξωτερικό σκληρό και οργάνωσε την ενημέρωσή του ώστε να μην ξαναστεναχωριέσαι για χαμένες φωτογραφίες και έγγραφα!"
date: 2020-10-21
category: HowTo
layout: post
---

Όλοι μας έχουμε κατά καιρούς στεναχωρηθεί που δεν βρίσκουμε φωτογραφίες από την τάδε εκδρομή/περίοδο στη ζωή μας, που δεν μπορούμε να βρούμε εκείνη την παλιά εργασία ή ακόμα και έγγραφα που κάποια στιγμή είχαμε (και θα μας χρησίμευαν πολύ την παρούσα στιγμή). Γιατί, όμως, δεν τα βρίσκαμε? Η απάντηση σε αυτή την ερώτηση, αδιαμφισβήτητα, δεν είναι μόνο μια. Μπορεί να οφείλεται σε λάθος της στιγμής και αδυναμία επαναφοράς του, μπορεί να οφείλεται σε ξαφνική δυσλειτουργία του υπολογιστή (βλέπε να πέσει νερό στο laptop!) αλλά και σε πολλούς άλλους παράγοντες. Το σημερινό άρθρο δεν εχει σκοπό να **σας δείξει πως να μην χάσετε ΠΟΤΕ ξανά αρχεία**, (θα ήταν παράλογο, άλλωστε, σε εκείνη την περίπτωση να μην είχα χρησιμοποιήσει τον πιασάρικο αυτό τίτλο). Αντ' αυτού, μπορεί να σας δείξει πως να περιορίσετε στο ελάχιστο την πιθανή ζημιά.

> **Μία αστεία ιστορία**: 
>
> Μην αισθάνεστε άσχημα αν σας έχει συμβεί το παραπάνω (ακόμα και αν αυτό έγινε πολλές φορές). Σκεφτείτε να ήσασταν στη θέση ενός εργαζόμενου στη Pixar (ναι την γνωστή) και ... καταλάθος να διαγράφατε το Toy Story 2 ( **όλο** ) και το Bug's Life ( ελάχιστους μήνες πριν αυτό προβληθεί στους κινηματογράφους ). Ναι, υπάρχουν και [χειρότερα](https://thenextweb.com/media/2012/05/21/how-pixars-toy-story-2-was-deleted-twice-once-by-technology-and-again-for-its-own-good/).

Τώρα ας γυρίσουμε στο θέμα μας.

<!-- vim-markdown-toc GFM -->

* [Back Up](#back-up)
	* [Find the disk](#find-the-disk)
	* [Partitions](#partitions)
	* [Regular Back Ups](#regular-back-ups)
	* [Automatization](#automatization)
* [Summing Up](#summing-up)
	* [Complementary material:](#complementary-material)

<!-- vim-markdown-toc -->

# Back Up 

## Find the disk

Σε αυτό το σημείο μπορεί πολλοί να αντιμετωπίσουν πρόβλημα (η εντολή να μην εμφανίζει αποτέλεσμα). Αυτό, δεδομένου ότι η εντολή ανήκει σε εκείνες που έρχονται προεγκατεστημένες σε κάθε Linux Distribution, μπορεί να αποδοθεί σε μία συγκεκριμένη λειτουργία. Για λόγους ασφάλειας δεν επιτρέπεται η χρήση του προγράμματος από άτομα που στερούνται των σχετικών δικαιωμάτων ( είναι πολύ περίεργο το συναίσθημα του να αναλύεις έτσι τα permissions ). H λύση? Τρέξτε το με `sudo`.

``` bash
fdisk -l
```

Η *έξοδος* της εντολής είναι το σύνολο των συσκευών που είναι συνδεδεμένες στο σύστημα που δουλεύετε, επιτρέποντας μας να προσδιορίσουμε πως αναγνωρίζεται από το λογισμικό ο σκληρός με τον οποίο θα εργαστούμε.

![Fdisk Output](/images/linuxBU/fdiskOutputpng.png)

Στη δική μου περίπτωση ο δίσκος είναι ο `/dev/sda/`. Δεν έχει, όμως, σίγουρα και ο δικός σας δίσκος αυτή την περιγραφή. Εξετάστε το αποτέλεσμα προσεκτικά. Έχοντας βρει τον δίσκο μας, μπορούμε να περάσουμε στο επόμενο βήμα.

## Partitions
Αν είναι η πρώτη σας επαφή με το αντικείμενο, λογικά, θα αναρωτιέστε τι ακριβώς είναι τα partitions και ποιός είναι ο στόχος μας τώρα. Προσεγγίζοντας το απλά, ο στόχος μας είναι ο ορισμός της *σύμβασης* που θα ακολουθήσουμε κατά την χρήση *μέρους* ή και ολόκληρου του δίσκου. 
Δηλαδή:
- Αρχικά θα πρέπει να αποφασίσουμε αν θα χρησιμοποιήσουμε ολόκληρο τον δίσκο ή μέρος αυτού. Στο συγκεκριμένο tutorial, θα εργαστούμε εκμεταλλευόμενοι όλο τον σκληρό, καθώς η διαδικασία για μέρος του σκληρού είναι πανομοιότυπη και λιγότερο εύχρηστη για backup.
- Στη συνέχεια καλούμαστε να επιλέξουμε [filesystem](https://searchstorage.techtarget.com/definition/file-system) για τον σκληρό, 'ορίζοντας' ουσιαστικά τη σύμβαση που αναφέραμε παραπάνω. Προσωπικά θεωρώ (μετά από όχι τόσο αναλυτική έρευνα [1](https://unix.stackexchange.com/questions/1430/rock-stable-filesystem-for-large-files-backups-for-linux), [2](https://unix.stackexchange.com/questions/85959/which-filesystem-to-backup-is-the-best) ) πως ο μέσος χρήστης θα είναι παραπάνω απο καλυμένος με την χρήση του [EXT4](https://en.wikipedia.org/wiki/Ext4)

```bash
# replace /dev/sda with your disk
# optional - show partitions
fdisk -l /dev/sda   

# you may need to specify partition for part of the disk
mkfs.ext4 /dev/sda  
```
Σε αυτό το σημείο έχουμε ολοκληρώσει, ουσιαστικά το format του δίσκου, ώστε εκείνος να μπορεί να χρησιμοποιηθεί για back up. Τα επόμενα βήματα δεν είναι αναγκαία, και βοηθούν **αποκλειστικά** στην διευκόλυνση της ζωής ενός και την διαμόρφωση καλύτερων συνηθειών γύρω από τα back up.

Για όσους θέλουν να χρησιμοποιήσουν τώρα τον σκληρό:
```bash
# replace /dev/sda with your disk
# Create a folder in the /media/ directory
mkdir /media/zoaki
# Use the folder you just created as a mountpoint for your drive
sudo mount /dev/sda /media/zoaki
# You can acess your HD contents as if it is the /media/zoaki dir
# e.g The following command should give you an empty dir
# 		ls /media/zoaki/ 
# When you've finished working on it
sudo umount /dev/sda
```
## Regular Back Ups
Ήρθε η ώρα να γνωρίσουμε άλλη μία εντολή: `rsync`. Για όσους δεν έχουν ακόμα ιδιαίτερη ευχέρεια στην χρήση του terminal ( αν το αποκαλείς command prompt, ευγενικά πάντα, είσαι άρρωστος και πρέπει απαραιτήτως να επισκεφτείς γιατρό ), *σχεδόν* όλα τα προγράμματα κατά την εγκατάσταση τους έρχονται με ... *οδηγίες* τις οποίες μπορεί κανείς να διαβάσει με δύο τρόπους:

```bash
man rsync
rsync -h 	# --help 
```
Η πρώτη ανοίγει την σελίδα του manual ( εξού και man! τρελό, το ξέρω! ), ενώ η δεύτερη παραθέτει σε μία πιο συνοπτική μορφή τις παραμέτρους που μπορεί να χρησιμοποιήσει κανείς στην εν λόγω εφαρμογή. Εστιάζοντας στην `rsync` έχουμε:

```bash
# source: man rsync:
# --archive, -a            archive mode; equals -rlptgoD (no -H,-A,-X)
# --update, -u             skip files that are newer on the receiver
# --compress, -z           compress file data during the transfer
# --backup, -b             make backups (see --suffix & --backup-dir)
# an interesting option as well is --delete
```
Συνδυάζοντας τις παραπάνω βασικές  παραμέτρους: `rsync -aubz [SRC] [DEST]`,όπου:
- SRC	: το dir το οποίο θέλετε να κάνετε back up
- DEST	: το mountpoint του σκληρού
 
Αν για παράδειγμα, ήθελα να κάνω back up το home directory (~) και ο σκληρός μου βρισκόταν στον φάκελο του προηγούμενου παραδείγματος θα έπρεπε να τρέξω:

```bash
rsync -abuz ~ /media/zoaki
```

## Automatization
Πώς θα μπορούσαμε, όμως, εφαρμόζοντας την νοοτροπία των Linux συστημάτων να γλυτώσουμε αυτή την "άσχημη" διαδικασία και να γράψουμε ένα *δικό* μας προγραμματάκι, να μας λύνει τα χέρια? Στο παιχνίδι τώρα μπαίνει και το τελευταίο πρόγραμμα που θα χρησιμοποιήσουμε: `cron`.

**Τί θα κάνουμε?**
- Αρχικά θα δημιουργήσουμε έναν φάκελο στον οποίο θα βάλουμε το υλικό της αυτοματοποίησης.
	- Εκεί θα δημιουργήσουμε τα κατάλληλα αρχεία:
		- *tobackup.txt*, στο οποίο θα γράψουμε το path των φακέλων και αρχείων που θέλουμε να κάνουμε συστηματικά back up.
		- *backup.sh*, στο οποίο θα αναλύουμε την διαδικασία αντιγραφής/backup που θα εκτελείται σε επίπεδο εβδομάδας (το τελευταίο μπορείτε να το θέσετε *πραγματικά* σε ο,τι επιθυμεί η ψυχή σας)
- Θα βάλουμε το κατάλληλο *tag* στον σκληρό μας, προκειμένου να μπορούμε να χρησιμοποιούμε πιο "αόριστα" το παραπάνω script
- Tέλος, θα προσθέσουμε το *backup.sh* στο crontab ώστε να τρέχει αυτοματοποιημένα την στιγμή που θέλουμε

Ας αρχίσουμε:
```bash
# labeling your disk so that it can be mounted like that
e2label /deb/sda /backup
# you need to edit your /etc/fstab file
# use your editor of choice
sudo vim /etc/fstab
# Add this line at the end of the file (without #)
# and feel free to read the manual of fstab
# LABEL=/backup	/media/zoaki	ext4	defaults	1	2
mkdir -p ~/Scripts/bu/
cd ~/Scripts/bu/
touch tobackup.txt backup.sh
crontab -e
# Προσθέστε αυτό στην τελευταία γραμμή 
# (Για περισσότερες πληροφορίες λεπτομέρειες διαβάστε:
# man cron
# τις ιστοσελίδες στο τέλος του άρθρου
0 2 * * 0 /home/<yourusername>/Scripts/backup.sh
```
Επεξεργαστείτε τα δύο αυτά αρχεία με το πρόγραμμα της επιλογής σας - δείτε παρακάτω
```txt
Παράδειγμα για το αρχείο tobackup.txt
.vimrc
.vim/
Projects/
Documents/Work/
Scripts/
```
```bash
# Αντιγράψτε το στο αρχείο backup.sh, αντικαθιστώντας το username σας, 
# Σύμφωνα με αυτό ο υπολογιστής σας θα κλείνει αφού ολοκληρωθεί η διαδικασία
mount -L /backup
rsync -aubz --files-from='~/Scripts/bu/tobackup.txt' /home/<yourusername> /media/zoaki/ 
umount /media/zoaki
poweroff
```

> !Disclaimer: Το συγκεκριμένο, όπως και όλα τα άρθρα στο blog, διατίθεται δωρεάν και αποτελεί το αποτέλεσμα προσωπικής έρευνας και δουλειάς επί του εκάστοτε θέματος. Δεν ευθύνομαι για τυχόν ζημιά. (Αν και πραγματικά θα ήθελα να μάθω πως κατάφερε κάποιος να προκαλέσει ζημιά με το περιεχόμενο αυτού του tutorial).

# Summing Up
Όλο δικό σας. Απολαύστε την ασφάλεια του να έχεις backup!

## Complementary material:
Για όσους θέλουν να δουν και κάτι παραπάνω, ακολουθούν μερικοί συνδέσμοι με άρθρα που μου φάνηκαν χρήσιμα κατά την διαδικασία "δημιουργίας" του δικού μου back up και έρευνας για το άρθρο:
- [HowToGeek: Filesystem](https://www.howtogeek.com/196051/htg-explains-what-is-a-file-system-and-why-are-there-so-many-of-them/)
- [Rsync and cron](https://www.jveweb.net/en/archives/2011/02/using-rsync-and-cron-to-automate-incremental-backups.html)
- [Crontab guru](https://crontab.guru/every-week)
- Θα ενημερωθούν άμεσα αλλά λόγω κούρασης θεώρησα προτιμότερο να προσθέσω τα references κάποια άλλη μέρα

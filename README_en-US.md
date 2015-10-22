Why is the default README written in Simplified Chinese?
--------------------------------------------------------
This script is intended to be used by Chinese competitive programmers.  It is
mostly useless for people who cannot read Chinese.  This English version of
README is put up just in case you are curious what this script is about.

What is BZOJ?
-------------
Short answer: a Chinese OJ.

Long answer:
大视野在线测评, which roughly translates as "Wide Vision Online Judge", is
one of the online judges popular among Chinese competitive programmers.  It
used to be called "八中OJ" (No. 8 High School's Online Judge) because it's
run by Hunan Hengyang No. 8 High School.  As with POJ, CF, SPOJ and so on,
we also refer to this online judge by a de facto shorthand, "BZOJ", which is
the pinyin abbreviation of "八中OJ".  While BZOJ is no longer formally
associated with No. 8 High School, the jargon remains popular among the
majority of Chinese competitive programmers.  The formal name 大视野在线测评,
on the other hand, is rarely used.

Btw, just some personal opinion: BZOJ is a good resource for contestants who
want to get to the next level, but its disrespect for authors, elusion from
copyright liability and paid membership has made it an ethically unacceptable
OJ for me.

Translated version of README.md
-------------------------------

### BZOJ submission downloader
This simple script is written for one of my friend who accidentally deleted
all of his BZOJ solutions.  Enter your user name and password and this script
will dump all of your submissions to BZOJ.

Usage: `./dl.bash MYDIR`

The script is pretty short so if you needed some modifications, just hack it
yourself.

#### dependencies
Most Linux distros come with Bash 4, etc. preinstalled, so these softwares
are not listed below.  If you are using other platforms, you may want to
install additional tools not listed below.
  - Ruby (tested on 1.9.3)
  - cURL


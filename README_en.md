# What is this?

This is a script for mpv player, allowing you to watch videos from animedia.online site right in `mpv`, instead of browser.

# How to install?

Clone this repo to `~/.config/mpv/scripts` (on Linux, or corresponding path to scripts directory for other OS'es, that uses another paths)

(currently, no distributions provide system-wide packages, and most probably never will)

# How to use?

```
$ mpv https://amedia.online/<title_name>/episode/<episode_number>/seriya-onlayn.html
```

At the time of writing this, I've only implemented playing per-episode (using links to the episodes).
But I have plans to support full-title-links (and fill playlist)


If you want to choose another (than "auto") resolution (most of the time there is only 1080p and 360p available in addition to 720p, so for now plugin only supports them), you can declare that by adding `###q=<res>` (where `<res` is the resolution you need) to the end of link

```
$ mpv 'https://<.......>.html###q=1080p'
$ mpv 'https://<.......>.html###q=720p'
$ mpv 'https://<.......>.html###q=360p'

```

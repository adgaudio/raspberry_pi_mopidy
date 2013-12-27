This script will install Mopidy (a music player daemon) and Rompr (a web
frontend) on Ubuntu.  

I use this script to set up a raspberry pi with spotify.

Use like this:

1. Copy or clone files to the raspberry pi (or any server) running Ubuntu
2. Run install script

```
# get files
git clone git git@github.com:adgaudio/raspberry_pi_mopidy.git
# install
cd raspberry_pi_mopidy
sh install.sh SPOTIFY_USER SPOTIFY_PW LASTFM_USER LASTFM_PW
```

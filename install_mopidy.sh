set -e 
set -u

spotify_user=$1
spotify_pw=$2
lastfm_user=$3
lastfm_pw=$4

sudo modprobe ipv6
grep -E "^ipv6" /etc/modules || (echo ipv6 | sudo tee -a /etc/modules)
wget -q -O - http://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
sudo wget -q -O /etc/apt/sources.list.d/mopidy.list http://apt.mopidy.com/mopidy.list
sudo apt-get update
sudo apt-get install -y mopidy
mkdir -p Music
mkdir -p mopidy/playlists

# create the /etc/init.d file and have it automatically start mopidy on boot
cat << EOF | sudo tee /etc/init.d/mopidy
#! /bin/sh

### BEGIN INIT INFO
# Provides: mopidy
# Required-Start: sshd
# Required-Stop: sshd
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Mopidy - Music Player Daemon
# Description: Mopidy is a MPD (Music Player Daemon) that receives instructions from
#  one or more MPD clients (ie rompr, mpdroid, etc) and then plays the requested
#  music.  If configured, it can connect to Spotify, Last.fm, and others.
### END INIT INFO
#
# Script Author:    Alex Gaudio <adgaudio@gmail.com>
#
# /etc/init.d/mopidy

# The following part carries out specific functions depending on arguments.

case "\$1" in
  start)
    echo "Starting mopidy"
    exec sudo -u pi mopidy 2>/home/pi/mopidy.stderr.log 1>/home/pi/mopidy.stdout.log &
    echo "mopidy is alive"
    ;;
  stop)
    echo "Stopping mopidy"
    pkill -f `which mopidy` || echo "mopidy already not running"
    echo "mopidy is dead"
    ;;
  restart)
    echo "Restarting mopidy"
    pkill -f `which mopidy` || echo "mopidy already not running"
    echo " ...starting..."
    exec sudo -u pi mopidy 2>/home/pi/mopidy.stderr.log 1>/home/pi/mopidy.stdout.log &
    echo "done"
    ;;
  *)
    echo "Usage: /etc/init.d/mopidy {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
EOF
sudo chmod +x /etc/init.d/mopidy

sudo update-rc.d mopidy defaults

# Create the mopidy config file...
mkdir -p ~/.config/mopidy
cat << EOF | tee ~/.config/mopidy/mopidy.conf
[mpd]
enabled = true
hostname = ::
port = 6600
max_connections = 20
connection_timeout = 60

[http]
enabled = false
hostname = ::
port = 6680
static_dir = /home/pi/rompr

[local]
enabled = false
media_dir = /home/pi/Music
playlists_dir = /home/pi/mopidy/playlists
tag_cache_file = /home/pi/mopidy/tag_cache

[spotify]
username = $spotify_user
password = $spotify_pw

[scrobbler]
username = $lastfm_user
password = $lastfm_pw

[logging]
debug_file = /home/pi/mopidy.log

[audio]
output = alsasink
EOF

sudo /etc/init.d/mopidy start

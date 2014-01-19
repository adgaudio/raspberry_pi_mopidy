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

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

sudo apt-get install -y mopidy mopidy-spotify
mkdir -p ~/Music
mkdir -p ~/mopidy/playlists
sudo chmod -R 777 ~/mopidy

git clone https://github.com/woutervanwijk/Mopidy-Webclient.git ~/Mopidy-Webclient

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
enabled = true
hostname = ::
port = 6680
static_dir = /home/pi/Mopidy-Webclient/webclient

[local]
enabled = false
data_dir = /var/lib/mopidy/local
media_dir = /var/lib/mopidy/media
playlists_dir = /var/lib/mopidy/playlists
tag_cache_file = /home/pi/mopidy/tag_cache

[spotify]
username = $spotify_user
password = $spotify_pw

[scrobbler]
username = $lastfm_user
password = $lastfm_pw

[logging]
debug_file = /var/log/mopidy/mopidy-debug.log
config_file = /etc/mopidy/logging.conf

[audio]
output = alsasink

[stream]
enabled = true
protocols =
    file
    http
    https
    mms
    rtmp
    rtmps
    rtsp
timeout = 5000
EOF
sudo chmod 777 ~/.config/mopidy/mopidy.conf

mopidy-convert-config

sudo /etc/init.d/mopidy start

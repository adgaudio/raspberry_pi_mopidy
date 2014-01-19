# This is an install script that will install and configure Mopidy (an MPD server)
# and Rompr (a web server that hooks into Mopidy) on an Ubuntu OS.
# 
# The script assumes you already have an internet connection.
#
# Author: Alex Gaudio <adgaudio@gmail.com>  
# Date: 10/19/2013
# -- Feel free to write me if you have questions!

set -e
set -u

# validate that these are set appropriately
spotify_user=$1
spotify_pw=$2
lastfm_user=$3
lastfm_pw=$4

# mopidy - the mpd (music player daemon)
sh install_mopidy.sh $spotify_user $spotify_pw $lastfm_user $lastfm_pw

# rompr - a web client that connects to mopidy
sh install_rompr.sh

# bug fix apache
grep ServerName /etc/apache2/apache2.conf || (echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf)
sudo /etc/init.d/apache2 restart

ip=`hostname`
echo ""
echo "You have two webclients available:"
echo "http://$ip/rompr"
echo "http://$ip:6680"
echo ""
echo "And the mopidy mpd client on port: 6600"

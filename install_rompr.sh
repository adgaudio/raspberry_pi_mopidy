set -u
set -e

cwd=`pwd`
rompr_version="0.32"
mopidy_conf="$HOME/.config/mopidy/mopidy.conf"
music_library="$HOME/Music"

# install rompr and deps
sudo apt-get install -y apache2 php5-curl imagemagick libapache2-mod-php5 php5-json
wget http://sourceforge.net/projects/rompr/files/rompr-$rompr_version.zip
unzip rompr-$rompr_version.zip

# configure it with apache
sed 's|/PATH-TO-ROMPR|'$cwd'/rompr|g' rompr/apache_conf.d/rompr.conf | sudo tee /etc/apache2/conf.d/rompr.conf
#sudo a2enconf rompr
sudo chown -R www-data $cwd/rompr/prefs
sudo chown -R www-data $cwd/rompr/albumart
sudo a2enmod expires
sudo a2enmod headers
sudo a2enmod deflate
sudo a2enmod php5
sudo service apache2 restart

# configure mopidy
sudo chown -R www-data $cwd/rompr/mopidy-tags
[ -z $music_library ] && mkdir $music_library
sudo ln -s $music_library $cwd/None
sudo mkdir -p /etc/mopidy
sudo ln -s $mopidy_conf /etc/mopidy/mopidy.conf

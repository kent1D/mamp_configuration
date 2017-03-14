#!/bin/bash
# MAMP Configuration
#
# Each time that MAMP is updated, it's loosing his specific pear and pecl installation
# 
# This scripts installs the following for each PHP versions :
# - PHP_CodeSniffer (https://github.com/squizlabs/PHP_CodeSniffer)
# - php-imagick (http://php.net/manual/fr/book.imagick.php)
#
brew=$(which brew)
ghostscript=$(which gs)
autoconf=$(which autoconf)
imagemagick=$(which convert)

if [ -z $ghostscript ] || [ -z $autoconf ] || [ -z $imagemagick ]; then
	if [ -z $brew ]; then
		echo "Homebrew est nécessaire pour installer les dépendances."
		echo
		exit 1;
	else
		echo "Installation des dépendances via homebrew."
		echo
		brew install ghostscript autoconf ImageMagick --with-ghostscript
	fi
fi


for dir in /Applications/MAMP/bin/php/*/
do
	echo "Configuration de PHP $(basename $dir)"
	echo ""
	dir=${dir%*/}
	# Installer PHP Code Sniffer (https://tommcfarlin.com/php-codesniffer/)
	PHPCS_install=$($dir/bin/pear list |awk '/^PHP_CodeSniffer/ { print $2 }')
	PHPCS_last=$($dir/bin/pear info PHP_CodeSniffer |awk '/^Release Version/ { print $3 }')
	if [ "$PHPCS_install" != $PHPCS_last ]; then
		echo "Installation de PHP Code Sniffer"
		echo
		"$dir"/bin/pear install PHP_CodeSniffer
	echo
	else
		echo "PHP Code Sniffer est déjà installé à la dernière version ($PHPCS_install)"
		echo
	fi
	
	IMAGICK_install=$($dir/bin/pecl list |awk '/^imagick/ { print $2 }')
	IMAGICK_last=$($dir/bin/pecl info imagick |awk '/^Release Version/ { print $3 }')
	if [ "$IMAGICK_install" != $IMAGICK_last ]; then
		echo "Installation de php-imagick"
		echo
		"$dir"/bin/pecl install  imagick
		echo
	else
		echo "php-imagick est déjà installé à la dernière version ($IMAGICK_install)"
		echo
	fi
	
	IMAGICK_isactivated=$(cat $dir/conf/php.ini |awk '/^extension=imagick.so/')
	if [ -z "$IMAGICK_isactivated" ]; then
		echo "Activation de php-imagick"
		echo 
		echo extension=imagick.so >> "$dir"/conf/php.ini
	else
		echo "php-imagick est déjà activé"
		echo
	fi
done

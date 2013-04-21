#!/bin/bash

# This script was written by Arnaud CHEN-YEN-SU, <arnaud.chenyensu@gmail.com>
# On April 22, 2013
# More information on Github : https://github.com/arnaudchenyensu/Install-Laravel-4

function help ()
{
    echo "A simple script that automate the process of installing and configuring Laravel 4"
    echo ""
    echo "      installLaravel4             - Download, install and configure Laravel 4"
    echo "      installLaravel4 --help      - Print this output"
}

# The only argument is the default value to return
function getInput ()
{
    read
    if [ -z $REPLY ]; then
        echo $1;
    else
        echo $REPLY;
    fi
}

# replace $file $searchterm $replaceByThisTerm
function replace ()
{
     sed "s/$2/$3/" $1 > $1.tmp
     mv $1.tmp $1
}

function downloadLaravel ()
{
    archive=laravel-`date +%s`.zip
    echo -n "What will be the name of your directory? [laravel-develop] "
    directory=$(getInput laravel-develop)

    while [ -d $directory ]; do
        echo -n "Error : This directory already exist. Please specify another one: "
        read
        directory=$REPLY;
    done

    echo "Downloading Laravel 4"
        curl -Lo $archive https://github.com/laravel/laravel/archive/develop.zip
        if [ $? -ne 0 ]; then
            echo "There was an error when downloading Laravel 4..."
            exit 4
        fi

    echo "Decompressing"
        mkdir $directory
        mv $archive $directory; cd $directory;
        unzip $archive > /dev/null
        mv laravel-develop/* .
        rm $archive
}

function isComposerInstallGlobally ()
{
    composer >& /dev/null;
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

function installAndConfigureComposer ()
{
    if  isComposerInstallGlobally ; then
        echo "Great! Composer is already install";
    else
        echo "Oops, seems like Composer is not install... I'll install it into your project"
        curl -sS https://getcomposer.org/installer | php;
        if [ $? -ne 0 ]; then
            echo "There was an error when installing composer... Please fix it before continuing"
            exit 2;
        fi
        locally='true'
    fi

    echo "Configuring the Laravel Generator of JeffreyWay"
    echo "More information on github : https://github.com/JeffreyWay/Laravel-4-Generators"
    # Adding the needed line in composer.json
    tmp='composer.json.tmp'
    awk  '// {print;} /framework/ {print "\t \t\"way/generators\": \"dev-master\"";} ' composer.json > $tmp
    sed 's/*"/*",/' $tmp > composer.json
    rm $tmp
    # Adding the needed line in app/config/app.php
    app_file=app/config/app.php
    awk '/WorkbenchServiceProvider/ {getline; print "\t \t'\''Way\\Generators\\GeneratorsServiceProvider'\''";} // {print;}' $app_file > $app_file.tmp
    mv $app_file.tmp $app_file
}

# Installing dependencies with Composer
function installDependencies ()
{
    if isComposerInstallGlobally ; then
        composer install
    else
        php composer.phar install
    fi
    if [ $? -ne 0 ]; then
        echo "There was a problem when installing dependencies."
        exit 3
    fi
}

function configureLaravel ()
{
    php artisan key:generate

# Configuring the database
    database_config_file=app/config/database.php
    echo "Now we need to configure the database"
    echo -n "Host of your database? [localhost] "
    host=$(getInput localhost)
    replace $database_config_file "'host'      => 'localhost'" "'host'      => '$host'"

    echo -n "Name of your database? [database] "
    name=$(getInput database)
    replace $database_config_file "'database'  => 'database'" "'database'  => '$name'"

    echo -n "User of your database? [root] "
    username=$(getInput root)
    replace $database_config_file "'username'  => 'root'" "'username'  => '$username'"

    echo -n "Password of your database? "
    read
    password=$REPLY
    replace $database_config_file "'password'  => ''" "'password'  => '$password'"

    echo "You're ready to go! Just make sure that app/storage directory is writable by the web server"
}

if [ $# -eq 0 ]; then
    downloadLaravel
    installAndConfigureComposer
    installDependencies
    configureLaravel
    exit 0
else
    case $1 in
    --help)
            help
            exit 0
            ;;
    *)
            echo "Invalid argument"
            help
            exit 5
            ;;
    esac
fi

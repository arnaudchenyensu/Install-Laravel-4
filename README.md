This simple script automates the process of installing and configuring Laravel 4.

## Installation 

You first need to download the script :
```
curl -LO https://raw.github.com/arnaudchenyensu/Install-Laravel-4/master/src/installLaravel4.sh
```

Make sure it's executable :
```
chmod +x installLaravel4.sh
```

Finally run it :
```
./installLaravel4.sh
``` 

## How it works?

This script works like this :

1. Download Laravel 4
2. Install and configure Composer by adding the [Laravel Generator](https://github.com/JeffreyWay/Laravel-4-Generators) of [Jeffrey Way](https://github.com/JeffreyWay)
3. Install the dependencies using Composer
4. Configure Laravel 4 (generate key and configure the database)

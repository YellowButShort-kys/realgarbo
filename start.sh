#!/bin/bash
echo "Starting the bot..."
cd ~/Carp/realgarbo
for (( ; ; ))
do
    git pull
    ~/Carp/love.AppImage ./
    echo "Crash detected... Restarting"
done

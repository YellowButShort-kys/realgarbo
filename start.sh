#!/bin/bash
echo "Starting the bot..."
cd ~/code/realgarbo
for (( ; ; ))
do
    git pull
    ~/code/love12/love.AppImage ./
    echo "Crash detected... Restarting"
done

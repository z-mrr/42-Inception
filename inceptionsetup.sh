#!/bin/sh
sudo adduser jdias-mo
sudo usermod -aG sudo jdias-mo
if [ "$USER" = "root" ] || groups "$USER" | grep -q "\bsudo\b"; then
    echo "Setting up Inception..."
else
    echo "$USER is not a member of the sudo group. Exiting."
    exit 1
fi


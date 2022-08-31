#!/bin/bash

##################################################################
# Make a bunch of iOS App icons from a Master
# Given an image at least 512x512 pixels named icon.png, resize and create a
# duplicate at each specified size. Add new sizes as needed. When finished,
# copy the resulting images into your Xcode iOS project.

OUTDIR=appIcons

# Make sure there is an iOS directory already
if [ ! -d ./appIcons ] 
  then
    mkdir appIcons
fi

if [ ! -f icon.png ]
  then
    echo Please add a PNG image named icon.png to this folder and re-run this script.
    exit 1
fi

echo Making $OUTDIR if it does not already exist.
[ -d $OUTDIR ] || mkdir -p $OUTDIR

echo Generating Icons...

sips -z 20 20 --out $OUTDIR/AppIcon-20x20@1x.png icon.png
sips -z 40 40 --out $OUTDIR/AppIcon-20x20@2x.png icon.png
sips -z 60 60 --out $OUTDIR/AppIcon-20x20@3x.png icon.png
sips -z 29 29 --out $OUTDIR/AppIcon-29x29@1x.png icon.png
sips -z 58 58 --out $OUTDIR/AppIcon-29x29@2x.png icon.png
sips -z 48 48 --out $OUTDIR/AppIcon-48x48.png icon.png
sips -z 55 55 --out $OUTDIR/AppIcon-55.png icon.png
sips -z 66 66 --out $OUTDIR/AppIcon-66.png icon.png
sips -z 88 88 --out $OUTDIR/AppIcon-88.png icon.png
sips -z 82 82 --out $OUTDIR/AppIcon-82.png icon.png
sips -z 92 92 --out $OUTDIR/AppIcon-92.png icon.png
sips -z 100 100 --out $OUTDIR/AppIcon-100.png icon.png
sips -z 102 102 --out $OUTDIR/AppIcon-102.png icon.png
sips -z 90 90 --out $OUTDIR/AppIcon-90.png icon.png
sips -z 172 172 --out $OUTDIR/AppIcon-172.png icon.png
sips -z 196 196 --out $OUTDIR/AppIcon-196.png icon.png
sips -z 172 172 --out $OUTDIR/AppIcon-172.png icon.png

sips -z 216 216 --out $OUTDIR/AppIcon-216.png icon.png
sips -z 234 234 --out $OUTDIR/AppIcon-234.png icon.png

sips -z 87 87 --out $OUTDIR/AppIcon-29x29@3x.png icon.png
sips -z 40 40 --out $OUTDIR/AppIcon-40x40@1x.png icon.png
sips -z 80 80 --out $OUTDIR/AppIcon-40x40@2x.png icon.png
sips -z 120 120 --out $OUTDIR/AppIcon-40x40@3x.png icon.png
sips -z 512 512 --out $OUTDIR/AppIcon-512@2x.png icon.png
sips -z 120 120 --out $OUTDIR/AppIcon-60x60@2x.png icon.png
sips -z 180 180 --out $OUTDIR/AppIcon-60x60@3x.png icon.png
sips -z 76 76 --out $OUTDIR/AppIcon-76x76@1x.png icon.png
sips -z 152 152 --out $OUTDIR/AppIcon-76x76@2x.png icon.png
sips -z 167 167 --out $OUTDIR/AppIcon-83.5x83.5@2x.png icon.png
sips -z 1024 1024 --out $OUTDIR/AppIcon-1024@2x.png icon.png
#!/bin/bash

source /usr/local/lib/flashbang_lib.sh
# lc_error() exits with exit information of last command of script
# check_file() [FILE] Check if File exists and create
# check_dir() [DIR]  Check if Directory exists and create
# check_root() Checks if user is root and exits if not
# Colors $COL[R,G,B,Y,LR..] for Color. $COLD for Reset
# $SCRIPTNAME and $SCRIPTPATH for Name and Path
# $PIPEFILE for Pushbulletervice dir is "/home/flashbang/Data/pushbullet.pipe"
# log_and_pipe() "logtext" - logs given Text and sends ist tp pipe, if existant


# Skript zur estellung eines Backups meiner wichtigen Dateien

# ------Einstellungen------
ERRORLOG="/home/flashbang/Data/backup-errors.log"
LOG="/home/flashbang/Data/backup.log"
MESSAGETIME=8
BACKUPDIR=/mnt/ext
SOURCE=/mnt/NAS
EXCLUDES=""

DATUM="$(date +%Y-%m-%d_%H:%M)"
START="$(date +%s)"
cd /
logger "$SCRIPTNAME - gestartet"

############### Funktionen ###################



############ Mount check ###############

if ! mount | grep "$SOURCE" > /dev/null; then
        log_and_pipe "$SCRIPTNAME - NAS Backup fehler Quell-Festplatte: $BACKUPDIR, nicht gemountet oder Verzeichnis nicht vorhanden"
        exit 1
fi

if ! mount | grep $BACKUPDIR > /dev/null; then
        log_and_pipe "$SCRIPTNAME - NAS Backup fehler Backup-Festplatte: $BACKUPDIR ist aus irgend einem Grund nicht vorhanden."
        exit 2
fi

############# Backup ######################

        /usr/bin/rsync -av --delete $EXCLUDES $SOURCE $BACKUPDIR > $LOG 2> $ERRORLOG
        if [ $? -ne 0 ]; then
                log_and_pipe "$SCRIPTNAME - Backup fehlerhaft! Das Backup am ${DATUM} hat einen Fehler beim copieren von $SOURCE nach $BACKUPDIR erzeugt."
        exit 5
        fi

wait
STOP=$(date +%s)
TIME=$(($STOP-$START))
TIMEM=$(($TIME/60))
FILESZIZE=$(df -h  --output='used' $BACKUPDIR | tail -1 | sed 's/ //g')


while [ $(date +%H) -le $MESSAGETIME ] ; do
        sleep 55
done

log_and_pipe "Backup erfolgreich beendet nach $TIMEM min. Dateigroesse: $BACKUPDIR: $FILESZIZE"

exit 0

#!/bin/bash
# Skript zur estellung eines Backups meiner wichtigen Dateien

# ------Einstellungen------
BACKUPDIR=media/Backup
SOURCE=media/NAS/NAS/
EXCLUDE="--exclude=media/NAS/NAS/Filme --exclude=media/NAS/NAS/Serien"
DATUM="$(date -I)"
MAILUSER=flashbang

cd /

if [ ! -d "${SOURCE}" ]; then

mail -s "NAS nicht gemountet oderVerzeichnis nicht vorhanden" $MAILUSER <<EOM
${SOURCE} ist aus irgend einem Grund nicht vorhanden.
EOM

exit 1

else

if [ ! -d "${BACKUPDIR}" ] ; then

mail -s "Backup-Festplatte nicht gemountet oder Verzeichnis nicht vorhanden" $MAILUSER <<EOM
${BACKUPDIR} ist aus irgend einem Grund nicht vorhanden.
EOM

exit 2

fi
fi

if [ ! -f $BACKUPDIR/Backup* ]; then

tar -cpf $BACKUPDIR/Backup"$DATUM".tar $SOURCE $EXCLUDE

else

tar -upf $BACKUPDIR/Backup* $SOURCE $EXCLUDE
mv -f $BACKUPDIR/Backup* $BACKUPDIR/Backup"$DATUM".tar

fi

if [ $? -ne 0 ]; then

mail -s "Backup war fehlerhaft!" $MAILUSER <<EOM
Hallo Admin,
das Backup in ${BACKUPDIR} am ${DATUM} wurde mit Fehler(n) beendet.
EOM

exit 5

else

mail -s "Backup war erfolgreich!" $MAILUSER <<EOM
Hallo Admin,
das Backup in ${BACKUPDIR} am ${DATUM} wurde ohne Fehler beendet.
EOM
fi

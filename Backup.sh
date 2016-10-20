#!/bin/bash
# Skript zur estellung eines Backups meiner wichtigen Dateien

# ------Einstellungen------
BACKUPDIR=media/HDD/Backup
SOURCE=media/NAS/NAS/
EXCLUDE="--exclude=media/NAS/NAS/Download --exclude=media/NAS/NAS/Filme --exclude=media/NAS/NAS/Serien"
DATUM="$(date -I)"

cd /

if [ ! -d "${SOURCE}" ]; then

mail -s "NAS nicht gemountet oderVerzeichnis nicht vorhanden" root <<EOM
${SOURCE} ist aus irgend einem Grund nicht vorhanden.
EOM

exit 1

else

if [ ! -d "${BACKUPDIR}" ] ; then

mail -s "Backup-Festplatte nicht gemountet oder Verzeichnis nicht vorhanden" root <<EOM
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

mail -s "Backup war fehlerhaft!" root <<EOM
Hallo Admin,
das Backup in ${BACKUPDIR} am ${DATUM} wurde mit Fehler(n) beendet.
EOM

else

mail -s "Backup war erfolgreich!" root <<EOM
Hallo Admin,
das Backup in ${BACKUPDIR} am ${DATUM} wurde ohne Fehler beendet.
EOM
fi

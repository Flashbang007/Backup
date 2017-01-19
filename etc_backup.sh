#!/bin/bash
# Script fuer inkrementelles Backup mit 14 taegigem Vollbackup

### Einstellungen ##
BACKUPDIR="/media/NAS/NAS/Dokumente/etc_backup"           ## Pfad zum Backupverzeichnis
ROTATEDIR="/media/NAS/NAS/Dokumente/etc_backup/rotate"    ## Pfad wo die Backups nach 14 Tagen konserviert werden
TIMESTAMP="timestamp.dat"          ## Zeitstempel
SOURCE="/etc"                      ## Verzeichnis(se) welche(s) gesichert werden soll(en)
DATUM="$(date +%d-%m-%Y)"          ## Datumsformat einstellen
ZEIT="$(date +%H:%M)"              ## Zeitformat einstellen >>Edit bei NTFS und Verwendung auch unter Windows : durch . ersetzen

### Verzeichnisse/Dateien welche nicht gesichert werden sollen ! Achtung keinen Zeilenumbruch ! ##
#EXCLUDE="--exclude=home/user/Filme --exclude=home/user/Musik --exclude=home/user/Spiele --exclude=home/user/.VirtualBox  --exclude=home/user/.local/share/Trash"

### Wechsel in root damit die Pfade stimmen ##
cd /

### Backupverzeichnis anlegen ##
mkdir -p ${BACKUPDIR}

### Test ob Backupverzeichnis existiert ##
if [ ! -d "${BACKUPDIR}" ]; then
logger -i $(echo "`basename "$0"` fehlgeschlagen")
 . exit 1
fi

### Alle Variablen einlesen und letzte Backupdateinummer herausfinden ##
set -- ${BACKUPDIR}/backup-???.tgz
lastname=${!#}
backupnr=${lastname##*backup-}
backupnr=${backupnr%%.*}
backupnr=${backupnr//\?/0}
backupnr=$[10#${backupnr}]

### Backupdateinummer automatisch um +1 bis maximal 14 erhoehen ##
if [ "$[backupnr++]" -ge 14 ]; then
mkdir -p ${ROTATEDIR}/${DATUM}-${ZEIT}

### Test ob Rotateverzeichnis existiert##
if [ ! -d "${ROTATEDIR}/${DATUM}-${ZEIT}" ]; then
logger -i $(echo "`basename "$0"` fehlgeschlagen")
 . exit 1
else
### /b* und /t* weil die Dateien nur mit b und t beginnen ##

for i in $(ls -tr ${ROTATEDIR} | sed '$d') ; do
rm -rf ${ROTATEDIR}/$i
done

mv ${BACKUPDIR}/b* ${ROTATEDIR}/${DATUM}-${ZEIT}
mv ${BACKUPDIR}/t* ${ROTATEDIR}/${DATUM}-${ZEIT}
fi

### Abfragen ob das Backupverschieben erfolgreich war ##
if [ $? -ne 0 ]; then
logger -i $(echo "`basename "$0"` fehlgeschlagen")
exit 1
else
### die Backupnummer wieder auf 1 stellen ##
backupnr=1
fi
fi

backupnr=000${backupnr}
backupnr=${backupnr: -3}
filename=backup-${backupnr}.tgz

### Nun wird das eigentliche Backup ausgefuehrt ##
tar -cpzf ${BACKUPDIR}/${filename} -g ${BACKUPDIR}/${TIMESTAMP} ${SOURCE} ${EXCLUDE}

### Abfragen ob das Backup erfolgreich war ##
if [ $? -ne 0 ]; then
logger -i $(echo "`basename "$0"` fehlgeschlagen")
else
logger -i $(echo "`basename "$0"` war erfolgreich")
fi

exit 0

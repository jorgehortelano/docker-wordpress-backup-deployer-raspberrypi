#!/bin/bash

# Generate your Dropbox token: https://www.dropbox.com/developers/apps
DROPBOX_TOKEN=Gx1iJ8k2v6kAAAAAAAAASUq4HCr0TlpCA-Tq9WlSDdo_fSPfjgpXCAyS6HfR3dcD

# If you have multiple folders with WordPress files, add/remove them from this array
directories=( "/var/www/wp-content" "/usr/src/wordpress" )

for dir in "${directories[@]}"
do
  printf "Backing up $dir"
  cd $PREFIX/$dir

  echo -e "Compressing directory...\n"
  BACKUP_FILENAME=backpup_${dir}_$(date -d today "+%Y-%m-%d_%H-%M-%S").tar.gz
  tar czf $BACKUP_FILENAME $dir

  echo -e "Uploading to Dropbox...\n"
  curl -k --progress-bar -i --globoff -o /tmp/dropbox 
  --upload-file $BACKUP_FILENAME https://api-content.dropbox.com/1/files_put/auto/$BACKUP_FILENAME 
  -H "Authorization:Bearer $DROPBOX_TOKEN"

  echo -e "Removing files...\n"
  rm $BACKUP_FILENAME
done
  
echo -e "Exporting database...\n"
DATABASE_FILENAME=backpup_database_$(date -d today "+%Y-%m-%d_%H-%M-%S").tar.gz.sql
/usr/local/bin/wp db export --add-drop-table $DATABASE_FILENAME
rm $DATABASE_FILENAME

printf "Done!n"
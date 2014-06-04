#!/usr/bin/env bash

function show_options {
  cat <<SHOW_OPTIONS
Options: <inputfile>

Instructions:

  1. Stop ARSnova: $ ./stop.sh
  2. Apply the database you are going to review: $ $0 <inputfile>
  3. Start ARSnova: $ ./start.sh
  4. Verify results
  5. Repeat
  7. Once finished, stop ARSnova: $ ./stop.sh
  6. To clean up, move the file "old.arsnova.properties"
     back to its original location:
     $ sudo mv old.arsnova.properties /etc/arsnova/arsnova.properties
     (or just destroy and recreate this VM)
  7. You may delete all other temp files: $ rm old.*
SHOW_OPTIONS
}

if [ -z "$1" ]
then
  show_options
  exit
fi

INPUT_FILE="$1"
if [ ! -f "$INPUT_FILE" ]
then
  if [ ! -f "/vagrant/$INPUT_FILE" ]
  then
    echo -e "File $INPUT_FILE not found.\n"
    show_options
    exit
  else
    INPUT_FILE="/vagrant/$INPUT_FILE"
  fi
fi

ARS_PROPERTIES="/etc/arsnova/arsnova.properties"
NEW_DB=`date | md5sum | awk '{print $1}' | sed -e 's/^/review_hw0_/'`
OLD_DB=`egrep 'couchdb\.name=(.*)' "$ARS_PROPERTIES" | awk -F '=' '{print $2}'`
OLD_PROPERTIES="old.$OLD_DB.properties"
curl -X PUT "http://localhost:5984/$NEW_DB"
couchdb-load "http://localhost:5984/$NEW_DB" < "$INPUT_FILE"
TMP=`tempfile`
sed 's/^couchdb\.name=.*/couchdb.name='"$NEW_DB"'/' "$ARS_PROPERTIES" > "$TMP"
cp "$ARS_PROPERTIES" "$OLD_PROPERTIES"
sudo mv "$TMP" "$ARS_PROPERTIES"

echo -e "\n"
echo "Database changed. Please restart ARSnova."
echo "Original properties file is saved as $OLD_PROPERTIES."

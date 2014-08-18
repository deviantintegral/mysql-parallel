#!/usr/bin/env bash

USER=$1
DATABASE=$2
HOST=$3
PORT=$4

# Validate our arugments and ensure that GNU parallel is available.
if [[ -z $DATABASE ]]
then
  echo "Usage: mysqldumpp.sh <user> <database> [host] [port]"
  exit 1
fi

if [[ -z $HOST ]]
then
  HOST='localhost'
fi

if [[ -z $PORT ]]
then
  PORT=3306
fi

PARALLEL=`type -P parallel`
if [[ -z $PARALLEL ]]
then
  echo "GNU Parallel is required. Install it from your package manager or from"
  echo "https://savannah.gnu.org/projects/parallel/."
  exit 1
fi

BZIP2=`type -P pbzip2`
if [[ -z $BZIP2 ]]
then
  echo "pbzip2 was not found. Falling back to bzip2. Consider installing pbzip2 for improved"
  echo "performance."
  BZIP2=`type -P bzip2`
fi

echo -n "Please enter your mysql password for $USER: "
read -s PASS
echo ""

# Fetch all of the tables in the database.
if [ -z "$PASS" ]
then
  TABLES=`mysql --batch --skip-column-names -u $USER -h$HOST -P$PORT -e 'SHOW TABLES;' $DATABASE`
else
  TABLES=`mysql --batch --skip-column-names -u $USER --password="$PASS" -h$HOST -P$PORT -e 'SHOW TABLES;' $DATABASE`
fi

if [[ -z $TABLES ]]
then
  echo "Unable to read tables from $DATABASE. Check your connection options"
  exit 1
fi

DATE=`date "+%Y-%m-%d-%H%M"`
DESTINATION="$DATABASE-$DATE"

mkdir -p "$DESTINATION"

# Run one job for each table we are dumping.
if [ -z "$PASS" ]
then
  time echo $TABLES |
  $PARALLEL -d ' ' --trim=rl -I ,  echo "Dumping table ,." \&\& mysqldump -C -u$USER -h$HOST -P$PORT --skip-lock-tables --add-drop-table $DATABASE  , \| $BZIP2 \> $DESTINATION/,.sql.bz2
else
  time echo $TABLES |
  $PARALLEL -d ' ' --trim=rl -I ,  echo "Dumping table ,." \&\& mysqldump -C -u$USER -p"'$PASS'" -h$HOST -P$PORT --skip-lock-tables --add-drop-table $DATABASE  , \| $BZIP2 \> $DESTINATION/,.sql.bz2
fi

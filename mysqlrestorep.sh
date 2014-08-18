#!/usr/bin/env bash

USER=$1
DATABASE=$2
DIRECTORY=$3
HOST=$4
PORT=$5

# Validate our arugments and ensure that GNU parallel is available.
if [[ -z $DIRECTORY ]]
then
  echo "Usage: mysqlrestorep.sh <user> <database> <directory> [host] [port]"
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

BZIP2=`type -P lbzip2`
if [[ -z $BZIP2 ]]
then
  echo "lbzip2 was not found. Falling back to bzip2. Consider installing lbzip2 for improved"
  echo "performance."
  BZIP2=`type -P bzip2`
fi

cd $DIRECTORY

echo -n "Please enter your mysql password for $USER: "
read -s PASS
echo ""

if [ -z "$PASS" ]
then
  time ls -S *.sql.bz2 | $PARALLEL -I, echo "Importing table ,." \&\& $BZIP2 -kcd , \| mysql -u $USER -h$HOST -P$PORT $DATABASE
else
  time ls -S *.sql.bz2 | $PARALLEL -I, echo "Importing table ,." \&\& $BZIP2 -kcd , \| mysql -u $USER -h$HOST -P$PORT -p"'$PASS'" $DATABASE
fi

cd -

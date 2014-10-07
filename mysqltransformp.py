#!/usr/bin/python

import argparse
import bz2
import datetime
import os
import re

def main():
  destination_default = 'mysql-dumps-' + str(datetime.datetime.now().date())
  parser = argparse.ArgumentParser()
  parser.add_argument('sql_dump', help='the SQL file to transform in multiple files')
  parser.add_argument('-d', '--destination', help='name of the folder to be created', default=destination_default)
  arguments = parser.parse_args()
  # If the destionation folder does not exist, then create it.
  if not os.path.exists(arguments.destination):
    os.makedirs(arguments.destination)
  try:
    file_object = open(arguments.sql_dump, 'r')
    sql_buffer = tablename = filename = ''
    # Read the input file line by line.
    for line in file_object:
      # Detect if this is a new table.
      if _is_new_sql_table(line):
        if len(sql_buffer) and len(filename):
          _save_table(sql_buffer, filename)
          print 'Saved: ' + tablename
          sql_buffer = ''
        tablename = _get_tablename(line)
        print 'Detected table: ' + tablename
        filename = arguments.destination + '/' + tablename + '.sql'
      sql_buffer += line
    print 'Saving: ' + filename
    _save_table(sql_buffer, filename)
  finally:
    file_object.close()

def _is_new_sql_table(line):
  return re.search('^-- Table structure for table.*', line) != None

def _get_tablename(line):
  return re.search('^-- Table structure for table `([^ ]*)`.*', line).group(1)

def _save_table(sql_buffer, filename):
  sql_buffer += '--\n'
  file_object = bz2.BZ2File(filename + '.bz2', 'w')
  file_object.write(sql_buffer)
  file_object.close()

if __name__ == '__main__':
  main()

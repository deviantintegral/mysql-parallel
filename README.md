Parallel Scripts for MySQL
==========================

These scripts are used to run MySQL dumps and restores in parallel, with one
job per table. This brings significant performance increases in most dumps and
restores, especially when SSDs are used. By default, jobs will be spawned for
each concurrent thread that the system can run. As well, lbzip2 will be used,
as with bzip2 any dumps or restores where a small number of tables contain the
majority of the data will be blocked by a single bzip2 process on a CPU core.
While this might seem a bit extreme, in practice the OS X scheduler (and
presumably the Linux schedule) handles the large number of processes and
threads just fine.

Warning for Ubuntu Users
========================

By default, Ubuntu sets the ```--tollef``` flag in ```/etc/parallel/config```.
This breaks these scripts in amusing and horrible ways. Remove that line from
the global configuration if you want to use these scripts. See <a href="https://stackoverflow.com/questions/16448887/gnu-parallel-not-working-at-all/16448888#16448888">GNU parallel not working at all</a> for details.

Example
=======

    # Will create a timestamped my_database-TIMESTAMP directory and dump one .sql.bz2 file per table.
    $ ./mysqldumpp.sh root my_database

    # Will restore all of the tables in my_database_directory to the given database.
    $ ./mysqlrestorep.sh root my_database my_database_directory

Contact
=======

This script Built by Robots: https://www.lullabot.com/

Or, file an issue in the GitHub queue, or use my Drupal.org contact form:

- http://drupal.org/user/71291/contact


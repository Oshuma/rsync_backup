#!/bin/bash

function usage {
  echo "Usage: `basename $0`  -d <backup_dir> <dir1, dir2, ...>"
  echo "Example: `basename $0` -d /media/usb_drive/Backups ~/Documents ~/Pictures"
}

declare -r rsync_bin=$(which rsync)
declare -a rsync_opts=(
  --archive
  --compress
  --verbose
)

while getopts "d:" OPTION; do
  case $OPTION in
    d ) destination=$OPTARG ;;
    h ) usage ; exit ;;
    * ) usage ; exit ;;
  esac
done
shift $(($OPTIND - 1))

if [ $# -eq 0 ]; then
  echo "Must name at least one directory or file to backup."
  usage
  exit
fi

if [ ! $destination ]; then
  echo "Must use '-d' to set backup destination."
  usage
  exit
fi
if [ ! -e $destination ]; then
  echo "Destination not found: $destination"
  exit
fi

paths=$@

echo "Backup: $paths"
echo "To:     $destination"
echo -n "Are you sure? (yes/no) "
read answer
if [ $answer != "yes" ]; then
  echo "Aborting."
  exit
fi

# Check the existence of the paths.
for path in $paths; do
  if [ ! -e $path ]; then
    echo -e "\nPath not found: $path"
    echo "Aborting."
    exit
  fi
done

# Run the backup.
for path in $paths; do
  command="${rsync_bin} ${rsync_opts[*]} $path $destination"
  echo "- $command"
  $command
done

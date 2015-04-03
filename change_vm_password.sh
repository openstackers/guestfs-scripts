#!/bin/bash
# Changes a virtual machine password
# Iván Chavero <ichavero@chavero.com.mx>

MOUNTPOINT=/tmp/mnt
FILESYSTEM=/dev/sda1
IMAGE=""
PASSWORD=""

while getopts ":i:m:p:gv" opt; do
  case $opt in
    i)
      IMAGE=$OPTARG
      ;;
    p)
      PASSWORD=$OPTARG
      ;;
    m)
      MOUNTPOINT=$OPTARG
      ;;
    g)
      echo "Guessing which filesystem to mount (this will take a while)"
      FILESYSTEM=$(guestfish --rw -a /space/images/centos-6-cloud -i  list-filesystems | cut -d ':' -f 1)
     ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage: -i <image> -p <password>  [-m <temporary mount point>] [-g guess filesystem to mount (takes a while)]"
      ;;
  esac
done

if [ "${IMAGE}" == "" ]; then
  echo "Missing argument -i <image>"
  exit
fi

if [ "${PASSWORD}" == "" ]; then
  echo "Missing argument -p <password>"
  exit
fi


mkdir $MOUNTPOINT
ENC_PASS=$(openssl passwd -1 $PASSWORD)
echo "PASS: $ENC_PASS"
guestmount -a $IMAGE -m $FILESYSTEM --rw $MOUNTPOINT
sed -i -e "s/root:\!\!/root:$ENC_PASS/" $MOUNTPOINT/etc/shadow
guestunmount $MOUNTPOINT
rmdir $MOUNTPOINT


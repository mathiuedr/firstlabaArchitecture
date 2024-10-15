path=$1
limit=$2
tmpfile=`mktemp tmp.XXXXXXXXXXXXXXXXXXX`
dd if=/dev/zero of=$tmpfile bs=$limit count=1
mkfs -t ext4 -F $tmpfile
mkdir -p $path
sudo mount -o loop $tmpfile $path

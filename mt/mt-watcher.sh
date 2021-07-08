#!/bin/sh

if test -z "$ENABLE_MT_WATCHER"; then
    echo 'Set the $ENABLE_MT_WATCHER environment variable to enable file system monitoring.'
    exit
fi

# wait for `make me` to complete
sleep 5

inotifywait -mr \
    --exclude support \
    -e modify -e close_write -e move -e create -e delete \
    *.cgi addons alt-tmpl default_templates extlib lib \
    php plugins search_templates themes tmpl tools mt-static | \
while read line; do
    echo $line
    docker kill -s HUP mt_mt_1
done

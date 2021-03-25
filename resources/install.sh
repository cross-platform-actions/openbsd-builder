#!/bin/sh

set -exu

sed -i'' "s/{{ SECONDARY_USER_USERNAME }}/$SECONDARY_USER_USERNAME/" /install.conf
sed -i'' "s/{{ SECONDARY_USER_PASSWORD }}/$SECONDARY_USER_PASSWORD/" /install.conf
sed -i'' "s/{{ ROOT_PASSWORD }}/$ROOT_PASSWORD/" /install.conf

# Use # instead of / because the URL to the templates contains /
sed -i'' "s#{{ DISKLABEL_TEMPLATE }}#$DISKLABEL_TEMPLATE#" /install.conf

# Always use the first line of ftplist.cgi for the default answer of "HTTP Server?".
# This is a workaround for the change introduced in the following commit:
# https://github.com/openbsd/src/commit/bf983825822b119e4047eb99486f18c58351f347
sed -i'' 's/\[\[ -z $_l \]\] && //' /install.sub
/install -a -f /install.conf

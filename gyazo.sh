#!/bin/sh
#
# Copyright (c) 2018 YASUOKA Masahiko <yasuoka@yasuoka.net>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

UPLOAD=https://upload.gyazo.com/upload.cgi
IDFILE=$HOME/.gyazo.id

TMP=
abort() {
	[ -n "$TMP" ] && rm -f $TMP
	exit 1
}
usage() {
	echo "usage: ${0##*/} [image file]" >&2
}

while getopts "" ch "$@"; do
	case $ch in
	*)	usage
		exit 64;;
	esac
done
shift $((OPTIND - 1))

trap abort 1 2

if ! which import > /dev/null 2>&1; then
	echo "Require \"import\" (ImageMagick) installed"
	exit 1
fi
if ! which convert > /dev/null 2>&1; then
	echo "Require \"convert\" (ImageMagick) installed"
	exit 1
fi
if ! which curl > /dev/null 2>&1; then
	echo "Require \"curl\" installed"
	exit 1
fi
XCLIP=xclip
if ! which xclip > /dev/null 2>&1; then
	XCLIP=:
fi

if [ $# -gt 0 ]; then
	case $1 in
	*.png)	_img=$1;;
	*)	_img=$(mktemp -t ".$(echo ${0##*/} | tr '.' '_')XXXXXXX")
		TMP="$TMP $_img"
		convert $1 png:$_img || abort
	esac
else
	_img=$(mktemp -t ".$(echo ${0##*/} | tr '.' '_')XXXXXXX")
	TMP="$TMP $_img"
	import png:$_img || abort
fi

CURLOPTS="-H \"User-Agent: Gyazo/1.0\""
ID=$(cat $IDFILE 2>/dev/null)
if [ -n "$ID" ]; then
	URL=$(curl $CURLOPTS -s -X POST -F "id=$ID" -F "imagedata=@$_img" \
	    "$UPLOAD")
else
	_header_file=$(mktemp -t ".$(echo ${0##*/} | tr '.' '_')XXXXXXXX")
	TMP="$TMP $_header_file"
	URL=$(curl $CURLOPTS -D $_header_file -s -X POST -F "imagedata=@$_img" \
	    "$UPLOAD")
	sed -n '/^X-Gyazo-Id: /s///p' $_header_file > $IDFILE
fi
echo $URL
echo $URL | $XCLIP
[ -n "$TMP" ] && rm -f $TMP

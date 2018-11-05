gyazo command
=============

``gyazo`` is a small command line client for [gyazo](https://gyazo.com).

Prerequisites
-------------

- curl
- ImageMagick is installed and "import" command is working
- xclip (optional)
  - if the script finds the xclip, the image URL is copied to the X11
    clipboard


Install
-------

    $ doas install -c -m 0555 gyazo.sh /usr/local/bin/gyazo


Usage
-----

    usage: gyazo [image file]

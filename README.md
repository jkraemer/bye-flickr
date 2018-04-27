Bye, Flickr!
============

Simple app to download everything from your flickr account. Your photos will be
put into a directory structure reflecting Flickr collections and sets. Metadata
for collections, sets and photos will be stored as JSON files, as well as
contacts and groups data.

Installation
------------

You need Ruby. I used it with Ruby 2.5, 2.4 should be ok as well. Install the
gem, run `bye-flickr -h` for usage info.

~~~~

$ gem install bye-flickr
Successfully installed bye-flickr-0.1.0
1 gem installed

$ bye-flickr -h
usage: /home/jk/.gem/ruby/2.5.1/bin/bye-flickr [options]
Required arguments (create API key and secret in the Flickr web interface):
    -d, --dir     directory to store data
    -k, --key     API key
    -s, --secret  API secret

Optional arguments, if you already have authorized the app:
    --at          Access token
    --as          Access token secret

Other commands:
    --version     print the version
    -h, --help

~~~~

Usage
-----

First of all, head to your [Flickr
account](https://www.flickr.com/services/apps/create/apply/) and create an API
key. Choose non-commercial and pick any name you like for your 'App'. In the
end you will get a key and a secret which are what you need for the `-k` and
`-s` options. Pick a directory in a location with enough disk space and there you go:

~~~~

$ bye-flickr -d /space/photos -k lengthyAPIkey -s notsolongsecret
token_rejected
Open this url in your browser to complete the authentication process:
https://api.flickr.com/services/oauth/authorize?oauth_token=some-token&perms=read
Copy here the number given when you complete the process.

~~~~

Do as you're told and go to the URL, authorize the app, copy/paste the nine
digit number and hit Enter.

~~~~
179-386-583
You are now authenticated as flickrUserName with token some-other-token and secret yetanothersecret.
~~~~

For subsequent runs you can take note of the access token and secret you just
got and use them as values for the `--at` and `--as` command line options. This
will save you from having to authorize the app through the web interface over
and over again.

To show it's working the app prints out a `.` for every photo downloaded, and
also prints the name of the directory (collection/set) it's currently working
on. Photos not belonging to any set are, surprise, put into a directory named
`not in any set`.

Depending on the size of your Flickr account and your bandwidth this may take a
long time. Downloading 26GB from my personal account took a couple of hours on
my Hetzner server.


Caveats
-------

I built this because I wanted to download my photos, so naturally I cut some
corners where I could. Two things that I'm aware of which might need improvement are:

- Support Flickr's pagination. If you have sets with more than 500 photos in it
  (or more than 500 Photos that are not in any set) you will need that because
  500 is the maximum number of photos you can get with a single API request. My
  sets aren't that large so I skipped this.
- There is no support for resuming an unfinished download, the app always
  starts from scratch.

Pull Requests welcome :)


License
-------

MIT. See LICENSE for the text.



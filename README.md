docker-mopidy
=============

Containerized **[Mopidy](https://www.mopidy.com/)** music server with support for [MPD clients](https://docs.mopidy.com/en/latest/clients/mpd/) and [HTTP clients](https://docs.mopidy.com/en/latest/ext/web/#ext-web).


Features
--------

  * Follows [official installation](https://docs.mopidy.com/en/latest/installation/debian/) on top of [Debian](https://registry.hub.docker.com/_/debian/).
  * With backend extensions for:
      * [Mopidy-Spotify](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-spotify) for **[Spotify](https://www.spotify.com/us/)** (Premium)
      * [Mopidy-GMusic](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-gmusic) for **[Google Play Music](https://play.google.com/music/listen)**
      * [Mopidy-SoundClound](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-soundcloud) for **[SoundCloud](https://soundcloud.com/stream)**
      * [Mopidy-YouTube](https://docs.mopidy.com/en/latest/ext/backends/#mopidy-youtube) for **[YouTube](https://www.youtube.com)**
  * With [Mopidy-Moped](https://docs.mopidy.com/en/latest/ext/web/#mopidy-moped) web extension.
  * Runs as `mopidy` user inside the container.

You may install additional [backend extensions](https://docs.mopidy.com/en/latest/ext/backends/).


Usage
-----

General usage (see [mopidy commands](https://docs.mopidy.com/en/latest/command/)):

    $ docker run -d \
          -v /dev/snd:/dev/snd --lxc-conf='lxc.cgroup.devices.allow = c 116:* rwm' \
          -v $PWD/media:/var/lib/mopidy/media:ro \
          -v $PWD/local:/var/lib/mopidy/local \
          -p 6600:6600 -p 6680:6680 \
          wernight/mopidy \
          -o spotify/username=USERNAME -o spotify/password=PASSWORD \
          -o gmusic/username=USERNAME -o gmusic/password=PASSWORD \
          -o soundcloud/auth_token=TOKEN

Replace `USERNAME`, `PASSWORD`, `TOKEN` accordingly:

  * For *Spotify* you'll need a *Premium* account.
  * For *Google Music* use your Google account (if you have *2-Step Authentication*, generate an [app specific password](https://security.google.com/settings/security/apppasswords)).
  * For *SoundCloud*, just [get a token](https://www.mopidy.com/authenticate/) after registering.

Ports:

  * 6600 - MPD server
  * 6680 - HTTP server

Volumes:

  * `/var/lib/mopidy/media` - Path to directory with local media files (optional).
  * `/var/lib/mopidy/local` - Path to directory to store local metadata such as libraries and playlists in (optional).
  * `/dev/snd` - Used to share ALSA socket and play audio.

### Example using HTTP client to stream local files

 1. Give read access to your audio files to user 102 (`mopidy`), group 29 (`audio`), or all users (e.g., `$ chgrp -R 29 $PWD/media && chmod -R g+r $PWD/media`).
 2. Index local files:

        $ docker run --rm -v $PWD/media:/var/lib/mopidy/media:ro -v $PWD/local:/var/lib/mopidy/local -p 6800:6800 wernight/mopidy local scan
 3. Start the server:

        $ docker run -d -v $PWD/media:/var/lib/mopidy/media:ro -v $PWD/local:/var/lib/mopidy/local -p 6800:6800 wernight/mopidy

 4. Browse to http://localhost:6800/

### Example using [ncmpcpp](https://docs.mopidy.com/en/latest/clients/mpd/#ncmpcpp) MPD console client

    $ docker run --name mopidy -d wernight/mopidy
    $ docker run --rm -it --link mopidy:mopidy wernight/ncmpcpp --host mopidy


Feedbacks
---------

Having more issues? [Report a bug on GitHub](https://github.com/wernight/docker-mopidy/issues).

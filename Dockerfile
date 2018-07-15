FROM debian:jessie

MAINTAINER Werner Beroux <werner@beroux.com>

# Official Mopidy install for Debian/Ubuntu along with some extensions
# (see https://docs.mopidy.com/en/latest/installation/debian/ )
ADD https://apt.mopidy.com/mopidy.gpg /tmp/mopidy.gpg
ADD https://apt.mopidy.com/mopidy.list /etc/apt/sources.list.d/mopidy.list

RUN apt-key add /tmp/mopidy.gpg

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    mopidy \
    mopidy-soundcloud \
    mopidy-spotify \
    gstreamer0.10-alsa

# Install more extensions via PIP.
ADD https://bootstrap.pypa.io/get-pip.py /tmp/get-pip.py
RUN python /tmp/get-pip.py
RUN pip install -U six
RUN pip install \
    requests==2.19.1 \
    cryptography==2.2.2 \
    pyopenssl==18.0.0 \
    Mopidy-Moped \
    Mopidy-GMusic \
    Mopidy-Pandora

# Clean-up to save some space
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default configuration
ADD mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf
RUN chown mopidy:audio -R /var/lib/mopidy/.config

# Start helper script
ADD mopidy.sh /mopidy.sh
RUN chown mopidy:audio /mopidy.sh

# Run as mopidy user
USER mopidy

VOLUME /var/lib/mopidy/local
VOLUME /var/lib/mopidy/media

EXPOSE 6600
EXPOSE 6680
EXPOSE 5555/udp

ENTRYPOINT ["/mopidy.sh"]
CMD ["/usr/bin/mopidy"]


FROM debian:jessie

MAINTAINER Werner Beroux <werner@beroux.com>

# Official Mopidy install for Debian/Ubuntu along with some extensions
# (see https://docs.mopidy.com/en/latest/installation/debian/ )
ADD https://apt.mopidy.com/mopidy.gpg /tmp/mopidy.gpg
ADD https://apt.mopidy.com/mopidy.list /etc/apt/sources.list.d/mopidy.list

RUN apt-key add /tmp/mopidy.gpg

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        mopidy \
        mopidy-soundcloud \
        mopidy-spotify \
        gstreamer0.10-alsa \
        python-crypto \
    && curl -L https://bootstrap.pypa.io/get-pip.py | python - \
    && pip install -U six \
    && pip install \
        Mopidy-Moped \
        Mopidy-GMusic \
        Mopidy-YouTube \
    && apt-get purge --auto-remove -y \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Default configuration
ADD mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf
RUN chown mopidy:audio -R /var/lib/mopidy/.config

# Start helper script
ADD entrypoint.sh /entrypoint.sh
RUN chown mopidy:audio /entrypoint.sh

# Run as mopidy user
USER mopidy

VOLUME /var/lib/mopidy/local
VOLUME /var/lib/mopidy/media

EXPOSE 6600
EXPOSE 6680

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]

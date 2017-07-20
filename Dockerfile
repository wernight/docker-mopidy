FROM debian:stretch-slim

# Default configuration
COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf

# Start helper script
COPY entrypoint.sh /entrypoint.sh

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        gcc \
        gnupg \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python-crypto \
 && curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add - \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
        mopidy-soundcloud \
        mopidy-spotify \
 && curl -L https://bootstrap.pypa.io/get-pip.py | python - \
 && pip install -U six \
 && pip install \
        Mopidy-Moped \
        Mopidy-GMusic \
        Mopidy-YouTube \
        pyasn1==0.1.8 \
    # Install dumb-init
    # https://github.com/Yelp/dumb-init
 && DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")') \
 && curl -Lo /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI" \
 && chmod +x /usr/local/bin/dumb-init \
    # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
        gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
    # Limited access rights.
 && chown mopidy:audio -R /var/lib/mopidy/.config \
 && chown mopidy:audio /entrypoint.sh

# Run as mopidy user
USER mopidy

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680

ENTRYPOINT ["/usr/local/bin/dumb-init", "/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]

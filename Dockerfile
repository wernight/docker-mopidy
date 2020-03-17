FROM debian:buster-slim

&& apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        gcc \
        dumb-init \
        python3 \
        python3-pip \
        python3-dev \
        python3-crypto \
        python3-gst-1.0 \
        build-essential \
        libgstreamer1.0-0 \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-tools \
        gstreamer1.0-alsa \
 && curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add - \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
        mopidy-spotify \
 && pip3 install \
 # List extensions you want to install
        Mopidy-Local \
        Mopidy-Mobile \
        Mopidy-MPD \
        Mopidy-GMusic \
        Mopidy-Pandora \
        Mopidy-YouTube \
        Mopidy-MusicBox-Webclient \
        pyopenssl \
 && mkdir -p /var/lib/mopidy/.config \
 && ln -s /config /var/lib/mopidy/.config/mopidy \
    # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
        gcc \
        build-essential \
        python3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY mopidy.conf /config/mopidy.conf

# Copy the pulse-client configuratrion.
COPY pulse-client.conf /etc/pulse/client.conf

# Allows any user to run mopidy, but runs by default as a randomly generated UID/GID.
ENV HOME=/var/lib/mopidy
RUN set -ex \
 && usermod -G audio,sudo mopidy \
 && chown mopidy:audio -R $HOME /entrypoint.sh \
 && chmod go+rwx -R $HOME /entrypoint.sh

# Runs as mopidy user by default.
USER mopidy

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680 5555/udp

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]

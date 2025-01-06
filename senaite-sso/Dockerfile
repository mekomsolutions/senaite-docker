FROM mekomsolutions/senaite

# Copy Buildout
COPY requirements.txt buildout.cfg develop.cfg $SENAITE_INSTANCE_HOME/

# Copy the build dependencies and startup scripts
COPY build_deps.txt run_deps.txt  /

# Install moreutils and gettext
RUN apt-get update \
    && apt-get install -y --no-install-recommends moreutils gettext \
    && rm -rf /var/lib/apt/lists/*

# Note: we concatenate all commands to avoid multiple layer generation and reduce the image size
RUN apt-get update \
    # Install system packages
    && apt-get install -y --no-install-recommends $(grep -vE "^\s*#" /build_deps.txt | tr "\n" " ") \
    && apt-get install -y --no-install-recommends $(grep -vE "^\s*#" /run_deps.txt | tr "\n" " ") \
    && git clone https://github.com/mekomsolutions/ftw.oidcauth.git $SENAITE_INSTANCE_HOME/src/ftw.oidcauth \
    && cd $SENAITE_INSTANCE_HOME/src/ftw.oidcauth && git checkout custom \
    # Buildout
    && cd $SENAITE_INSTANCE_HOME \
    && pip install -r requirements.txt \
    && buildout \
    && ln -s $SENAITE_FILESTORAGE/ var/filestorage \
    && ln -s $SENAITE_BLOBSTORAGE/ var/blobstorage \
    && chown -R senaite:senaite $SENAITE_HOME $SENAITE_DATA \
    # Cleanup
    && apt-get purge -y --auto-remove $(grep -vE "^\s*#" /build_deps.txt  | tr "\n" " ") \
    && rm -rf /$SENAITE_HOME/buildout-cache \
    && rm -rf /var/lib/apt/lists/*
COPY docker-initialize.py docker-entrypoint.sh /

# Change working directory
WORKDIR $SENAITE_INSTANCE_HOME

# Mount external volume
VOLUME /data

# Expose instance port
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]

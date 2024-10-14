# Use an official Python runtime as a parent image
FROM python:2.7-slim-buster

# Set one or more individual labels
LABEL maintainer="Mekom Solutions"
LABEL email="info@mekomsolutions.com"
LABEL senaite.core.version="v2.5.0"

# Set environment variables
ENV PLONE_MAJOR=5.2 \
  PLONE_VERSION=5.2.14 \
  PLONE_MD5=e8e1f774f069026319be3038631e0734 \
  PLONE_UNIFIED_INSTALLER=Plone-5.2.14-UnifiedInstaller-1.0 \
  SENAITE_HOME=/home/senaite \
  SENAITE_USER=senaite \
  SENAITE_INSTANCE_HOME=/home/senaite/senaitelims \
  SENAITE_DATA=/data \
  SENAITE_FILESTORAGE=/data/filestorage \
  SENAITE_BLOBSTORAGE=/data/blobstorage

# Create the senaite user
RUN useradd --system -m -d $SENAITE_HOME -U -u 500 $SENAITE_USER

# Create directories
RUN mkdir -p $SENAITE_INSTANCE_HOME $SENAITE_FILESTORAGE $SENAITE_BLOBSTORAGE

# Copy Buildout
COPY resources/requirements.txt resources/versions.cfg resources/buildout.cfg resources/develop.cfg $SENAITE_INSTANCE_HOME/

#RUN chown -R senaite:senaite $SENAITE_INSTANCE_HOME $SENAITE_FILESTORAGE $SENAITE_BLOBSTORAGE

# Copy the build dependencies and startup scripts
COPY resources/build_deps.txt resources/run_deps.txt resources/docker-initialize.py resources/docker-entrypoint.sh /

# Note: we concatenate all commands to avoid multiple layer generation and reduce the image size
RUN apt-get update \
  # Install system packages
  && apt-get install -y --no-install-recommends $(grep -vE "^\s*#" /build_deps.txt | tr "\n" " ") \
  && apt-get install -y --no-install-recommends $(grep -vE "^\s*#" /run_deps.txt | tr "\n" " ") \
  # Fetch unified installer
  && wget -O Plone.tgz https://launchpad.net/plone/$PLONE_MAJOR/$PLONE_VERSION/+download/$PLONE_UNIFIED_INSTALLER.tgz \
  && echo "$PLONE_MD5 Plone.tgz" | md5sum -c - \
  && tar -xzf /Plone.tgz \
  && cp -rv $PLONE_UNIFIED_INSTALLER/base_skeleton/* $SENAITE_INSTANCE_HOME \
  && cp -v $PLONE_UNIFIED_INSTALLER/buildout_templates/buildout.cfg $SENAITE_INSTANCE_HOME/buildout-base.cfg \
  && rm -rf $PLONE_UNIFIED_INSTALLER Plone.tgz \
  && git clone  https://github.com/mekomsolutions/plone.initializer.git $SENAITE_INSTANCE_HOME/src/plone.initializer \
  && cd $SENAITE_INSTANCE_HOME/src/plone.initializer && git checkout main \
  && git clone  https://github.com/mekomsolutions/senaite.indexer.git $SENAITE_INSTANCE_HOME/src/senaite.indexer \
  && cd $SENAITE_INSTANCE_HOME/src/senaite.indexer && git checkout main \
  && git clone  https://github.com/mekomsolutions/senaite.monkeypatches.git $SENAITE_INSTANCE_HOME/src/senaite.monkeypatches\
  && cd $SENAITE_INSTANCE_HOME/src/senaite.monkeypatches && git checkout main

# Buildout
RUN cd $SENAITE_INSTANCE_HOME \
  && pip install -r requirements.txt \
  && buildout -c develop.cfg \
  && ln -s $SENAITE_FILESTORAGE/ var/filestorage \
  && ln -s $SENAITE_BLOBSTORAGE/ var/blobstorage \
  && chown -R senaite:senaite $SENAITE_HOME $SENAITE_DATA \
  # Cleanup
  && apt-get purge -y --auto-remove $(grep -vE "^\s*#" /build_deps.txt  | tr "\n" " ") \
  && rm -rf /$SENAITE_HOME/buildout-cache \
  && rm -rf /var/lib/apt/lists/*

# Change working directory
WORKDIR $SENAITE_INSTANCE_HOME

# Mount external volume
VOLUME /data

# Expose instance port
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]

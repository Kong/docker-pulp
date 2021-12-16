# syntax = docker/dockerfile:experimental
FROM fedora:35 as build
ENV PYTHONUNBUFFERED 1

# Install build dependencies
#RUN --mount=type=cache,target=/var/cache/dnf \
RUN dnf install -y \
      curl \
      python3 python3-virtualenv python3-devel \
      createrepo_c-devel \
      cmake \
      make \
      gcc \
      git \
      patch \
      libpq-devel \
      ninja-build \
      cairo-devel \
      libpq-devel \
      rpm-devel \
      file-devel \
      sqlite-devel \
      libxml2-devel \
      zlib-devel \
      expat-devel \
      libmodulemd-devel \
      gobject-introspection-devel \
      cairo-gobject-devel \
      zchunk-devel \
    && dnf clean all

# Create virtualenv
RUN virtualenv -p python3 /opt/pulp

# Ensure uptodate pip and wheel
RUN /opt/pulp/bin/pip install -U \
    pip setuptools wheel

# Install pulp and plugins
COPY requirements.txt /opt/pulp/pulp-requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/pulp/bin/pip install -U -r /opt/pulp/pulp-requirements.txt

# patch pulp in a way that'll remain visible from resulting container
RUN mkdir -p /opt/pulp/kong_patches/
COPY patches/*.patch /opt/pulp/kong_patches/
# hopefully there's just one python 3 site-packages...
RUN for P in /opt/pulp/kong_patches/*; do \
    patch --verbose -p1 -i "$P" \
          -d /opt/pulp/lib/python3.*/site-packages/ \
    ; done

## Main image
FROM fedora:35
ENV PYTHONUNBUFFERED 1
ENV PATH /opt/pulp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV DJANGO_SETTINGS_MODULE="pulpcore.app.settings" \
    PULP_DATABASES__default__ENGINE="django.db.backends.postgresql_psycopg2" \
    PULP_DATABASES__default__NAME="pulp" \
    PULP_DATABASES__default__USER="pulp"

COPY --from=build /opt/pulp /opt/pulp
COPY signing.py /opt/pulp/lib/register-signing-api.py
COPY sign-metadata.sh /opt/pulp/bin/sign-metadata

# TODO: tini should be in newer Dockers already; do we need to install this?
# https://github.com/krallin/tini/#using-tini
# if not; consider a github scheduled action to check release version
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini && \
    useradd --system -m -d /var/lib/pulp -s /sbin/nologin pulp && \
    mkdir -p /var/lib/pulp/tmp && chown pulp /var/lib/pulp/tmp

# TODO: mount=type=bind,from=build,source=/var/cache/dnf,target=/var/cache/dnf,rw
# This won't work due to the "clean all", but removing that needs --squash
RUN --mount=type=cache,target=/var/cache/dnf \
    dnf install -y curl \
      python3 \
      createrepo_c-libs \
      postgresql \
      libpq \
      sqlite \
      libxml2 \
      zlib \
      file-libs \
      libmodulemd \
      gobject-introspection \
      expat \
      zchunk-libs \
    && dnf clean all

WORKDIR /var/lib/pulp
USER pulp

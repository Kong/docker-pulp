FROM opensuse/tumbleweed as build

ENV TZ=Asia/Shanghai \
    # Python
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    # PIP:
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    # Poetry
    POETRY_NO_INTERACTION=1 \ 
    PATH="$PATH:/root/.poetry/bin" 

RUN echo 'Start Init' \
    && zypper install -y \
      wget \
      curl \
      git \
      cmake \
      gcc \
      swig \
      python3 \
      python3-pip \
      python38-pycairo-devel \
      gobject-introspection-devel \
      ghc-postgresql-libpq-devel \
      file-devel \
      libfile1_0 \
      libcreaterepo_c-devel \
      libzck-devel \
      libMagick++-devel \
      libmodulemd-devel \
      doxygen \
    && curl -sSL 'https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py' | python3 \
    && zypper clean

# Project initialization:
WORKDIR /app
COPY pyproject.toml ./
COPY poetry.lock ./
RUN python3 -m venv --copies /app/venv
RUN source /app/venv/bin/activate && poetry install --no-ansi --no-root --no-dev

# Main Image
FROM fedora:32
ENV PYTHONUNBUFFERED 1
ENV PATH /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV DJANGO_SETTINGS_MODULE="pulpcore.app.settings" \
    PULP_DATABASES__default__ENGINE="django.db.backends.postgresql_psycopg2" \
    PULP_DATABASES__default__NAME="pulp" \
    PULP_DATABASES__default__USER="pulp"

COPY --from=build /app/venv /app/venv

RUN dnf install -y curl \
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
      compat-openssl10 \
    && dnf clean all

# ADD TINI
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini 

# ADD Pulp User
RUN useradd --system -m -d /var/lib/pulp -s /sbin/nologin pulp
WORKDIR /var/lib/pulp
USER pulp

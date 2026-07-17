# Reproducible environment for static analysis + the offline test suite.
#
# This is a convenience for contributors who don't want to install the
# Flutter SDK locally; it is NOT required to run `flutter test` (which
# only needs a local Flutter/Dart install - see README "Quick start") and
# is not invoked by CI. It intentionally does not attempt to build an
# Android/iOS release artifact, since that requires signing material this
# repo deliberately does not ship (see fastlane/README.md).
FROM debian:bookworm-slim AS flutter-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# Pin to the stable channel; swap the --branch value for a specific
# release tag if you need bit-for-bit reproducibility.
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter precache \
    && flutter config --no-analytics

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN dart run build_runner build --delete-conflicting-outputs

# Default action: analyze + run the fully offline test suite.
CMD ["sh", "-c", "flutter analyze && flutter test"]

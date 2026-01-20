FROM nextcloud:latest

USER root
RUN apt-get update && apt-get install -y \
    ffmpeg \
    exiftool \
    procps \
&& apt-get clean

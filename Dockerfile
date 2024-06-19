FROM pandoc/extra:3.1.1.0-ubuntu

#RUN apt-get -y update && apt-get install curl unzip -y

ARG TEMPLATES_DIR=/.pandoc/templates

COPY ./doc-build-assets/eisvogel.tex ${TEMPLATES_DIR}/eisvogel.latex

RUN chmod 644 ${TEMPLATES_DIR}/eisvogel.latex

# --- uncomment if fetch font file from web; must use `-L` in curl to obtain font file ---
#WORKDIR /tmp

#RUN curl -Lo SourceHanSans.ttc.zip https://github.com/adobe-fonts/source-han-sans/raw/release/SuperOTC/SourceHanSans.ttc.zip \
#&& unzip SourceHanSans.ttc.zip -d /usr/share/fonts/truetype/SourceHanSans \
#&& rm /tmp/SourceHanSans.ttc.zip \
#&& fc-cache -f -v

WORKDIR /data
# ---


# --- uncomment if load font file from local doc-build-assets directory ---
COPY ./doc-build-assets/SourceHanSans.ttc /usr/share/fonts/truetype/SourceHanSans/SourceHanSans.ttc

RUN chmod 644 /usr/share/fonts/truetype/SourceHanSans/SourceHanSans.ttc \
&& fc-cache -f -v
# ---
FROM pandoc/extra:3.1.1.0-ubuntu

# RUN apt-get -y update && apt-get install curl unzip -y
RUN apt-get -y update

ARG TEMPLATES_DIR=/.pandoc/templates

COPY eisvogel.tex ${TEMPLATES_DIR}/eisvogel.latex

RUN chmod 644 ${TEMPLATES_DIR}/eisvogel.latex

# WORKDIR /tmp

# must use `-L` in curl to obtain font file

# RUN curl -Lo SourceHanSans.ttc.zip https://github.com/adobe-fonts/source-han-sans/raw/release/SuperOTC/SourceHanSans.ttc.zip \
# && unzip SourceHanSans.ttc.zip -d /usr/share/fonts/truetype/SourceHanSans \
# && rm /tmp/SourceHanSans.ttc.zip \
# && fc-cache -f -v

# WORKDIR /data

COPY SourceHanSans.ttc /usr/share/fonts/truetype/SourceHanSans/SourceHanSans.ttc

RUN chmod 644 /usr/share/fonts/truetype/SourceHanSans/SourceHanSans.ttc \
&& fc-cache -f -v

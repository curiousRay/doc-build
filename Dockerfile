FROM pandoc/extra:3.1.1.0-ubuntu

RUN apt-get -y update && apt-get install ttf-wqy-microhei -y

ARG TEMPLATES_DIR=/.pandoc/templates

COPY eisvogel.tex ${TEMPLATES_DIR}/eisvogel.latex

RUN chmod 644 ${TEMPLATES_DIR}/eisvogel.latex
FROM  node:8.9.4

LABEL Maintainer="" \
      Description="ClinFeed User Interface" \
      Vendor="Bioclinica: FLS (Financial Lifecycle Solutions)" \
      Version="0.0.1"

ENV HOME=/home/app
ENV APP_NAME=clinfeedui

# Change directory so that our commands run inside this new directory
WORKDIR $HOME/$APP_NAME

RUN npm config set user 0
RUN npm config set unsafe-perm true

RUN npm install -g @angular/cli@1.7.2 && npm cache verify

# Copy angular application
COPY . .

RUN sed -i -e 's/\r$//' clinfeedui.sh

RUN npm install

COPY BioClinicaRootCA.crt BioclinicaSubordinateCAG2.crt ADFS-SSL-Cert.crt ADFS-Token-decrypting.crt ADFS-Token-Signing.crt /tmp/cert/

RUN mkdir /usr/local/share/ca-certificates/bioclinica && \
    apt-get update && \
    apt-get install -y libnss3-tools && \
    mkdir -p $HOME/.pki/nssdb && \
    certutil -N -d $HOME/.pki/nssdb --empty-password && \
    certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n biorootca -i BioClinicaRootCA.crt && \
    cp -R /tmp/cert/* /usr/local/share/ca-certificates/bioclinica && \
    update-ca-certificates

# Start the app
ENTRYPOINT ["./clinfeedui.sh"]

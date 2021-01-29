FROM gcr.io/cloud-builders/gsutil

COPY increment_buildnumber.sh /bin

RUN chmod +x /bin/increment_buildnumber.sh

ENTRYPOINT ["increment_buildnumber.sh"]
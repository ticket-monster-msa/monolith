FROM httpd:2.4

# For debugging
# RUN apt update && apt install vim -y

# Copy files
COPY ./public-html /usr/local/apache2/htdocs/
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# For debugging
# ENTRYPOINT ["tail"]
# CMD ["-f","/dev/null"]
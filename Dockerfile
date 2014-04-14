FROM runvnc/docker-nimrod-babel
ADD . /opt/authserver
RUN babel install -y https://github.com/runvnc/oicutils.git
RUN babel install -y bcrypt
RUN babel install -y jester
RUN cd /opt/authserver
RUN nimrod c authserver.nim
WORKDIR /opt/authserver
CMD ["/opt/authserver/authserver"]

FROM runvnc/docker-nimrod-babel
ADD . /opt/authserver
RUN babel install -y https://github.com/runvnc/oicutils.git
RUN babel install -y bcrypt
RUN babel install -y jester
RUN cd /opt/authserver
WORKDIR /opt/authserver
RUN nimrod c authserver.nim
CMD ["/opt/authserver/authserver"]

#!/bin/bash
docker run -d --name redis crosbymichael/redis
docker run -d --link redis:redis --name redis_ambassador -p 6379:6379 svendowideit/ambassador
#docker run -d --name redis_ambassador --expose 6379 -e REDIS_PORT_6379_TCP=tcp://127.0.0.1:6379 svendowideit/ambassador
docker run -i -t --link redis_ambassador:redis runvnc/authserver

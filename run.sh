#!/bin/bash
docker run -i -t --link redis_ambassador:redis runvnc/authserver bash

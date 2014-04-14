import auth, jester, strutils, oicutils, marshal, redis, os

var tokenExpires: int
var red:TRedis

post "/auth":
  if auth(@"apikey", @"user"):
    resp "OK"
  else:
    resp "Failed"


post "/newuser":
  if newUser(@"user", @"password"):
    resp "OK"
  else:
    resp "Failed"

post "/checkpassword":
  if checkPassword(@"user", @"password"):
    resp "OK"
  else:
    resp "Failed"

get "/accesstoken":
  ## Check password and if valid generate and store an access token
  ## that expires in X seconds.  If invalid account info then
  ## return nil
  var token = getAccessToken(@"user", @"password", tokenExpires)
  if isNil(token):
    resp "Failed"
  else:
    resp token

get "/verifytoken":
  ## Check if token is valid and not expired
  ## (the key still exists in the db)
  var accessToken = @"token"
  if verifyToken(accessToken):
    resp "OK"
  else:
    resp "Failed"


#get "/user/@user":
#  var usr = getUser(@"user")
#  var outp = 
#  for k, v in usr:   
#  resp $usr

get "/apikey/@user": 
  resp getApiKey(@"user")

post "/userupdate":  
  if userUpdate(@"user", @"key", @"val"):
    resp "OK"
  else:
    resp "Failed"

proc init() =
  dumpEnv()
  var redisHost: string
  var redisPort: string
  var redisInfo = parseDockerHostPort("REDIS_PORT", "localhost", "6379")
  if existsEnv("TOKEN_EXPIRES"):
    tokenExpires = parseInt(getEnv("TOKEN_EXPIRES"))
  else:
    tokenExpires = 60 * 60 * 24
  echo "Trying to connect to redis on host " & redisInfo["host"] & " and port " & redisInfo["port"]
  auth.init(newStringTable({"host": redisInfo["host"], "port":redisInfo["port"]}))

init()
run()

import redis, os, strtabs, sockets, bcrypt, strutils, oicutils


var red:TRedis

proc init*(config:PStringTable) =
  red = redis.open(config["host"], TPort(parseInt(config["port"])))

proc auth*(apikey, user: string):bool =
  var key = red.hGet("user:" & user, "apikey")
  if key == nil:
    return false
  elif key == apikey:
    return true
  else:
    return false

var salt = ""

proc getSalt():string =
  if existsFile("slt"):
    salt = readFile("slt")
  else:
    salt = genSalt(10)
    writeFile("slt", salt)
  return salt

proc newUser*(user, password: string):bool = 
  if user == nil or password == nil:
   return false
  try:
    if red.exists("user:"&user):
      return false
    else:
      var passhash = hash(password, getSalt())
      var apiKey = makeApiKey()
      red.hMSet("user:" & user, [(field:"user", value: user),
                                 (field:"apikey", value: apiKey),
                                 (field:"passhash", value: passhash)])
      return true
  except:
    echo("Exception creating new user")
    return false

proc checkPassword*(user, password:string):bool =
  if not red.exists("user:" & user):
    sleep(50)
    return false
  else:
    var passhash = red.hGet("user:" & user, "passhash")
    return compare(hash(password, getSalt()), passhash)

proc getAccessToken*(user, password:string, expires:int ):string =
  ## Check password and if valid generate and store an access token
  ## that expires in X seconds.  If invalid account info then
  ## return nil
  if checkPassword(user, password):
    var token = "access:" & uid()
    red.setk(token, "y")
    discard red.expire(token, expires)
    var tokenLen = token.len
    var str = token[7..tokenLen-1]
    str = str.strip()
    return str
  else:
    return nil

proc verifyToken*(accessToken:string):bool =
  echo "checking for existing key " & accessToken
  if red.exists("access:"&accessToken):
    return true
  else:
    return false


proc getUser*(user:string):PStringTable =
  return red.hGetAllTable("user:"&user)

proc getApiKey*(user:string):string =
  return red.hGet("user:"&user, "apikey")

proc userUpdate*(user, key, val: string):bool =
  if user == nil or key == nil:
    return false
  if not red.exists("user:"&user):
    return false
  else:          
    red.hMSet("user:" & user, [(field:"user", value: user),
                               (field:key, value: val)])
    return true

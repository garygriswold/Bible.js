import httplib

PROD_HOST = "dbt.io"
DEBUG_HOST = "api.bible.build"

LANG_DEBUG_V2 = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&format=json&pretty=true"
LANG_DEBUG_V4 = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=2&format=json&pretty=true"
LANG_PROD_V4 = "/library/language?key=b37964021bdd346dc602421846bf5683&v=4&pretty=true"

conn = httplib.HTTPSConnection(PROD_HOST)
conn.request("GET", LANG_PROD_V4)
resp = conn.getresponse()
data = resp.read()
print data
conn.close()
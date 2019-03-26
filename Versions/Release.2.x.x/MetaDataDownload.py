import httplib

PROD_HOST = "dbt.io"
DEBUG_HOST = "api.bible.build"

LANG_DEBUG_V4 = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&format=json&pretty=true"
LANG_DEBUG_V2 = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=2&format=json&pretty=true"
LANG_PROD_V4 = "/library/language?key=b37964021bdd346dc602421846bf5683&v=4&format=json&pretty=true"

LANG_DEBUG_V4_ENG = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&iso=eng&I10n=spa&format=json&pretty=true"
LANG_DEBUG_V4_CSV = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&iso=eng&format=csv"
LANG_DEBUG_V4_ALT = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&iso=eng&format=json&pretty=true&include_alt_names=true"
LANG_DEBUG_V4_I10N = "/languages?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&iso=eng&format=json&pretty=true&I10N=it"

BIBLE_DEBUG_V4_ENG = "/bibles?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&language=eng&format=json&pretty=true"
BIBLE_DEBUG_V4 = "/bibles?key=afcb0adb-5247-4327-832d-abeb316358f9&v=4&format=json&pretty=true"


#VERSION_DEBUG_V2 =
#VERSION_DEBUT_V4 =
#VERSION_PROD_V4 = 

conn = httplib.HTTPSConnection(DEBUG_HOST)
conn.request("GET", BIBLE_DEBUG_V4_ENG)
resp = conn.getresponse()
data = resp.read()
print data
conn.close()

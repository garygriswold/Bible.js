PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Translation;
DROP TABLE IF EXISTS StoreVersion;
DROP TABLE IF EXISTS CountryVersion;
DROP TABLE IF EXISTS Version;
DROP TABLE IF EXISTS Owner;
DROP TABLE IF EXISTS Language;
DROP TABLE IF EXISTS Country;


CREATE TABLE Country (
countryCode TEXT NOT NULL PRIMARY KEY,
primLanguage TEXT NOT NULL,
englishName TEXT NOT NULL,
localCountryName TEXT NOT NULL
);
INSERT INTO Country VALUES ('WORLD', 'en', 'World', 'World');
-- INSERT INTO Country VALUES ('US', 'en', 'United States', 'United States');
-- INSERT INTO Country VALUES ('MX', 'es', 'Mexico', 'Méjico');


CREATE TABLE Language (
silCode TEXT PRIMARY KEY NOT NULL,
langCode TEXT NOT NULL,
direction TEXT NOT NULL CHECK(direction IN('ltr', 'rtl')),
englishName TEXT NOT NULL,
localLanguageName TEXT NOT NULL
);
INSERT INTO Language VALUES ('eng', 'en', 'ltr', 'English', 'English');
INSERT INTO Language VALUES ('spa', 'es', 'ltr', 'Spanish', 'Español');
INSERT INTO Language VALUES ('arb', 'ar', 'rtl', 'Arabic', 'العربية');
INSERT INTO Language VALUES ('cnm', 'zh', 'ltr', 'Chinese', '汉语, 漢語');
INSERT INTO Language VALUES ('amu', 'es', 'ltr', 'Amuzgo, Guerrero', 'Amuzgo, Guerrero');
INSERT INTO Language VALUES ('azg', 'es', 'ltr', 'Amuzgo, San Pedro Amuzgos', 'Amuzgo, San Pedro Amuzgos');


CREATE TABLE Owner (
ownerCode TEXT PRIMARY KEY NOT NULL,
englishName TEXT NOT NULL,
localOwnerName TEXT NOT NULL,
ownerURL TEXT NOT NULL
);
INSERT INTO Owner VALUES ('WBT', 'Wycliffe Bible Translators', 'Wycliffe Bible Translators', 'www.wycliffe.org');
INSERT INTO Owner VALUES ('SPN', 'Bible Society of Spain', 'Sociedad Bíblica de España', 'www.unitedbiblesocieties.org/society/bible-society-of-spain/');
INSERT INTO Owner VALUES ('EBIBLE', 'eBible.org', 'eBible.org', 'www.ebible.org');
INSERT INTO Owner VALUES ('CRSWY', 'Crossway', 'Crossway', 'www.crossway.org');
INSERT INTO Owner VALUES ('ABS', 'American Bible Society', 'American Bible Society', 'www.americanbible.org/');


CREATE TABLE Version (
versionCode TEXT NOT NULL PRIMARY KEY,
silCode TEXT NOT NULL REFERENCES Language(silCode),
ownerCode TEXT NOT NULL REFERENCES Owner(ownerCode),
versionAbbr TEXT NOT NULL,
localVersionName TEXT NOT NULL,
scope TEXT NOT NULL CHECK (scope IN('BIBLE','BIBLE_NT','BIBLE_PNT')),
filename TEXT UNIQUE,
isQaActive TEXT CHECK (isQaActive IN('T','F')),
copyright TEXT NULL,
introduction TEXT
);
-- English
INSERT INTO Version VALUES ('CEVUS06', 'eng', 'ABS', 'CEV', 'Contemporary English Version', 'BIBLE', 'CEVUS06.db', 'F', 
'Contemporary English Version® © 1995 American Bible Society. All rights reserved.', NULL);
INSERT INTO Version VALUES ('ESV', 'eng', 'CRSWY', 'ESV', 'English Standard Version', 'BIBLE', 'ESV.db', 'F', 
'English Standard Version®, copyright © 2001 by Crossway Bibles, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.', NULL);
INSERT INTO Version VALUES ('GNTD', 'eng', 'ABS', 'GN', 'Good News', 'BIBLE', 'GNTD.db', 'F', 
'Good News Translation® (Today’s English Version, Second Edition) © 1992 American Bible Society. All rights reserved.  Bible text from the Good News Translation (GNT) is not to be reproduced in copies or otherwise by any means except as permitted in writing by American Bible Society, 1865 Broadway, New York, NY 10023.', NULL);
INSERT INTO Version VALUES ('KJVA', 'eng', 'ABS', 'KJV', 'King James Version, American Edition', 'BIBLE', 'KJVA.db', 'F', 
'King James Version 1611, spelling, punctuation and text formatting modernized by ABS in 1962; typesetting © 2010 American Bible Society.', NULL);
INSERT INTO Version VALUES ('KJVPD', 'eng', 'EBIBLE', 'KJV', 'King James Version', 'BIBLE', 'KJVPD.db', 'F', 
'King James Version 1611 (KJV), Public Domain, eBible.org.', NULL);
INSERT INTO Version VALUES ('WEB', 'eng', 'EBIBLE', 'WEB', 'World English Bible', 'BIBLE', 'WEB.db', 'F', 
'World English Bible (WEB), Public Domain, eBible.org.', NULL);

-- Spanish
INSERT INTO Version VALUES ('RVR09PD', 'spa', 'EBIBLE', 'RVR1909', 'Santa Biblia — Reina Valera 1909', 'BIBLE', 'RVR09PD.db', 'F', 
'Santa Biblia — Reina Valera 1909 (RVR1909), Public Domain, eBible.org', NULL);
INSERT INTO Version VALUES ('BLP', 'spa', 'SPN', 'BLP', 'La Palabra (versión española)', 'BIBLE', 'BLP.db', 'F', 
'La Palabra (BLP) versión española Copyright © Sociedad Bíblica de España, 2010 Utilizada con permiso', NULL);
INSERT INTO Version VALUES ('BLPH', 'spa', 'SPN', 'BLPH', 'La Palabra (versión hispanoamericana)','BIBLE', 'BLPH.db', 'F', 
'La Palabra (BLPH) versión hispanoamericana Copyright © Sociedad Bíblica de España, 2010 Utilizada con permiso', NULL);

-- Arabic
INSERT INTO Version VALUES ('ARVDVPD', 'arb', 'EBIBLE', 'ARVDV', 'فان دايك الكتاب المقدس باللغة العربية', 'BIBLE', 'ARVDVPD.db', 'F',
'Van Dyck Arabic Version (ARVDV), Public Domain, eBible.org.', NULL);

INSERT INTO Version Values ('amu', 'amu', 'WBT', 'AMU', 'Amuzgo, Guerrero', 'BIBLE_NT', 'AMU.db', 'F', 
'Amuzgo, Guerrero, © 1999 by Wycliffe Bible Translators', NULL);
INSERT INTO Version Values ('azg', 'azg', 'WBT', 'AZG', 'Amuzgo, San Pedro Amuzgos', 'BIBLE_NT', 'AZG.db', 'F', 
'Amuzgo, San Pedro Amuzgos, © 1992 by Wycliffe Bible Translators', NULL);



CREATE TABLE CountryVersion (
countryCode TEXT REFERENCES Country(countryCode),
versionCode TEXT REFERENCES Version(versionCode),
PRIMARY KEY(countryCode, versionCode)
);
INSERT INTO CountryVersion VALUES ('WORLD', 'WEB');
INSERT INTO CountryVersion VALUES ('WORLD', 'KJVPD');
INSERT INTO CountryVersion VALUES ('WORLD', 'RVR09PD');
INSERT INTO CountryVersion VALUES ('WORLD', 'ARVDVPD');
-- INSERT INTO CountryVersion VALUES ('WORLD', 'GNTD');
-- INSERT INTO CountryVersion VALUES ('WORLD', 'ESV');
-- INSERT INTO CountryVersion VALUES ('US', 'CEVUS06');
-- INSERT INTO CountryVersion VALUES ('US', 'KJVA');
-- INSERT INTO CountryVersion VALUES ('MX', 'BLPH');
-- INSERT INTO CountryVersion VALUES ('MX', 'BLP');
-- INSERT INTO CountryVersion VALUES ('MX', 'amu');
-- INSERT INTO CountryVersion VALUES ('MX', 'azg');


CREATE TABLE StoreVersion (
storeLocale TEXT NOT NULL,	
versionCode NOT NULL REFERENCES Version(versionCode),
defaultVersion NOT NULL CHECK(defaultVersion IN('T', 'F')),
startDate NOT NULL,
endDate NULL,
PRIMARY KEY (storeLocale, versionCode)
);
INSERT INTO StoreVersion VALUES ('en', 'WEB', 'T', '2016-05-16', null);
INSERT INTO StoreVersion VALUES ('en', 'KJVPD', 'F', '2016-05-16', null);
INSERT INTO StoreVersion VALUES ('es', 'RVR09PD', 'T', '2016-05-31', null);
INSERT INTO StoreVersion VALUES ('es', 'WEB', 'F', '2016-05-31', null);
INSERT INTO StoreVersion VALUES ('ar', 'ARVDVPD', 'T', '2016-06-01', null);


CREATE TABLE Translation (
source TEXT NOT NULL,
target TEXT NOT NULL,
translated TEXT NOT NULL,
PRIMARY KEY(source, target)
);

INSERT INTO Translation VALUES ('en', 'en', 'English');
INSERT INTO Translation VALUES ('en', 'es', 'Inglés');
INSERT INTO Translation VALUES ('en', 'zh', '英语');
INSERT INTO Translation VALUES ('en', 'ar', 'الإنجليزية');

INSERT INTO Translation VALUES ('es', 'en', 'Spanish');
INSERT INTO Translation VALUES ('es', 'es', 'Español');
INSERT INTO Translation VALUES ('es', 'zh', '西班牙语');
INSERT INTO Translation VALUES ('es', 'ar', 'الأسبانية');

INSERT INTO Translation VALUES ('ar', 'en', 'Arabic');
INSERT INTO Translation VALUES ('ar', 'es', 'Arábica');
INSERT INTO Translation VALUES ('ar', 'zh', '阿拉伯');
INSERT INTO Translation VALUES ('ar', 'ar', 'العربية');

INSERT INTO Translation VALUES ('WORLD', 'en', 'World');
INSERT INTO Translation VALUES ('WORLD', 'es', 'Mundo');
INSERT INTO Translation VALUES ('WORLD', 'zh', '世界');
INSERT INTO Translation VALUES ('WORLD', 'ar', 'العالم');

INSERT INTO Translation VALUES ('US', 'en', 'United States');
INSERT INTO Translation VALUES ('US', 'es', 'Estados Unidos');
INSERT INTO Translation VALUES ('US', 'zh', '美国');
INSERT INTO Translation VALUES ('US', 'ar', 'الولايات المتحدة');

INSERT INTO Translation VALUES ('MX', 'en', 'Mexico');
INSERT INTO Translation VALUES ('MX', 'es', 'Méjico');
INSERT INTO Translation VALUES ('MX', 'zh', '墨西哥');
INSERT INTO Translation VALUES ('MX', 'ar', 'المكسيك');





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
INSERT INTO Country VALUES ('US', 'en', 'United States', 'United States');
INSERT INTO Country VALUES ('MX', 'es', 'Mexico', 'Méjico');


CREATE TABLE Language (
silCode TEXT PRIMARY KEY NOT NULL,
langCode TEXT NOT NULL,
englishName TEXT NOT NULL,
localLanguageName TEXT NOT NULL
);
INSERT INTO Language VALUES ('eng', 'en', 'English', 'English');
INSERT INTO Language VALUES ('spa', 'es', 'Spanish', 'Español');
INSERT INTO Language VALUES ('arb', 'ar', 'Arabic', 'اللغة العربية');
INSERT INTO Language VALUES ('cnm', 'zh', 'Chinese', '汉语, 漢語');


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
scope TEXT NOT NULL CHECK (scope in('BIBLE','BIBLE_NT','BIBLE_PNT')),
filename TEXT UNIQUE,
isQaActive TEXT CHECK (isQaActive IN('T','F')),
copyright TEXT NULL,
introduction TEXT
);
INSERT INTO Version VALUES ('CEVUS06', 'eng', 'ABS', 'CEV', 'Contemporary English Version', 'BIBLE', 'CEVUS06.db', 'F', NULL, NULL);
INSERT INTO Version VALUES ('ESV', 'eng', 'CRSWY', 'ESV', 'English Standard Version', 'BIBLE', 'ESV.db', 'F', NULL, NULL);
INSERT INTO Version VALUES ('GNTD', 'eng', 'ABS', 'GN', 'Good News', 'BIBLE', 'GNTD.db', 'F', NULL, NULL);
INSERT INTO Version VALUES ('KJVA', 'eng', 'ABS', 'KJV', 'King James Version, American Edition', 'BIBLE', 'KJVA.db', 'F', NULL, NULL);
INSERT INTO Version VALUES ('KJVPD', 'eng', 'EBIBLE', 'KJV', 'King James Version', 'BIBLE', 'KJVPD.db', 'F', NULL, NULL);
INSERT INTO Version VALUES ('WEB', 'eng', 'EBIBLE', 'WEB', 'World English Bible', 'BIBLE', 'WEB.db', 'F', NULL, NULL);

UPDATE Version SET copyright = 'Contemporary English Version® © 1995 American Bible Society. All rights reserved.' WHERE versionCode = 'CEVUS06';
UPDATE Version SET copyright = 'English Standard Version®, copyright © 2001 by Crossway Bibles, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.' WHERE versionCode = 'ESV';
UPDATE Version SET copyright = 'Good News Translation® (Today’s English Version, Second Edition) © 1992 American Bible Society. All rights reserved.  Bible text from the Good News Translation (GNT) is not to be reproduced in copies or otherwise by any means except as permitted in writing by American Bible Society, 1865 Broadway, New York, NY 10023.' WHERE versionCode = 'GNTD';
UPDATE Version SET copyright = 'King James Version 1611, spelling, punctuation and text formatting modernized by ABS in 1962; typesetting © 2010 American Bible Society.' WHERE versionCode = 'KJVA';
UPDATE Version SET copyright = 'King James Version 1611 (KJV), Public Domain, eBible.org.' WHERE versionCode = 'KJVPD';
UPDATE Version SET copyright = 'World English Bible (WEB), Public Domain, eBible.org.' WHERE versionCode = 'WEB';

INSERT INTO Version VALUES ('BLP', 'spa', 'SPN', 'BLP', 'La Palabra (versión española)', 'BIBLE', 'BLP.db', 'F', NULL, NULL);
INSERT INTO Version VALUES ('BLPH', 'spa', 'SPN', 'BLPH', 'La Palabra (versión hispanoamericana)','BIBLE', 'BLPH.db', 'F', NULL, NULL);
UPDATE Version SET copyright = 'La Palabra (BLP) versión española Copyright © Sociedad Bíblica de España, 2010 Utilizada con permiso' WHERE versionCode = 'BLP';
UPDATE Version SET copyright = 'La Palabra (BLPH) versión hispanoamericana Copyright © Sociedad Bíblica de España, 2010 Utilizada con permiso' WHERE versionCode = 'BLPH';


CREATE TABLE CountryVersion (
countryCode TEXT REFERENCES Country(countryCode),
versionCode TEXT REFERENCES Version(versionCode),
PRIMARY KEY(countryCode, versionCode)
);
INSERT INTO CountryVersion VALUES ('WORLD', 'WEB');
INSERT INTO CountryVersion VALUES ('WORLD', 'KJVPD');
INSERT INTO CountryVersion VALUES ('WORLD', 'GNTD');
INSERT INTO CountryVersion VALUES ('WORLD', 'ESV');
INSERT INTO CountryVersion VALUES ('US', 'CEVUS06');
INSERT INTO CountryVersion VALUES ('US', 'KJVA');
INSERT INTO CountryVersion VALUES ('MX', 'BLPH');
INSERT INTO CountryVersion VALUES ('MX', 'BLP');


CREATE TABLE StoreVersion (
storeLocale TEXT NOT NULL,	
versionCode NOT NULL REFERENCES Version(versionCode),
startDate NOT NULL,
endDate NULL,
PRIMARY KEY (storeLocale, versionCode)
);
INSERT INTO StoreVersion VALUES ('en', 'WEB', '2016-05-16', null);
INSERT INTO StoreVersion VALUES ('en', 'KJVPD', '2016-05-16', null);


CREATE TABLE Translation (
source TEXT NOT NULL,
target TEXT NOT NULL,
translated TEXT NOT NULL,
PRIMARY KEY(source, target)
);
-- copyright and all rights should be replaced by a complete message
INSERT INTO Translation VALUES ('BIBLE', 'en', 'Bible');
INSERT INTO Translation VALUES ('BIBLE_NT', 'en', 'New Testament');
INSERT INTO Translation VALUES ('BIBLE_PNT', 'en', 'Partial New Testament');
INSERT INTO Translation VALUES ('COPYRIGHT', 'en', 'Copyright');
INSERT INTO Translation VALUES ('ALL_RIGHTS', 'en', 'All Rights Reserved');

INSERT INTO Translation VALUES ('BIBLE', 'es', 'Biblia');
INSERT INTO Translation VALUES ('BIBLE_NT', 'es', 'Nuevo Testamento');
INSERT INTO Translation VALUES ('BIBLE_PNT', 'es', 'Parcial Nuevo Testamento');
INSERT INTO Translation VALUES ('COPYRIGHT', 'es', 'Derechos de autor');
INSERT INTO Translation VALUES ('ALL_RIGHTS', 'es', 'Reservados todos los derechos');

INSERT INTO Translation VALUES ('en', 'en', 'English');
INSERT INTO Translation VALUES ('en', 'es', 'Inglés');
INSERT INTO Translation VALUES ('en', 'zh', '英语');
INSERT INTO Translation VALUES ('en', 'ar', 'الإنجليزية');

INSERT INTO Translation VALUES ('es', 'en', 'Spanish');
INSERT INTO Translation VALUES ('es', 'zh', '西班牙语');
INSERT INTO Translation VALUES ('es', 'es', 'Español');
INSERT INTO Translation VALUES ('es', 'ar', 'الأسبانية');

INSERT INTO Translation VALUES ('ar', 'en', 'what1');
INSERT INTO Translation VALUES ('ar', 'es', 'what2');
INSERT INTO Translation VALUES ('zh', 'ar', 'what3');

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





PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Translation;
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
locale TEXT NOT NULL,
englishName TEXT NOT NULL,
localLanguageName TEXT NOT NULL
);
INSERT INTO Language VALUES ('eng', 'en', 'English', 'English');
INSERT INTO Language VALUES ('spa', 'es', 'Spanish', 'Español');
INSERT INTO Language VALUES ('arb', 'ar', 'Arabic', 'اللغة العربية');
INSERT INTO Language VALUES ('cnm', 'zh', 'Chinese', '汉语, 漢語');


CREATE TABLE Owner (
ownerCode TEXT PRIMARY KEY NOT NULL,
ownerName TEXT NOT NULL,
ownerURL TEXT NOT NULL
);
INSERT INTO Owner VALUES ('WBT', 'Wycliffe Bible Translators', 'www.wycliffe.org');
INSERT INTO Owner VALUES ('SPN', 'Bible Society of Spain', 'www.unitedbiblesocieties.org/society/bible-society-of-spain/');
INSERT INTO Owner VALUES ('EBIBLE', 'eBible.org', 'www.ebible.org');
INSERT INTO Owner VALUES ('CRSWY', 'Crossway', 'https://www.crossway.org');
INSERT INTO Owner VALUES ('ABS', 'American Bible Society', 'http://www.americanbible.org/');


CREATE TABLE Version (
versionCode TEXT NOT NULL PRIMARY KEY,
silCode TEXT NOT NULL REFERENCES Language(silCode),
ownerCode TEXT NOT NULL REFERENCES Owner(ownerCode),
versionAbbr TEXT NOT NULL,
versionName TEXT NOT NULL,
copyright TEXT NOT NULL,
scope TEXT NOT NULL CHECK (scope in('BIBLE','BIBLE_NT','BIBLE_PNT')),
filename TEXT UNIQUE,
isQaActive TEXT CHECK (isQaActive IN('T','F')),
introduction TEXT
);
INSERT INTO Version VALUES ('WEB', 'eng', 'EBIBLE', 'WEB', 'World English Bible', 'PUBLIC', 'BIBLE', 'WEB.db1', 'F', NULL);
INSERT INTO Version VALUES ('GNTD', 'eng', 'ABS', 'GN', 'Good News', '1992', 'BIBLE', 'GNTD.db', 'F', NULL);
INSERT INTO Version VALUES ('ESV', 'eng', 'CRSWY', 'ESV', 'English Standard Version', '2001', 'BIBLE', 'ESV.db', 'F', NULL);
INSERT INTO Version VALUES ('CEVUS06', 'eng', 'ABS', 'CEV', 'Contemporary English Version', '1995', 'BIBLE', 'CEVUS06.db', 'F', NULL);
INSERT INTO Version VALUES ('KJVA', 'eng', 'ABS', 'KJV', 'King James Version', '2010', 'BIBLE', 'KJVA.db', 'F', NULL);
INSERT INTO Version VALUES ('BLPH', 'spa', 'SPN', 'BLPH', 'La Palabra versión hispanoamericana', '2010', 'BIBLE', 'BLPH.db', 'F', NULL);
INSERT INTO Version VALUES ('BLP', 'spa', 'SPN', 'BLP', 'La Palabra', '2010', 'BIBLE', 'BLP.db', 'F', NULL);


CREATE TABLE CountryVersion (
countryCode TEXT REFERENCES Country(countryCode),
versionCode TEXT REFERENCES Version(versionCode),
PRIMARY KEY(countryCode, versionCode)
);
INSERT INTO CountryVersion VALUES ('WORLD', 'WEB');
INSERT INTO CountryVersion VALUES ('WORLD', 'GNTD');
INSERT INTO CountryVersion VALUES ('WORLD', 'ESV');
INSERT INTO CountryVersion VALUES ('WORLD', 'CEVUS06');
INSERT INTO CountryVersion VALUES ('WORLD', 'KJVA');
INSERT INTO CountryVersion VALUES ('WORLD', 'BLPH');
INSERT INTO CountryVersion VALUES ('WORLD', 'BLP');


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





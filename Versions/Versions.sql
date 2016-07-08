PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Translation;
DROP TABLE IF EXISTS InstalledVersion;
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
-- World Languages
INSERT INTO Language VALUES ('arb', 'ar', 'rtl', 'Arabic', 'العربية');
INSERT INTO Language VALUES ('cnm', 'zh', 'ltr', 'Chinese', '汉语, 漢語');
INSERT INTO Language VALUES ('eng', 'en', 'ltr', 'English', 'English');
INSERT INTO Language VALUES ('pes', 'fa', 'rtl', 'Persian', 'فارسی');
INSERT INTO Language VALUES ('spa', 'es', 'ltr', 'Spanish', 'Español');
-- Wycliffe Languages
INSERT INTO Language VALUES ('azg', 'es', 'ltr', 'Amuzgo, San Pedro Amuzgos', 'Amuzgo, San Pedro Amuzgos');
INSERT INTO Language VALUES ('amu', 'es', 'ltr', 'Amuzgo, Guerrero', 'Amuzgo, Guerrero');


CREATE TABLE Owner (
ownerCode TEXT PRIMARY KEY NOT NULL,
englishName TEXT NOT NULL,
localOwnerName TEXT NOT NULL,
ownerURL TEXT NOT NULL
);
INSERT INTO Owner VALUES ('CRSWY', 'Crossway', 'Crossway', 'www.crossway.org');
INSERT INTO Owner VALUES ('EBIBLE', 'eBible.org', 'eBible.org', 'www.ebible.org');
INSERT INTO Owner VALUES ('ELAM', 'Elam Ministries', 'Elam Ministries', 'www.kalameh.com/shop');
INSERT INTO Owner VALUES ('SPN', 'Bible Society of Spain', 'Sociedad Bíblica de España', 'www.unitedbiblesocieties.org/society/bible-society-of-spain/');
INSERT INTO Owner VALUES ('WBT', 'Wycliffe Bible Translators', 'Wycliffe Bible Translators', 'www.wycliffe.org');


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
-- Chinese
INSERT INTO Version VALUES ('CUVSPD', 'cnm', 'EBIBLE', 'CUVS', 'Chinese Union Version (Simplified)', 'BIBLE', 'CUVSPD.db', 'F',
'Chinese Union Version (Simplified), Public Domain, eBible.org.', NULL);
INSERT INTO Version VALUES ('CUVTPD', 'cnm', 'EBIBLE', 'CUVT', 'Chinese Union Version (Traditional)', 'BIBLE', 'CUVTPD.db', 'F',
'Chinese Union Version (Traditional), Public Domain, eBible.org.', NULL);

-- English
INSERT INTO Version VALUES ('WEB_SHORT', 'eng', 'EBIBLE', 'WEB', 'WEB Genesis and Titus for testing', 'BIBLE_PNT', 'WEB_SHORT.db', 'F', '', NULL);
INSERT INTO Version VALUES ('ESV', 'eng', 'CRSWY', 'ESV', 'English Standard Version', 'BIBLE', 'ESV.db', 'F', 
'English Standard Version®, copyright © 2001 by Crossway Bibles, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.', NULL);
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

-- Arabic Languages
INSERT INTO Version VALUES ('ARBVDPD', 'arb', 'EBIBLE', 'ARBVD', 'فان دايك الكتاب المقدس باللغة العربية', 'BIBLE', 'ARBVDPD.db', 'F',
'Arabic Bible: Van Dyck Version (ARBVD), Public Domain, eBible.org', NULL);
INSERT INTO Version VALUES('NMV', 'pes', 'ELAM', 'NMV', 'ترجمۀ هزارۀ نو', 'BIBLE', 'NMV.db', 'F',
'The Persian New Millennium Version © 2014, is a production of Elam Ministries. All rights reserved', null);

-- Wycliffe
INSERT INTO Version Values ('amu', 'amu', 'WBT', 'AMU', 'Amuzgo, Guerrero', 'BIBLE_NT', 'AMU.db', 'F', 
'Amuzgo, Guerrero, © 1999 by Wycliffe Bible Translators', NULL);
INSERT INTO Version Values ('azg', 'azg', 'WBT', 'AZG', 'Amuzgo, San Pedro Amuzgos', 'BIBLE_NT', 'AZG.db', 'F', 
'Amuzgo, San Pedro Amuzgos, © 1992 by Wycliffe Bible Translators', NULL);



CREATE TABLE CountryVersion (
countryCode TEXT REFERENCES Country(countryCode),
versionCode TEXT REFERENCES Version(versionCode),
PRIMARY KEY(countryCode, versionCode)
);
INSERT INTO CountryVersion VALUES ('WORLD', 'ARBVDPD');
-- INSERT INTO CountryVersion VALUES ('WORLD', 'CUVSPD');
-- INSERT INTO CountryVersion VALUES ('WORLD', 'CUVTPD');
INSERT INTO CountryVersion VALUES ('WORLD', 'KJVPD');
INSERT INTO CountryVersion VALUES ('WORLD', 'NMV');
INSERT INTO CountryVersion VALUES ('WORLD', 'WEB');

-- INSERT INTO CountryVersion VALUES ('WORLD', 'RVR09PD');
-- INSERT INTO CountryVersion VALUES ('WORLD', 'ESV');
-- INSERT INTO CountryVersion VALUES ('MX', 'BLPH');
-- INSERT INTO CountryVersion VALUES ('MX', 'BLP');
-- INSERT INTO CountryVersion VALUES ('MX', 'amu');
-- INSERT INTO CountryVersion VALUES ('MX', 'azg');


CREATE TABLE InstalledVersion (
versionCode NOT NULL PRIMARY KEY REFERENCES Version(versionCode),
localeDefault NULL UNIQUE,
startDate NOT NULL,
endDate NULL
);
INSERT INTO InstalledVersion VALUES ('ARBVDPD', 'ar', '2016-06-01', null);
-- INSERT INTO InstalledVersion VALUES ('CUVSPD', 'zh', '2016-06-11', null);
-- INSERT INTO InstalledVersion VALUES ('CUVTPD', null, '2016-06-18', null);
INSERT INTO InstalledVersion VALUES ('KJVPD', null, '2016-05-16', null);
INSERT INTO InstalledVersion VALUES ('NMV', 'fa', '2016-06-27', null);
INSERT INTO InstalledVersion VALUES ('WEB', 'en', '2016-05-16', null);
-- INSERT INTO InstalledVersion VALUES ('RVR09PD', 'es', '2016-05-31', null);



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
INSERT INTO Translation VALUES ('en', 'fa', 'انگلیسی');

INSERT INTO Translation VALUES ('es', 'en', 'Spanish');
INSERT INTO Translation VALUES ('es', 'es', 'Español');
INSERT INTO Translation VALUES ('es', 'zh', '西班牙语');
INSERT INTO Translation VALUES ('es', 'ar', 'الأسبانية');
INSERT INTO Translation VALUES ('es', 'fa', 'اسپانیایی');

INSERT INTO Translation VALUES ('ar', 'en', 'Arabic');
INSERT INTO Translation VALUES ('ar', 'es', 'Arábica');
INSERT INTO Translation VALUES ('ar', 'zh', '阿拉伯');
INSERT INTO Translation VALUES ('ar', 'ar', 'العربية');
INSERT INTO Translation VALUES ('ar', 'fa', 'عربی');

INSERT INTO Translation VALUES ('zh', 'en', 'Chinese');
INSERT INTO Translation VALUES ('zh', 'es', 'Chino');
INSERT INTO Translation VALUES ('zh', 'zh', '中文');
INSERT INTO Translation VALUES ('zh', 'ar', 'الصينية');
INSERT INTO Translation VALUES ('zh', 'fa', 'چینی ها');

INSERT INTO Translation VALUES ('fa', 'en', 'Persian');
INSERT INTO Translation VALUES ('fa', 'es', 'persa');
INSERT INTO Translation VALUES ('fa', 'zh', '波斯语');
INSERT INTO Translation VALUES ('fa', 'ar', 'اللغة الفارسية');
INSERT INTO Translation VALUES ('fa', 'fa', 'فارسی');

INSERT INTO Translation VALUES ('WORLD', 'en', 'World');
INSERT INTO Translation VALUES ('WORLD', 'es', 'Mundo');
INSERT INTO Translation VALUES ('WORLD', 'zh', '世界');
INSERT INTO Translation VALUES ('WORLD', 'ar', 'العالم');
INSERT INTO Translation VALUES ('WORLD', 'fa', 'جهان');

INSERT INTO Translation VALUES ('US', 'en', 'United States');
INSERT INTO Translation VALUES ('US', 'es', 'Estados Unidos');
INSERT INTO Translation VALUES ('US', 'zh', '美国');
INSERT INTO Translation VALUES ('US', 'ar', 'الولايات المتحدة');
INSERT INTO Translation VALUES ('US', 'fa', 'ایالات متحده');

INSERT INTO Translation VALUES ('MX', 'en', 'Mexico');
INSERT INTO Translation VALUES ('MX', 'es', 'Méjico');
INSERT INTO Translation VALUES ('MX', 'zh', '墨西哥');
INSERT INTO Translation VALUES ('MX', 'ar', 'المكسيك');
INSERT INTO Translation VALUES ('MX', 'fa', 'مکزیک');





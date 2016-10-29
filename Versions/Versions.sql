PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Translation;
DROP TABLE IF EXISTS InstalledVersion;
DROP TABLE IF EXISTS DefaultVersion;
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
INSERT INTO Language VALUES ('awa', 'awa', 'ltr', 'Awadhi', ''); -- no tranlation
INSERT INTO Language VALUES ('ben', 'bn', 'ltr', 'Bengali', 'বাঙালি');
INSERT INTO Language VALUES ('bul', 'bg', 'ltr', 'Bulgarian', 'български език');
INSERT INTO Language VALUES ('cmn', 'zh', 'ltr', 'Chinese', '汉语, 漢語');
INSERT INTO Language VALUES ('eng', 'en', 'ltr', 'English', 'English');
INSERT INTO Language VALUES ('hin', 'hi', 'ltr', 'Hindi', 'हिंदी');
INSERT INTO Language VALUES ('hrv', 'hr', 'ltr', 'Croatian', 'hrvatski');
INSERT INTO Language VALUES ('hun', 'hu', 'ltr', 'Hungarian', 'Magyar');
INSERT INTO Language VALUES ('ind', 'id', 'ltr', 'Indonesian', 'Bahasa Indonesia');
INSERT INTO Language VALUES ('kan', 'kn', 'ltr', 'Kannada', 'ಕನ್ನಡ');
INSERT INTO Language VALUES ('mar', 'mr', 'ltr', 'Marathi', 'मराठी');
INSERT INTO Language VALUES ('nep', 'ne', 'ltr', 'Nepali', 'नेपाली');
INSERT INTO Language VALUES ('ori', 'or', 'ltr', 'Oriya', ''); -- no translation
INSERT INTO Language VALUES ('pan', 'pa', 'ltr', 'Punjabi', 'ਪੰਜਾਬੀ ਦੇ');
INSERT INTO Language VALUES ('por', 'pt', 'ltr', 'Portuguese', 'Português');
INSERT INTO Language VALUES ('rus', 'ru', 'ltr', 'Russian', 'русский');
INSERT INTO Language VALUES ('srp', 'sr', 'ltr', 'Serbian', 'Српски');
INSERT INTO Language VALUES ('spa', 'es', 'ltr', 'Spanish', 'Español');
INSERT INTO Language VALUES ('tam', 'ta', 'ltr', 'Tamil', 'தமிழ் மொழி');
INSERT INTO Language VALUES ('tha', 'th', 'ltr', 'Thai', 'ภาษาไทย');
INSERT INTO Language VALUES ('ukr', 'uk', 'ltr', 'Ukrainian', 'українська мова');
INSERT INTO Language VALUES ('vie', 'vi', 'ltr', 'Vietnamese', 'Tiếng Việt');
-- Right to Left Languages
INSERT INTO Language VALUES ('arb', 'ar', 'rtl', 'Arabic', 'العربية');
INSERT INTO Language VALUES ('pes', 'fa', 'rtl', 'Persian', 'فارسی');
INSERT INTO Language VALUES ('urd', 'ur', 'rtl', 'Urdu', 'اردو زبان');


CREATE TABLE Owner (
ownerCode TEXT PRIMARY KEY NOT NULL,
englishName TEXT NOT NULL,
localOwnerName TEXT NOT NULL,
ownerURL TEXT NOT NULL
);
INSERT INTO Owner VALUES ('BLI', 'Bible League International', 'Bible League International', 'www.bibleleague.org');
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
hasHistory TEXT CHECK (hasHistory IN('T','F')),
isQaActive TEXT CHECK (isQaActive IN('T','F')),
versionDate TEXT NOT NULL,
copyright TEXT NULL,
URLSignature TEXT NULL,
introduction TEXT NULL
);
-- America
INSERT INTO Version VALUES ('ERV-ENG', 'eng', 'BLI', 'ERV-ENG', 'Holy Bible: Easy-to-Read Version (ERV), International Edition', 'BIBLE', 'ERV-ENG.db', 'T', 'F', '2016-10-01', 'Holy Bible: Easy-to-Read Version (ERV), International Edition © 2013, 2016 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-POR', 'por', 'BLI', 'ERV-POR', 'Novo Testamento: Versão Fácil de Ler', 'BIBLE_NT', 'ERV-POR.db', 'T', 'F', '2016-10-10',
'Novo Testamento: Versão Fácil de Ler (VFL) © 1999, 2014 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-SPA', 'spa', 'BLI', 'ERV-SPA', 'La Biblia: La Palabra de Dios para todos', 'BIBLE', 'ERV-SPA.db', 'T', 'F', '2016-10-08',
'La Biblia: La Palabra de Dios para todos (PDT) © 2005, 2015 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ESV', 'eng', 'CRSWY', 'ESV', 'English Standard Version', 'BIBLE', 'ESV.db', 'T', 'F', '2020-01-01',
'English Standard Version®, copyright © 2001 by Crossway Bibles, a publishing ministry of Good News Publishers. Used by permission. All rights reserved.', NULL, NULL);
INSERT INTO Version VALUES ('KJVPD', 'eng', 'EBIBLE', 'KJV', 'King James Version', 'BIBLE', 'KJVPD.db', 'T', 'F', '2016-09-06', 
'King James Version 1611 (KJV), Public Domain, eBible.org.', NULL, NULL);
INSERT INTO Version VALUES ('WEB', 'eng', 'EBIBLE', 'WEB', 'World English Bible', 'BIBLE', 'WEB.db', 'T', 'F', '2016-09-06', 
'World English Bible (WEB), Public Domain, eBible.org.', NULL, NULL);
INSERT INTO Version VALUES ('WEB_SHORT', 'eng', 'EBIBLE', 'WEB', 'WEB Genesis and Titus for testing', 'BIBLE_PNT', 'WEB_SHORT.db', 'T', 'F', '2016-09-06',
'', NULL, NULL);

-- East Asia
INSERT INTO Version VALUES ('ERV-CMN', 'cmn', 'BLI', 'ERV-CMN', '圣经–普通话本', 'BIBLE', 'ERV-CMN.db', 'T', 'F', '2016-10-12',
'圣经–普通话本（普通话）© 1999，2015 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-IND', 'ind', 'BLI', 'ERV-IND', 'Perjanjian Baru: Versi Mudah Dibaca', 'BIBLE_NT', 'ERV-IND.db', 'T', 'F', '2016-10-12',
'Perjanjian Baru: Versi Mudah Dibaca (VMD) © 2003 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-NEP', 'nep', 'BLI', 'ERV-NEP', 'Nepali Holy Bible: Easy-to-Read Version', 'BIBLE', 'ERV-NEP.db', 'T', 'F', '2016-10-17',
'Nepali Holy Bible: Easy-to-Read Version (ERV) © 2004 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-THA', 'tha', 'BLI', 'ERV-THA', 'พระ​คริสต​ธรรม​คัมภีร์ ฉบับ​อ่าน​เข้า​ใจ​ง่าย', 'BIBLE', 'ERV-THA.db', 'T', 'F', '2016-10-12',
'พระคริสต​ธรรม​คัมภีร์: ฉบับ​อ่าน​เข้า​ใจ​ง่าย (ขจง) © 2015 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-VIE', 'vie', 'BLI', 'ERV-VIE', 'Thánh Kinh: Bản Phổ thông', 'BIBLE', 'ERV-VIE.db', 'T', 'F', '2016-10-12',
'Thánh Kinh: Bản Phổ thông (BPT) © 2010 Bible League International', NULL, NULL);

-- Middle East
INSERT INTO Version VALUES ('ARBVDPD', 'arb', 'EBIBLE', 'ARBVD', 'الكتاب المقدس ترجمة فان دايك', 'BIBLE', 'ARBVDPD.db', 'F', 'F', '2016-09-06',
'Arabic Bible: Van Dyck Translation (ARBVD), Public Domain, eBible.org', NULL, NULL);
INSERT INTO Version VALUES ('ERV-ARB', 'arb', 'BLI', 'ERV-ARB', 'بِعَهْدَيْهِ القَدِيمِ وَالجَدِيد الكِتَابُ المُقَدَّسُ', 'BIBLE', 'ERV-ARB.db', 'F', 'F', '2016-10',
'الكِتاب المُقَدَّس: التَّرْجَمَةُ العَرَبِيَّةُ المُبَسَّطَةُ (ت ع م) © 2009, 2016 رَابِطَةُ الكِتَابِ المُقَدَّسِ الدَّوْلِيَّة (Bible League International)',
NULL, NULL);
INSERT INTO Version VALUES('NMV', 'pes', 'ELAM', 'NMV', 'ترجمۀ هزارۀ نو', 'BIBLE', 'NMV.db', 'F', 'F', '2016-09-06',
'The Persian New Millennium Version © 2014, is a production of Elam Ministries. All rights reserved', NULL, NULL);

-- India
INSERT INTO Version VALUES ('ERV-AWA', 'awa', 'BLI', 'ERV-AWA', 'पवित्तर बाइबिल, Easy-to-Read Version', 'BIBLE', 'ERV-AWA.db', 'T', 'F', '2016-10-17',
'Awadhi Holy Bible: Easy-to-Read Version (ERV) © 2005 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-BEN', 'ben', 'BLI', 'ERV-BEN', 'পবিত্র বাইবেল, Easy-to-Read Version', 'BIBLE', 'ERV-BEN.db', 'T', 'F', '2016-10-17',
'Bengali Holy Bible: Easy-to-Read Version (ERV) © 2001, 2016 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-HIN', 'hin', 'BLI', 'ERV-HIN', 'पवित्र बाइबल, Easy-to-Read Version', 'BIBLE', 'ERV-HIN.db', 'T', 'F', '2016-10-17',
'Hindi Holy Bible: Easy-to-Read Version (ERV) © 1995 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-KAN', 'kan', 'BLI', 'ERV-KAN', 'Kannada: Easy-to-Read Version', 'BIBLE', 'ERV-KAN.db', 'T', 'F', '2016-10-17',
'Kannada: Easy-to-Read Version (ERV). © 1997 Bible League International.', NULL, NULL);
INSERT INTO Version VALUES ('ERV-MAR', 'mar', 'BLI', 'ERV-MAR', 'Marathi: Easy-to-Read Version', 'BIBLE', 'ERV-MAR.db', 'T', 'F', '2016-10-17',
'Marathi: Easy-to-Read Version (ERV). © 1998 Bible League International.', NULL, NULL);
INSERT INTO Version VALUES ('ERV-ORI', 'ori', 'BLI', 'ERV-ORI', 'ପବିତ୍ର ବାଇବଲ, Easy-to-Read Version', 'BIBLE', 'ERV-ORI.db', 'T', 'F', '2016-10-17',
'Oriya Holy Bible: Easy-to-Read Version (ERV) © 2004 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-PAN', 'pan', 'BLI', 'ERV-PAN', 'Punjabi: Easy-to-Read Version', 'BIBLE', 'ERV-PAN.db', 'T', 'F', '2016-10-17',
'Punjabi: Easy-to-Read Version (ERV). © 2002 Bible League International.', NULL, NULL);
INSERT INTO Version VALUES ('ERV-TAM', 'tam', 'BLI', 'ERV-TAM', 'பரிசுத்த பைபிள், Easy-to-Read Version', 'BIBLE', 'ERV-TAM.db', 'T', 'F', '2016-10-17',
'Tamil Holy Bible: Easy-to-Read Version (ERV) © 1998 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-URD', 'urd', 'BLI', 'ERV-URD', 'Urdu: Easy-to-Read Version', 'BIBLE', 'ERV-URD.db', 'T', 'F', '2016-10-17',
'Urdu: Easy-to-Read Version (ERV). © 2003 Bible League International.', NULL, NULL);

-- Eastern Europe
INSERT INTO Version VALUES ('ERV-BUL', 'bul', 'BLI', 'ERV-BUL', 'Новият завет, съвременен превод', 'BIBLE_NT', 'ERV-BUL.db', 'T', 'F', '2016-10-17',
'Новият завет: съвременен превод (СПБ) © 2000 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-HRV', 'hrv', 'BLI', 'ERV-HRV', 'Novi zavjet, Suvremeni prijevod', 'BIBLE_NT', 'ERV-HRV.db', 'T', 'F', '2016-10-17',
'Novi zavjet: Suvremeni prijevod (SHP) © 2002 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-HUN', 'hun', 'BLI', 'ERV-HUN', 'Biblia Egyszerű fordítás', 'BIBLE', 'ERV-HUN.db', 'T', 'F', '2016-10-17',
'BIBLIA: Egyszerű fordítás (EFO) © 2012 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-RUS', 'rus', 'BLI', 'ERV-RUS', 'Святая Библия Современный перевод', 'BIBLE', 'ERV-RUS.db', 'T', 'F', '2016-10-17',
'Библия: Современный перевод (РСП) © Bible League International, 1993, 2014', NULL, NULL);
INSERT INTO Version VALUES ('ERV-SRP', 'srp', 'BLI', 'ERV-SRP', 'Библија Савремени српски превод', 'BIBLE', 'ERV-SRP.db', 'T', 'F', '2016-10-17',
'Библија: Савремени српски превод (ССП) © 2015 Bible League International', NULL, NULL);
INSERT INTO Version VALUES ('ERV-UKR', 'ukr', 'BLI', 'ERV-UKR', 'Новий Заповіт Сучасною Мовою', 'BIBLE_NT', 'ERV-UKR.db', 'T', 'F', '2016-10-17',
'Новий Заповіт: Сучасною мовою (УСП) © Bible League International, 1996', NULL, NULL);



CREATE TABLE CountryVersion (
countryCode TEXT REFERENCES Country(countryCode),
versionCode TEXT REFERENCES Version(versionCode),
PRIMARY KEY(countryCode, versionCode)
);
INSERT INTO CountryVersion VALUES ('WORLD', 'ARBVDPD');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-AWA');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-ARB');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-BEN');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-BUL');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-CMN');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-ENG');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-HIN');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-HRV');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-HUN');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-IND');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-KAN');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-MAR');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-NEP');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-ORI');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-PAN');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-POR');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-RUS');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-SPA');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-SRP');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-TAM');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-THA');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-UKR');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-URD');
INSERT INTO CountryVersion VALUES ('WORLD', 'ERV-VIE');
INSERT INTO CountryVersion VALUES ('WORLD', 'KJVPD');
INSERT INTO CountryVersion VALUES ('WORLD', 'NMV');
INSERT INTO CountryVersion VALUES ('WORLD', 'WEB');



CREATE TABLE DefaultVersion (
langCode TEXT NOT NULL PRIMARY KEY,
filename TEXT NOT NULL REFERENCES Version(filename)
);
INSERT INTO DefaultVersion VALUES ('ar', 'ARBVDPD.db'); -- Arabic
INSERT INTO DefaultVersion VALUES ('bn', 'ERV-BEN.db'); -- Bengali
INSERT INTO DefaultVersion VALUES ('bg', 'ERV-BUL.db'); -- bulgarian
INSERT INTO DefaultVersion VALUES ('en', 'ERV-ENG.db'); -- English
INSERT INTO DefaultVersion VALUES ('es', 'ERV-SPA.db'); -- Spanish
INSERT INTO DefaultVersion VALUES ('fa', 'NMV.db');     -- Persian
INSERT INTO DefaultVersion VALUES ('hi', 'ERV-HIN.db'); -- Hindi
INSERT INTO DefaultVersion VALUES ('hr', 'ERV-HRV.db'); -- Croatia
INSERT INTO DefaultVersion VALUES ('hu', 'ERV-HUN.db'); -- Hungarian
INSERT INTO DefaultVersion VALUES ('id', 'ERV-IND.db'); -- Indonesian
INSERT INTO DefaultVersion VALUES ('kn', 'ERV-KAN.db'); -- Kannada 
INSERT INTO DefaultVersion VALUES ('mr', 'ERV-MAR.db'); -- Marathi
INSERT INTO DefaultVersion VALUES ('ne', 'ERV-NEP.db'); -- Nepali
INSERT INTO DefaultVersion VALUES ('or', 'ERV-ORI.db'); -- Oriya
INSERT INTO DefaultVersion VALUES ('pt', 'ERV-POR.db'); -- Portuguese
INSERT INTO DefaultVersion VALUES ('pa', 'ERV-PAN.db'); -- Punjabi
INSERT INTO DefaultVersion VALUES ('ru', 'ERV-RUS.db'); -- Russia
INSERT INTO DefaultVersion VALUES ('sr', 'ERV-SRP.db'); -- Serbia
INSERT INTO DefaultVersion VALUES ('ta', 'ERV-TAM.db'); -- Tamil
INSERT INTO DefaultVersion VALUES ('th', 'ERV-THA.db'); -- Thai
INSERT INTO DefaultVersion VALUES ('uk', 'ERV-UKR.db'); -- Ukraine
INSERT INTO DefaultVersion VALUES ('ur', 'ERV-URD.db'); -- Urdu
INSERT INTO DefaultVersion VALUES ('vi', 'ERV-VIE.db'); -- Vietnamese
INSERT INTO DefaultVersion VALUES ('zh', 'ERV-CMN.db'); -- Chinese


CREATE TABLE InstalledVersion (
versionCode NOT NULL PRIMARY KEY REFERENCES Version(versionCode),
startDate NOT NULL,
endDate NULL
);
INSERT INTO InstalledVersion VALUES ('ARBVDPD', '2016-06-01', null);
INSERT INTO InstalledVersion VALUES ('ERV-ENG', '2016-10-14', null);
-- INSERT INTO InstalledVersion VALUES ('ERV-SPA', '2016-10-08', null);
-- INSERT INTO InstalledVersion VALUES ('KJVPD', '2016-05-16', null);
-- INSERT INTO InstalledVersion VALUES ('NMV', '2016-06-27', null);
INSERT INTO InstalledVersion VALUES ('WEB', '2016-05-16', null);
-- INSERT INTO InstalledVersion VALUES ('ERV-PAN', '2016-10-28', null);
-- INSERT INTO InstalledVersion VALUES ('ERV-ORI', '2016-10-28', null);



CREATE TABLE Translation (
source TEXT NOT NULL,
target TEXT NOT NULL,
translated TEXT NOT NULL,
PRIMARY KEY(source, target)
);
-- INSERT INTO Translation VALUES ('en', 'en', 'English');
-- INSERT INTO Translation VALUES ('en', 'es', 'Inglés');
-- INSERT INTO Translation VALUES ('en', 'zh', '英语');
-- INSERT INTO Translation VALUES ('en', 'ar', 'الإنجليزية');
-- INSERT INTO Translation VALUES ('en', 'fa', 'انگلیسی');

-- INSERT INTO Translation VALUES ('es', 'en', 'Spanish');
-- INSERT INTO Translation VALUES ('es', 'es', 'Español');
-- INSERT INTO Translation VALUES ('es', 'zh', '西班牙语');
-- INSERT INTO Translation VALUES ('es', 'ar', 'الأسبانية');
-- INSERT INTO Translation VALUES ('es', 'fa', 'اسپانیایی');

-- INSERT INTO Translation VALUES ('ar', 'en', 'Arabic');
-- INSERT INTO Translation VALUES ('ar', 'es', 'Arábica');
-- INSERT INTO Translation VALUES ('ar', 'zh', '阿拉伯');
-- INSERT INTO Translation VALUES ('ar', 'ar', 'العربية');
-- INSERT INTO Translation VALUES ('ar', 'fa', 'عربی');

-- INSERT INTO Translation VALUES ('zh', 'en', 'Chinese');
-- INSERT INTO Translation VALUES ('zh', 'es', 'Chino');
-- INSERT INTO Translation VALUES ('zh', 'zh', '中文');
-- INSERT INTO Translation VALUES ('zh', 'ar', 'الصينية');
-- INSERT INTO Translation VALUES ('zh', 'fa', 'چینی ها');

-- INSERT INTO Translation VALUES ('fa', 'en', 'Persian');
-- INSERT INTO Translation VALUES ('fa', 'es', 'persa');
-- INSERT INTO Translation VALUES ('fa', 'zh', '波斯语');
-- INSERT INTO Translation VALUES ('fa', 'ar', 'اللغة الفارسية');
-- INSERT INTO Translation VALUES ('fa', 'fa', 'فارسی');

INSERT INTO Translation VALUES ('WORLD', 'en', 'World');
INSERT INTO Translation VALUES ('WORLD', 'es', 'Mundo');
INSERT INTO Translation VALUES ('WORLD', 'zh', '世界');
INSERT INTO Translation VALUES ('WORLD', 'ar', 'العالم');
INSERT INTO Translation VALUES ('WORLD', 'fa', 'جهان');

-- INSERT INTO Translation VALUES ('US', 'en', 'United States');
-- INSERT INTO Translation VALUES ('US', 'es', 'Estados Unidos');
-- INSERT INTO Translation VALUES ('US', 'zh', '美国');
-- INSERT INTO Translation VALUES ('US', 'ar', 'الولايات المتحدة');
-- INSERT INTO Translation VALUES ('US', 'fa', 'ایالات متحده');

-- INSERT INTO Translation VALUES ('MX', 'en', 'Mexico');
-- INSERT INTO Translation VALUES ('MX', 'es', 'Méjico');
-- INSERT INTO Translation VALUES ('MX', 'zh', '墨西哥');
-- INSERT INTO Translation VALUES ('MX', 'ar', 'المكسيك');
-- INSERT INTO Translation VALUES ('MX', 'fa', 'مکزیک');





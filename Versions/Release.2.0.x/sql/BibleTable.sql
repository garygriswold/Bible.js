DROP TABLE IF EXISTS Bible;
CREATE TABLE Bible(
  bibleId TEXT NOT NULL PRIMARY KEY,
  abbr TEXT NOT NULL,
  iso3 TEXT NOT NULL REFERENCES Language(iso3),
  name TEXT NULL,
  englishName TEXT NULL,
  localizedName TEXT NULL,
  textBucket TEXT NULL,
  textId TEXT NULL,
  keyTemplate TEXT NOT NULL,
  audioBucket TEXT NULL,
  otDamId TEXT NULL,
  ntDamId TEXT NULL,
  direction TEXT NULL CHECK (direction IN('ltr','rtl')),
  script TEXT NULL,
  country TEXT NULL REFERENCES Country(code));
CREATE INDEX bible_iso3_idx on Bible(iso3);
INSERT INTO Bible VALUES('ARBERV', 'ERV', 'arb', 'بِعَهْدَيْهِ القَدِيمِ وَالجَدِيد الكِتَابُ المُقَدَّسُ',
'Arabic: Easy-to-Read Bible', null, 'text-%R-shortsands', 'ARBERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'rtl', '', '')
INSERT INTO Bible VALUES('ARBVDV', 'VDV', 'arb', 'الكتاب المقدس ترجمة فان دايك',
'Arabic: Van Dyck Bible', null, 'text-%R-shortsands', 'ARBVDV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'rtl', '', '')
INSERT INTO Bible VALUES('AWAERV', 'ERV', 'awa', 'पवित्तर बाइबिल',
'Awadi: Easy-to-Read Bible' null, 'text-%R-shortsands', 'AWAERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('BENERV', 'ERV', 'ben', 'পবিত্র বাইবেল',
'Bengali: Easy-to-Read Bible' null, 'text-%R-shortsands', 'BENERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('BULERV', 'ERV', 'bul', 'Новият завет, съвременен превод',
'Bulgarian: Easy-to-Read Bible' null, 'text-%R-shortsands', 'BULERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('CMNERV', 'ERV', 'cmn', '圣经–普通话本',
'Chinese: Easy-to-Read Bible' null, 'text-%R-shortsands', 'CMNERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('ENGERU', 'ERV', 'eng', 'Easy to Read Bible',
'English: Easy-to-Read Bible' null, 'text-%R-shortsands', 'ENGERU', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('ENGKJV', 'KJV', 'eng', 'King James Version',
'English: King James Version' null, 'text-%R-shortsands', 'ENGKJV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('ENGWEB', 'WEB', 'eng', 'World English Bible',
'English: World English Bible' null, 'text-%R-shortsands', 'ENGWEB', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('HINERV', 'ERV', 'hin', 'पवित्र बाइबल',
'Hindi: Easy-to-Read Bible' null, 'text-%R-shortsands', 'HINERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('HRVERV', 'ERV', 'hrv', 'Novi zavjet, Suvremeni prijevod',
'Croatian: Easy-to-Read Bible' null, 'text-%R-shortsands', 'HRVERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('HUNERV', 'ERV', 'hun', 'Biblia Egyszerű fordítás',
'Hungarian: Easy-to-Read Bible' null, 'text-%R-shortsands', 'HUNERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('INDERV', 'ERV', 'ind', 'Perjanjian Baru: Versi Mudah Dibaca',
'Indonesian: Easy-to-Read Bible' null, 'text-%R-shortsands', 'INDERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('KANERV', 'ERV', 'kan', null,
'Kannada: Easy-to-Read Bible', null, 'text-%R-shortsands', 'KANERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('MARERV', 'ERV', 'mar', null,
'Marathi: Easy-to-Read Bible', null, 'text-%R-shortsands', 'MARERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('NEPERV', 'ERV', 'nep', null,
'Nepali: Easy-to-Read Bible', null, 'text-%R-shortsands', 'NEPERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('ORIERV', 'ERV', 'ori', 'ପବିତ୍ର ବାଇବଲ',
'Oriya: Easy-to-Read Bible', null, 'text-%R-shortsands', 'ORIERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('PANERV', 'ERV', 'pan', null,
'Punjabi: Easy-to-Read Bible', null, 'text-%R-shortsands', 'PANERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('PESNMV', 'ERV', 'pes', 'ترجمۀ هزارۀ نو',
'Persian: New Millennium Bible', null, 'text-%R-shortsands', 'PESEMV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('PORERV', 'ERV', 'por', 'Novo Testamento: Versão Fácil de Ler',
'Portuguese: Easy-to-Read Bible', null, 'text-%R-shortsands', 'PORERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('RUSWTC', 'ERF', 'rus', 'Святая Библия Современный перевод',
'Russian: Easy-to-Read Bible', null, 'text-%R-shortsands', 'RUSWTC', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('SPAWTC', 'ERV', 'spa', 'La Biblia: La Palabra de Dios para todos',
'Spanish: Easy-to-Read Bible', null, 'text-%R-shortsands', 'SPNWTC', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('SRPERV', 'ERV', 'srp', 'Библија Савремени српски превод',
'Serbian: Easy-to-Read Bible', null, 'text-%R-shortsands', 'SRPERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('TAMERV', 'ERV', 'tam', 'பரிசுத்த பைபிள்',
'Tamil: Easy-to-Read Bible', null, 'text-%R-shortsands', 'TAMERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('THAERV', 'ERV', 'tha', 'พระ​คริสต​ธรรม​คัมภีร์ ฉบับ​อ่าน​เข้า​ใจ​ง่าย',
'Thai: Easy-to-Read Bible', null, 'text-%R-shortsands', 'THAERV', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('UKRBLI', 'ERV', 'ukr', 'Новий Заповіт Сучасною Мовою',
'Ukrainian: Easy-to-Read Bible')'UKRERV', null, 'text-%R-shortsands', 'UKRBLI', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')
INSERT INTO Bible VALUES('URDWTC', 'ERV', 'urd', null,
'Urdu: Easy-to-Read Bible', null, 'text-%R-shortsands', 'URDWTC', '%I_%O_%B_%C.html',
'dbp-prod',  '', '', 'rtl', '', '')
INSERT INTO Bible VALUES('VIEWTC', 'ERV', 'vie', 'Thánh Kinh: Bản Phổ thông',
'Vietnamese" Easy-to-Read Bible', null, 'text-%R-shortsands', 'VIEWTC', '%I_%O_%B_%C.html',
'dbp-prod', '', '', 'ltr', '', '')



#ENGESV|ESV|eng|English Standard Version|English Standard Version|English Standard Version|dbp-prod|ENGESV|%I_%O_%B_%C.html|dbp-prod|ENGESVO2DA|ENGESVN2DA|ltr|Latn|GB
#ENGKJV|KJV|eng|King James Version|King James Version|King James Version|inapp|ENGKJV|%I_%O_%B_%C.html|dbp-prod|ENGKJVO2DA|ENGKJVN2DA|||
#ENGNAB|NAB|eng|New American Bible|New American Bible|New American Bible|dbp-prod|ENGNAB|%I_%O_%B_%C.html|dbp-prod||ENGNABN2DA|ltr|Latn|GB
#ENGWEB|WEB|eng|World English Bible|World English Bible|World English Bible|dbp-prod|ENGWEB|%I_%O_%B_%C.html|dbp-prod|ENGWEBO2DA|ENGWEBN2DA|ltr|Latn|GB
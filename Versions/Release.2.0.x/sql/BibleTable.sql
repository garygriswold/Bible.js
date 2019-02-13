DROP TABLE IF EXISTS Bible;
CREATE TABLE Bible(
  bibleId TEXT NOT NULL PRIMARY KEY,
  abbr TEXT NOT NULL,
  iso3 TEXT NOT NULL REFERENCES Language(iso3),
  scope TEXT NOT NULL CHECK (scope IN('B', 'N')),
  name TEXT NULL,
  englishName TEXT NOT NULL,
  localizedName TEXT NULL,
  textBucket TEXT NOT NULL,
  textId TEXT NOT NULL,
  keyTemplate TEXT NOT NULL,
  audioBucket TEXT NULL,
  otDamId TEXT NULL,
  ntDamId TEXT NULL,
  direction TEXT NULL CHECK (direction IN('ltr','rtl')),
  script TEXT NULL,
  country TEXT NULL REFERENCES Country(code));

CREATE INDEX bible_iso3_idx on Bible(iso3);

-- currently ERV-ARB
INSERT INTO Bible VALUES('ERV-ARB.db', 'ERV', 'arb', 'B', 'بِعَهْدَيْهِ القَدِيمِ وَالجَدِيد الكِتَابُ المُقَدَّسُ',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/ARBERV/ARBERV', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/ARBWTC/ARBWTCO1DA', 'audio/ARBWTC/ARBWTCN1DA', 
null, null, null);

-- currently ARBVDPD
INSERT INTO Bible VALUES('ARBVDPD.db', 'VDV', 'arb', 'B', 'الكتاب المقدس ترجمة فان دايك',
'Van Dyck Holy Bible', null, 'text-%R-shortsands', 'text/ARBVDV/ARBVDV', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/ARBVDV/ARZVDVO2DA', 'audio/ARBVDV/ARZVDVN2DA', 
null, null, null);

-- currently ERV-AWA
INSERT INTO Bible VALUES('ERV-AWA.db', 'ERV', 'awa', 'B', 'पवित्तर बाइबिल',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/AWAERV/AWAERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/AWAWTC/AWAWTCN2DA', 
null, null, null);

-- currently ERV-BEN
INSERT INTO Bible VALUES('ERV-BEN.db', 'ERV', 'ben', 'B', 'পবিত্র বাইবেল',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/BENERV/BENERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/BENWTC/BNGWTCN2DA', 
null, null, null);

-- currently ERV-BUL
INSERT INTO Bible VALUES('ERV-BUL.db', 'ERV', 'bul', 'N', 'Новият завет, съвременен превод',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/BULERV/BULERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/BULPRB/BLGAMBN1DA', 
null, null, null); -- audio is different version

-- currently ERV-CMN
INSERT INTO Bible VALUES('ERV-CMN.db', 'ERV', 'cmn', 'B', '圣经–普通话本',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/CMNERV/CMNERV', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/CMNUNV/CHNUNVO2DA', 'audio/CMNUNV/CHNUNVN2DA', 
null, null, null); -- audio is different version

-- currently ERV-ENG
INSERT INTO Bible VALUES('ERV-ENG.db', 'ERV', 'eng', 'B', 'Easy-to-Read Holy Bible',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/ENGERU/ENGERU', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/ENGESV/ENGESVO2DA', 'audio/ENGESV/ENGESVN2DA', 
null, null, null); -- audio is different version

-- currently KJVPD
INSERT INTO Bible VALUES('KJVPD.db', 'KJV', 'eng', 'B', 'King James Holy Bible',
'King James Holy Bible', null, 'text-%R-shortsands', 'text/ENGKJV/ENGKJV', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/ENGKJV/ENGKJVO2DA', 'audio/ENGKJV/ENGKJVN2DA', 
null, null, null);

-- currently WEB
INSERT INTO Bible VALUES('WEB.db', 'WEB', 'eng', 'B', 'World English Holy Bible',
'World English Holy Bible', null, 'text-%R-shortsands', 'text/ENGWEB/ENGWEB', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/ENGWEB/ENGWEBO2DA', 'audio/ENGWEB/ENGWEBN2DA', 
null, null, null);

-- currently ERV-HIN
INSERT INTO Bible VALUES('ERV-HIN.db', 'ERV', 'hin', 'B', 'पवित्र बाइबल',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/HINERV/HINERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/HINWTC/HNDWTCN2DA', 
null, null, null);

-- currently ERV-HRV
INSERT INTO Bible VALUES('ERV-HRV.db', 'ERV', 'hrv', 'N', 'Novi zavjet, Suvremeni prijevod',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/HRVERV/HRVERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

-- currently ERV-HUN
INSERT INTO Bible VALUES('ERV-HUN.db', 'ERV', 'hun', 'B', 'Biblia Egyszerű fordítás',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/HUNERV/HUNERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/HUNHBS/HUNHBSN1DA', 
null, null, null); -- audio is different version

-- currently ERV-IND
INSERT INTO Bible VALUES('ERV-IND.db', 'ERV', 'ind', 'N', 'Perjanjian Baru: Versi Mudah Dibaca',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/INDERV/INDERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/INDSHL/INZSHLN2DA', 
null, null, null); -- audio is different version

-- currently ERV-KAN
INSERT INTO Bible VALUES('ERV-KAN.db', 'ERV', 'kan', 'B', null,
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/KANERV/KANERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/KANWTC/ERVWTCN2DA', 
null, null, null);

-- currently ERV-MAR
INSERT INTO Bible VALUES('ERV-MAR.db', 'ERV', 'mar', 'B', null,
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/MARERV/MARERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/MARWTC/MARWTCN2DA', 
null, null, null);

-- currently ERV-NEP
INSERT INTO Bible VALUES('ERV-NEP.db', 'ERV', 'nep', 'B', null,
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/NEPERV/NEPERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

-- currently ERV-ORI
INSERT INTO Bible VALUES('ERV-ORI.db', 'ERV', 'ori', 'B', 'ପବିତ୍ର ବାଇବଲ',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/ORIERV/ORIERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/ORYWTC/ORYWTCN2DA', 
null, null, null);

-- currently ERV-PAN
INSERT INTO Bible VALUES('ERV-PAN.db', 'ERV', 'pan', 'B', null,
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/PANERV/PANERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

-- currently NMV
INSERT INTO Bible VALUES('NMV.db', 'NMV', 'pes', 'B', 'ترجمۀ هزارۀ نو',
'New Millennium Holy Bible', null, 'text-%R-shortsands', 'text/PESNMV/PESEMV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

-- currently ERV-POR
INSERT INTO Bible VALUES('ERV-POR.db', 'ERV', 'por', 'N', 'Novo Testamento: Versão Fácil de Ler',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/PORERV/PORERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/PORBAR/PORARAN2DA', 
null, null, null); -- audio is a different version

-- currently ERV-RUS
INSERT INTO Bible VALUES('ERV-RUS.db', 'ERV', 'rus', 'B', 'Святая Библия Современный перевод',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/RUSWTC/RUSWTC', 
'%I_%O_%B_%C.html', 'dbp-prod', 'audio/RUSS76/RUSS76O2DA', 'audio/RUSS76/RUSS76N2DA', 
null, null, null); -- audio is a different version

-- currently ERV-SPA
INSERT INTO Bible VALUES('ERV-SPA.db', 'ERV', 'spa', 'B', 'La Biblia: La Palabra de Dios para todos',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/SPAWTC/SPNWTC', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/SPAWTC/SPNWTCN2DA', 
null, null, null);

-- currently ERV-SRP
INSERT INTO Bible VALUES('ERV-SRP.db', 'ERV', 'srp', 'B', 'Библија Савремени српски превод',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/SRPERV/SRPERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

-- currently ERV-TAM
INSERT INTO Bible VALUES('ERV-TAM.db', 'ERV', 'tam', 'B', 'பரிசுத்த பைபிள்',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/TAMERV/TAMERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/TAMWTC/TCVWTCN1DA', 
null, null, null);

-- currently ERV-THA
INSERT INTO Bible VALUES('ERV-THA.db', 'ERV', 'tha', 'B', 'พระ​คริสต​ธรรม​คัมภีร์ ฉบับ​อ่าน​เข้า​ใจ​ง่าย',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/THAERV/THAERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

-- currently ERV-UKR
INSERT INTO Bible VALUES('ERV-UKR.db', 'ERV', 'ukr', 'N', 'Новий Заповіт Сучасною Мовою',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/UKRBLI/UKRERV', 
'%I_%O_%B_%C.html', 'dbp-prod', null, 'audio/UKRN39/UKRO95N2DA', 
null, null, null); -- audio is a different version

-- currently ERV-URD
INSERT INTO Bible VALUES('ERV-URD.db', 'ERV', 'urd', 'B', null,
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/URDWTC/URDWTC', 
'%I_%O_%B_%C.html', 'dbp-prod',  null, 'audio/URDWTC/URDWTCN2DA', 
null, null, null);

-- currently ERV-VIE
INSERT INTO Bible VALUES('ERV-VIE.db', 'ERV', 'vie', 'B', 'Thánh Kinh: Bản Phổ thông',
'Easy-to-Read Holy Bible', null, 'text-%R-shortsands', 'text/VIEWTC/VIEWTC', 
'%I_%O_%B_%C.html', 'dbp-prod', null, null, 
null, null, null);

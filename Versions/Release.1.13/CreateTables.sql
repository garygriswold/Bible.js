CREATE TABLE Language (
languageCode TEXT PRIMARY KEY NOT NULL, // FCBH 3 char code, from FCBH language **
languageName TEXT NOT NULL,             // name in its own language, from FCBH language **
languageISO TEXT NULL,                  // iso 3 character code, from FCBH language ++ (silCode)
languageISO1 TEXT NULL,                 // iso 2 character code, from FCBH language ++ (langCode)
englishName TEXT NULL,                  // name in English, from FCBH language ++
);

CREATE TABLE LanguageLocalized (
languageCode TEXT NOT NULL,     		// FCBH 3 char code, from FCBH language **
languageISO1 TEXT NOT NULL,     		// 2 char code that is language for localizedName
localizedName TEXT NOT NULL,     		// derived from UI, I hope
PRIMARY KEY (languageCode, languageISO1)
);

CREATE TABLE Organization (
organizationId TEXT NOT NULL PRIMARY KEY,
organizationName TEXT NOT NULL,
englishName TEXT NOT NULL,
organizationURL TEXT NULL
);

CREATE TABLE Version (
versionCode TEXT NOT NULL PRIMARY KEY,  // FCBH 3 char code is unique, from FCBH Version **
ssVersionCode: String                   // Pre FCBH SafeBible versionCode ++ (versionCode)
languageCode TEXT NOT NULL              // FCBH 3 char language code, from FCBH Resource query **
    REFERENCES Language(languageCode),
organizationId TEXT NOT NULL            // FCBH I don't know where this comes from ++ (ownerCode)
    REFERENCES Organization(organizationId),
versionAbbr TEXT NOT NULL,              // User friendly versionCode, maybe can be removed
versionName TEXT NOT NULL,              // FCBH version name, from FCBH Version ++
filename TEXT UNIQUE,                   // SS filename ++
hasHistory TEXT CHECK (hasHistory IN('T','F')), // SS true only when book abbrev available
versionDate TEXT NOT NULL,              // Unknown source in FCBH ++
copyright TEXT NULL,                    // Unknown source in FCBH ++
introduction TEXT NULL                  // Unknown source in FCBH
);
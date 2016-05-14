//
// Translation string lookup, build map
//
SELECT source, translated FROM Translation WHERE target = 'xx_XX';
SELECT source, translated FROM Translation WHERE target = 'xx';
SELECT source, translated FROM Translation WHERE target = 'en';
//
// between each select: if (translate[source] == null) translate[source] = translated
//

//
// Replaces select Countries in VersionView
//
SELECT countryCode, primLanguage, localCountryName FROM Country;
//
// lookup countryCode in translate to get Preferred Country Name
//

//
// Replaces select Versions in VersionView
//
SELECT v.versionCode, l.languageName, l.locale, v.versionName, v.versionAbbr, v.copyright, v.filename, 
o.ownerName, o.ownerURL
FROM Version v 
JOIN Owner o ON v.ownerCode = o.ownerCode
JOIN Language l ON v.silCode = l.silCode
JOIN CountryVersion cv ON v.versionCode = cv.versionCode
WHERE cv.countryCode = 'WORLD';
//
// lookup locale in translate to get Perferred Language Name
// lokkup copyright and all rights or add complete copyright message to version table.
//

//
// Replaces select by Filename from BibleVersion
//
SELECT v.versionCode, v.silCode, v.isQaActive, v.copyright, v.introduction,
l.localLanguageName, l.locale, v.versionName, v.versionAbbr, o.ownerCode, o.ownerName, o.ownerURL
FROM Version v
JOIN Owner o ON v.ownerCode = o.ownerCode
JOIN Language l ON v.silCode = l.silCode
WHERE v.filename = 'WEB.db1';
//
// lookup locale in translate to get Perferred Language Name
//



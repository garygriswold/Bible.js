
############################ Upload Bibles ############################

python py/UploadBibleText.py ARBVDPD.db
python py/UploadBibleText.py ERV-ARB.db
python py/UploadBibleText.py ERV-AWA.db
python py/UploadBibleText.py ERV-BEN.db
python py/UploadBibleText.py ERV-BUL.db
python py/UploadBibleText.py ERV-CMN.db
python py/UploadBibleText.py ERV-ENG.db
python py/UploadBibleText.py ERV-HIN.db
python py/UploadBibleText.py ERV-HRV.db
python py/UploadBibleText.py ERV-HUN.db
python py/UploadBibleText.py ERV-IND.db
python py/UploadBibleText.py ERV-KAN.db
python py/UploadBibleText.py ERV-MAR.db
python py/UploadBibleText.py ERV-NEP.db
python py/UploadBibleText.py ERV-ORI.db
python py/UploadBibleText.py ERV-PAN.db
python py/UploadBibleText.py ERV-POR.db
python py/UploadBibleText.py ERV-RUS.db
python py/UploadBibleText.py ERV-SPA.db
python py/UploadBibleText.py ERV-SRP.db
python py/UploadBibleText.py ERV-TAM.db
python py/UploadBibleText.py ERV-THA.db
python py/UploadBibleText.py ERV-UKR.db
python py/UploadBibleText.py ERV-URD.db
python py/UploadBibleText.py ERV-VIE.db
python py/UploadBibleText.py KJVPD.db
python py/UploadBibleText.py NMV.db
python py/UploadBibleText.py WEB.db

# To validate the naming in the Upload:
# sh extract_dbp_prod.sh # to extract these bibles from dbp
# python py/ListBucket.py > west_2.out # to List uploaded Bibles
# diff dbp_prod.out west_2.out

############################ Support Tables ############################

# Create and Load Credentials Table
sqlite Versions.db < Credentials.sql

# Create and Load Owner Table
sqlite Versions.db < sql/Owners.sql

#Create and Lood Region Table
sqlite Versions.db << END_SQL1
CREATE TABLE Region (
countryCode TEXT NOT NULL PRIMARY KEY,
continentCode TEXT NOT NULL CHECK (continentCode IN('AF','EU','AS','NA','SA','OC','AN')),
geoschemeCode TEXT NOT NULL CHECK (geoschemeCode IN(
		'AF-EAS','AF-MID','AF-NOR','AF-SOU','AF-WES',
		'SA-CAR','SA-CEN','SA-SOU','NA-NOR',
		'AS-CEN','AS-EAS','AS-SOU','AS-SEA','AS-WES',
		'EU-EAS','EU-NOR','EU-SOU','EU-WES',
		'OC-AUS','OC-MEL','OC-MIC','OC-POL','AN-ANT')),
awsRegion TEXT NOT NULL REFERENCES AWSRegion(awsRegion),
countryName TEXT NOT NULL	
);
CREATE INDEX Region_awsRegion_index ON Region(awsRegion);
.separator '|'
.import data/Region.txt Region
END_SQL1
# Continent Code
# AF|Africa
# EU|Europe
# AS|Asia
# NA|North America
# SA|South America
# OC|Oceana
# AN|Antartica

# United Nations geoschema
# AF-EAS|Eastern Africa
# AF-MID|Middle Africa
# AF-NOR|Northern Africa
# AF-SOU|Southern Africa
# AF-WES|Western Africa
# SA-CAR|Caribbean
# SA-CEN|Central America
# SA-SOU|South America
# NA-NOR|North America
# AS-CEN|Central Asia
# AS-EAS|Eastern Asia
# AS-SOU|Southern Asia
# AS-SEA|South-Eastern Asia
# AS-WES|Western Asia
# EU-EAS|Eastern Europe
# EU-NOR|Northern Europe
# EU-SOU|Southern Europe
# EU-WES|Western Europe
# OC-AUS|Australia and New Zealeand
# OC-MEL|Melanesia
# OC-MIC|Micronesia
# OC-POL|Polynesia

# Rules for bucket assignment:
# 1) AF -> eu-west-1
# 2) EU -> eu-west-1
# 3) OC -> ap-southeast-2
# 4) AN -> ap-southeast-2
# 5) NA -> us-east-1
# 6) SA -> us-east-1
# 7) AS-WES -> eu-west-1
# 8) AS-SOU -> ap-southeast-1
# 9) AS-SEA -> ap-southeast-1
# 10) AS-CEN -> ap-northeast-1
# 11) AS-EAS -> ap-northeast-1

# Create and Load LanguageTemp and ISO3Priority
python py/LanguageTable.py
python py/ISO3PriorityTable.py

sqlite Versions.db < sql/language.sql
sqlite Versions.db < sql/iso3Priority.sql

# Create and Load Language
sqlite Versions.db <<END_SQL2
DROP TABLE IF EXISTS Language;
CREATE TABLE Language (
  iso3 TEXT NOT NULL PRIMARY KEY,
  iso1 TEXT NULL,
  macro TEXT NULL,
  name TEXT NOT NULL,
  country TEXT NULL REFERENCES Country(code),
  pop REAL NULL);

INSERT INTO Language
select l.iso3, l.iso1, l.macro, l.name, p.country, p.pop 
FROM LanguageTemp l LEFT OUTER JOIN ISO3Priority p 
ON p.iso3=l.iso3;
END_SQL2

# must drop LanguageTemp and ISO3Priority

DROP TABLE IF EXISTS AudioBook;
DROP TABLE IF EXISTS Audio;
DROP TABLE IF EXISTS AudioVersion;

CREATE TABLE AudioVersion(
	versionCode TEXT NOT NULL PRIMARY KEY,
	dbpLanguageCode TEXT NOT NULL,
	dbpVersionCode TEXT NOT NULL	
);

CREATE TABLE Audio(
	damId TEXT NOT NULL PRIMARY KEY,
	dbpLanguageCode TEXT NOT NULL,
	dbpVersionCode TEXT NOT NULL,
	collectionCode TEXT NOT NULL,
	mediaType TEXT NOT NULL,
	volumeName TEXT NOT NULL,
	created DATE NOT NULL
);

CREATE TABLE AudioBook(
	damId TEXT NOT NULL REFERENCES Audio(damId),
	bookId TEXT NOT NULL,
	bookOrder TEXT NOT NULL,
	numberOfChapters INT NOT NULL,
	PRIMARY KEY (damId, bookId)
);



DROP TABLE IF EXISTS AudioChapter;
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
	numberOfChapters INTEGER NOT NULL,
	PRIMARY KEY (damId, bookId)
);

CREATE TABLE AudioChapter(
	damId TEXT NOT NULL REFERENCES Audio(damId),
	bookId TEXT NOT NULL,
	chapter INTEGER NOT NULL,
	versePositions TEXT NOT NULL,
	PRIMARY KEY (damId, bookId, chapter),
	FOREIGN KEY (damId, bookId) REFERENCES AudioBook(damId, bookId)
);



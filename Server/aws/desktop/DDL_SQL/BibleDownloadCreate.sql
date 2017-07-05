-- This SQL Files is used to create the BibleDownload table
-- This file is run manually as needed to create this table.

-- DROP TABLE IF EXISTS BibleDownload;

CREATE TABLE BibleDownload(
	requestid TEXT PRIMARY KEY,
	bucket TEXT NOT NULL,
	datetime DATETIME NOT NULL,
	userid TEXT NOT NULL,
	operation TEXT NOT NULL,
	filename TEXT NOT NULL,
	httpStatus TEXT NOT NULL,
	prefLocale TEXT NULL,
	locale TEXT NULL,
	error TEXT NULL, 
	tranSize TEXT NOT NULL, 
	fileSize TEXT NOT NULL, 
	totalms TEXT NOT NULL, 
	s3ms TEXT NOT NULL, 
	userAgent NOT NULL 	
);

 
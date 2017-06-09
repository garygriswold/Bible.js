-- This SQL Files is used to create the VideoAnalytics table
-- This file is run manually as needed to create this table.

DROP TABLE IF EXISTS VideoViews;

CREATE TABLE VideoViews(
	sessionId TEXT NOT NULL,
	timeStarted TEXT NOT NULL,

	mediaSource TEXT NOT NULL,
	mediaId TEXT NOT NULL,
	languageId TEXT NOT NULL,
	silLang TEXT NOT NULL,
	isStreaming INT NOT NULL, -- Boolean 0 or 1
	
	language TEXT NOT NULL,
	country TEXT NOT NULL,
	locale TEXT NOT NULL,
	
	deviceType TEXT NOT NULL,
	deviceFamily TEXT NOT NULL,
	deviceName TEXT NOT NULL,
	deviceOS TEXT NOT NULL,
	osVersion TEXT NOT NULL,
	
	appName TEXT NOT NULL,
	appVersion TEXT NOT NULL,
	
	timeCompleted TEXT NULL,
	elapsedTime INT NULL,
	mediaViewStartingPosition INT NULL,
	mediaTimeViewInSeconds INT NULL,
	mediaViewCompleted INT NULL, -- Boolean 0 or 1

	PRIMARY KEY (sessionId, timeStarted)	
);



 
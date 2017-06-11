#!/bin/sh -v

cp ../../Analytics.db TestAnalyticsNew.db
sleep 1.0
node DownloadController.js


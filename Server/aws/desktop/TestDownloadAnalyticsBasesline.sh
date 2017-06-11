#!/bin/sh -v

cp ../../Analytics.db TestAnalyticsBaseline.db
sleep 1.0
node DownloadS3Logs.js


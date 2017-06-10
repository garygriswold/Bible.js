#!/bin/sh

sqlite TestAnalyticsNew.db < DDL_SQL/BibleDownloadCreate.sql

node DownloadController.js

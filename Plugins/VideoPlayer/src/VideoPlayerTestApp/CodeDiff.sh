#!/bin/sh -v

TESTDIR=VideoPlayerTestApp
PRODDIR=../ios/VideoPlayer

#ACTION=cp
ACTION=diff

$ACTION $PRODDIR/AnalyticsSessionId.swift $TESTDIR/AnalyticsSessionId.swift
$ACTION $PRODDIR/AVPlayerViewControllerExtension.swift $TESTDIR/AVPlayerViewControllerExtension.swift
$ACTION $PRODDIR/VideoAnalytics.swift $TESTDIR/VideoAnalytics.swift
$ACTION $PRODDIR/VideoViewControllerDelegate.swift $TESTDIR/VideoViewControllerDelegate.swift
$ACTION $PRODDIR/VideoViewPlayer.swift $TESTDIR/VideoViewPlayer.swift
$ACTION $PRODDIR/VideoViewState.swift $TESTDIR/VideoViewState.swift


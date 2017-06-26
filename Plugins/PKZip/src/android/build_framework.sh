#!/bin/sh -ve

./gradlew deleteJars clean assemble check copyDebug copyRelse 


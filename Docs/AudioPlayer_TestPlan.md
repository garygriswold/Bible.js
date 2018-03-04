AudioPlayer Test Plan
=====================
Gary Griswold  
Jan 23, 2018  
Rev Mar 4, 2018  

Audio Player Internal
---------------------

Note: some tests must be repeated for translations with and without verse data.

1.	Start of Play - When audio play starts, the player starts from Bible Text currently viewed; the current version, book and chapter.

2. Start of Play -  If the version in Text is not available in audio, it should fetch another audio version in the same language at the current chapter.

3.	Start of Play - Verse.  Play should start from the verse that is displayed at the top of the page. ??? Or, should it always start at the beginning of the chapter?

4.	Start of Play: No Version - If there is no audio available for the Bible Text that is being displayed, the Audio UI features should be absent.
 
5.	Audio Download - The Audio should be downloaded using https and all information about the identity of the data downloaded should be on the URL path, not in the subhost of the domain. Inspect network transmissions.
 
6.	Continuation of Play - While a chapter is playing the player prefetches the next chapter, and prepares it for playing so that the next chapter will start immediately, when the current chapter ends.  Inspect network transmissions.

7.	Audio Caching - AWS S3 component should cache audio files and not request them again, once they are requested.

8.	Cache Cleanup - Cache should be stored in a location where the OS will erase old files if it needs storage. On iOS this is Library/Caches directory. 

9.	Saving of Position - When the user stops playing by any means, the App will store the current location in the audio, and the identity of the chapter and version.
	1. Pause Button
	2. Stop Button
	3. Control Center pause
	4. Killing the App
	5. Device shutoff	

10.	Using Stored Position - When the user again starts playing the same chapter, if verse position data is available, it will begin playing at the beginning of the verse where playing stopped.

11.	Using Stored Position - When the user starts playing the same chapter, but no verse position data is available, it should back up a few seconds from where playing stopped.

12.	UNIMPLEMENTED: Using Old Stored Position - When the user again starts playing the same, chapter, if the position is more than Y days old, it should start at the beginning of the chapter. Or, the same rule that would apply if there were not stored position.

13.	Bookmark control center - When the user starts playing again from the control center, it should start from the last place listened to.

14.	Analytics - Whenever the player is paused, at the end of play of part of a chapter or many chapters, the audio player should upload statistic.

15.	Statistics should be uploaded without having a bucket on the URL.

16.	Analytics userId - In order that analytics for a single user can be recognized, each analytics upload will contain a userId, but this should be an App generated pseudo UUID, not any existing number from the device or phone service. It should be a pseudo UUID so that it cannot be used to infer the user’s MAC address.
	
Foreground Play
---------------

1.	UI Presentation - There is a single audio button on the menu, and touching it presents the full audio player UI. The audio UI includes a stop button, which when touched causes the audio player UI to disappear.

2.	UI Location - the Location could be over text, or on toolbar separated from text.

3.	UI Appearance - Play / Pause, button is Play when not playing and Pause when playing. Stop button is also present in case A. Includes scrub bar with draggable thumb. 

4.	UI Highlighting - The Play, Pause, Stop and Thumb highlight in some way when touched.

5.	UI Animation - While the audio is playing the thumb moves the length of the bar in the playing of each chapter, and jumps to the beginning for each succeeding chapter. 

6.	UI Verse Number - If verse start position data is available, the verse number displays in a bubble above the scrub bar thumb.

6.	No UI Verse Number - If verse start position data is not available, the bubble above the thumb is absent.

7.	UI Scrub Bar Interaction - User can change place in current chapter, by dragging the scrub bar thumb to any location in scrub bar. If verse start position data is available, the verse number displays in a bubble above the scrub bar thumb as it is dragged showing the user the audio location of each verse.

8.	UI Text Cursor - While Play, the App might display a cursor that highlights the current verse being read.  This cursor, could be a highlighting of the verse, or a bar to the left and/or right of the text.  (This cursor idea might be more difficult that other features because it requires interaction between a native audio player and the Text displayed by JS code, but it is possible). (See YouVersion for example) 

9.	UI Scrub Bar Verse Number Interaction - If the verse start position is available, the playing starts at the beginning of the verse where the thumb was released.

10. UI Scrub Thumb Release, no verse position - If verse position data is not available, play starts a few seconds before where the thumb is released.

11.	UI Scrub Bar Next Chapter - If the scrub bar is dragged all of the way to the right, the play jumps to the start of the next chapter. 

12.	UI Button Sizes - For ease of use, it would be good for the buttons and thumb to be close to 3/8 in or at least 1/4 in in size.
	
Background Play
---------------

1.	Lock Button - When the User clicks the Pause of Stop button, the audio stops. But, when the user clicks the Lock button, the screen goes dark, and the audio continues to play. 

2.	Home Button - When the user navigates to another App without stopping the audio, the audio continues to play.

3.	Volume Control - It should be possible to control the volume from the physical buttons of the device, and the control center.

Interruptions
-------------

1.	Other Audio - If the user should start a different audio in a different App, the Bible Audio should stop.

1.	Other Audio Stops - If the user starts the Bible Audio, other audio should stop.

2.	Phone Call - If the user receives a calls or initiates a call while the audio is playing, the audio should pause on its own. When the call is finished, the audio should restart automatically. 

3.	Earphones plugged in - If a user should plugin earphones while the audio is playing, there should be no change in the playing, (or it could pause momentarily because the plugin will cause a noticeable sound). 

4.	Earphones unplugged - If the user should unplug earphones while the audio is playing, the player should automatically pause, and give the user a chance to adjust the volume, because the user will often need to reduce volume of the speaker.

Control Center (ios only)
-------------------------

1.	Control Center Info - When the user displays the Control Center, if Bible App audio was the last audio being played or is currently being played, the Control Center should display the book, and chapter, and verse that was being played.

2.	Control Center Icon - The control center should display the icon of the App, if that is the last audio played.

3.	Control Center when in Background - When the audio is playing in background, if the user presents the control center, it should be possible to pause and restart play from the control center. 

4.	Control Center Restart - When the App is not playing it should be possible for the user to present the control center, and restart the audio from where they were last listening. The audio should play in background and not restart the App in foreground.

5.	Control Center Back - Clicking the back button should restart the chapter, or if near the beginning of the chapter, it should go to the prior chapter.

6.	Control Center Forward - Clicking the forward button should start the next chapter.

7.	The back and forward button should activate play even when the audio is currently paused.

8.	When control center is playing, and user returns to App foreground, the App should be playing. a) When the App was left while playing, or b) When the App was left while not playing.

App Switching Tests
-------------------

1.	When Audio is playing and the user opens TOC, Search, Video, or Settings the Audio should continue playing.

2.	When the user selects a chapter / verse in the TOC, the audio should either stop playing, or begin playing at the new location.

3.	When the user performs a search, Audio should continue playing.

4.	When the user clicks on a search result, it should either stop playing, or begin playing at the new location.

5.	When the user selects a video and starts playing, the audio should stop.

6.	When the user changes font size, the audio should continue.

7.	When the user changes Bible versions, the audio should stop, or begin playing the other version at the new location.



AudioPlayer Test Plan
=====================
Gary Griswold  
Jan 23, 2018  
Rev Mar 4, 2018  

Audio Player Internal
---------------------

Note: some tests must be repeated for translations with and without verse data.

1. The audio button should only be enabled if the audio exists for the text version

2.	Start of Play - When audio play starts, the player starts from Bible Text currently viewed; the current version, book and chapter.

3.	Audio Download - The Audio should be downloaded using https and all information about the identity of the data downloaded should be on the URL path, not in the subhost of the domain. Inspect network transmissions.

4.	Continuation of Play - While a chapter is playing the player prefetches the next chapter, and prepares it for playing so that the next chapter will start immediately, when the current chapter ends.  Inspect network transmissions.

5.	Audio Caching - AWS S3 component should cache audio files and not request them again, once they are requested.

6.	Cache Cleanup - Cache should be stored in a location where the OS will erase old files if it needs storage. On iOS this is Library/Caches directory.

7.	Saving of Position - When the user stops playing by any means, the App will store the current location in the audio, and the identity of the chapter and version.
	1. Audio button on button bar
	2. Pause Button
	3. Control Center pause
	4. Killing the App
	5. Device shutoff	

8.	Using Stored Position - When the user again starts playing the same chapter, if verse position data is available, it will begin playing at the beginning of the verse where playing stopped.

9.	Using Stored Position - When the user starts playing the same chapter, but no verse position data is available, it should back up a few seconds from where playing stopped.

10.	UNIMPLEMENTED: Using Old Stored Position - When the user again starts playing the same, chapter, if the position is more than Y days old, it should start at the beginning of the chapter. Or, the same rule that would apply if there were not stored position.

11.	Bookmark control center - When the user starts playing again from the control center, it should start from the last place listened to.

12.	Analytics - Whenever the player is paused, at the end of play of part of a chapter or many chapters, the audio player should upload statistic.

13.	Statistics should be uploaded without having a bucket on the URL.

14.	Analytics userId - In order that analytics for a single user can be recognized, each analytics upload will contain a userId, but this should be an App generated pseudo UUID, not any existing number from the device or phone service. It should be a pseudo UUID so that it cannot be used to infer the user’s MAC address.
	
Foreground Play
---------------

1.	UI Presentation - There is a single audio button on the menu, and touching it presents the full audio player UI. Touching the audio button again makes the audio panel to disappear.

2.  When the panel first appears the play button is disabled, but enabled when the audio arrives.

3.	UI Appearance - Play / Pause, button is Play when not playing and Pause when playing. Includes scrub bar with draggable thumb.

4.	UI Highlighting - The Play, Pause, Stop and Thumb highlight when touched.

5.	UI Animation - While the audio is playing the thumb moves the length of the bar in the playing of each chapter, and jumps to the beginning for each succeeding chapter.


6.	UI Verse Number - If verse start position data is available, the verse number displays in a bubble above the scrub bar thumb.

6.	No UI Verse Number - If verse start position data is not available, the bubble above the thumb is absent.

7.	UI Scrub Bar Interaction - User can change place in current chapter, by dragging the scrub bar thumb to any location in scrub bar. If verse start position data is available, the verse number displays in a bubble above the scrub bar thumb as it is dragged showing the user the audio location of each verse.

NOT IMPLEMENTED: 8.	UI Text Cursor - While Audio play, the App will do an animated scroll of the text verse by verse for those Audio Bibles where verse information is available.

NOT IMPLEMENTED: 9.	UI Scrub Bar Verse Number Interaction - If the verse start position is available, the playing starts at the beginning of the verse where the thumb was released.

10. UI Scrub Thumb Release, no verse position - If verse position data is not available, play starts a few seconds before where the thumb is released.

11.	UI Scrub Bar Next Chapter - If the scrub bar is dragged all of the way to the right, the play jumps to the start of the next chapter.

12. The UI buttons should be similar in size to button bar buttons
	
Background Play
---------------

1.	Lock Button - When the User clicks the Pause or audio button, the audio stops. But, when the user clicks the Lock button, the screen goes dark, and the audio continues to play.

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

5.	Control Center Skip Back - Clicking the skip back button should skip back a number of seconds.

6.	Control Center Skip Forward - Clicking the forward button should skip a number of seconds.

NO SURE: 7.	The Skip back and forward button should activate play even when the audio is currently paused.

8.	When control center is playing, and user returns to App foreground, the App should be playing. a) When the App was left while playing, or b) When the App was left while not playing.

App Switching Tests
-------------------

1.	When Audio is playing and the user opens TOC, Search, Video, or Settings the Audio should continue playing.

2.	When the user selects a chapter / verse in the TOC, the audio should continue playing.

3.	When the user performs a search, and when the user clicks on a verse in search, the Audio should continue playing.

4.	When the user selects a video and starts playing, the audio should stop.

5.	When the user changes font size, the audio should continue.

6.	When the user changes Bible versions, the audio should continue, and jump to the position in the text that is being listened to.

Network Reliability
-------------------

1.	Test that once a download is started the handler is disabled to prevent multiple downloads

2.	Timeout - The timeout is currently set very long and I don't know how to change that.

3.	Once a requested download succeeds, that audio should begin playing.

4.	While an audio is in progress the App will allow the user to do other things.


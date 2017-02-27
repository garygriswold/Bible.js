VideoPlayer
===========

Native VideoPlayers for Android and iOS, which "bookmark" the position of play
for multiple videos.

Example Use of Plugin
---------------------

    var videoUrl = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595";
	window.VideoPlayer.present("jesusFilm", videoUrl,
	function() {
		console.log("SUCCESS FROM VideoPlayer");
	},
	function(error) {
		console.log("ERROR FROM VideoPlayer " + error);
	});
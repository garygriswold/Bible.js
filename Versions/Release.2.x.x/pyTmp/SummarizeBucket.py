# This program reads a bucket listing, and summarizes it down one
# entry for each unique resource, by eliminating all of the chapter rows.
# It creates two files one for audio and one for text
# For text files it indicates the presence of about.html, index.html, info.json, title.json
# For audio files it collects just each bible code, and damId

import io

input = io.open("metadata/FCBH/dbp_prod.txt", mode="r", encoding="utf-8")
textOut = io.open("metadata/FCBH/dbp_text.txt", mode="w", encoding="utf-8")
audioOut = io.open("metadata/FCBH/dbp_audio.txt", mode="w", encoding="utf-8")
priorText = ""
textLine = []
priorAudio = ""
priorDamId = ""
audioLine = []
for line in input:
	line = line.strip()
	parts = line.split("/")
	if parts[0] == 'text' and len(parts[1]) == 6 and len(parts[2]) == 6:# and line.endswith("ml"):
		text = parts[1] + "/" + parts[2]
		if not priorText.startswith(text):
			if len(textLine) > 0:
				textOut.write(u" ".join(textLine) + "\n")
			priorText = text
			textLine = [text, parts[2]]
		if line.endswith(u"about.html"):
			textLine.append(u"about")
		elif line.endswith(u"index.html"):
			textLine.append(u"index")
		elif line.endswith(u"info.json"):
			textLine.append(u"info")
		elif line.endswith(u"title.json"):
			textLine.append(u"title")

	elif parts[0] == 'audio' and len(parts[1]) == 6 and line.endswith("mp3"):
		audio = parts[1]
		damId = parts[2]
		if not priorAudio.startswith(audio):
			if len(audioLine) > 0:
				audioOut.write(u" ".join(audioLine) + "\n")
			priorAudio = audio
			audioLine = [audio]
		if priorDamId != damId:
			priorDamId = damId
			audioLine.append(damId)

textOut.write(u" ".join(textLine) + "\n")
audioOut.write(u" ".join(audioLine) + "\n")

input.close()
textOut.close()
audioOut.close()

#text/AAZANT/AAZANT/about.html
#text/AAZANT/AAZANT/index.html
#text/AAZANT/AAZANT/info.json
#text/AAZANT/AAZANT/mobile.css
#text/AAZANT/AAZANT/mobile.png
#text/AAZANT/AAZANT/title.json


use scripting additions
use framework "Foundation"

on run
	tell application "iTunes"
		-- set allSongs to every track in playlist "‹È–¼‚ğÄ\’z‚µ‚½‚¢ƒvƒŒƒCƒŠƒXƒg"
		-- repeat with i from 1 to (count of allSongs) ` end repeat
		-- set props to properties of item i of allSongs
		
		set props to properties of current track
		
		set encodedName to urlEncode(name of props & " " & artist of props & " " & album of props) of me
		set newLocation to "http://itunes.apple.com/search?term=" & encodedName & "&country=JP&lang=ja_jp"
		set shellScript to "curl " & quote & newLocation & quote
		set curlResult to do shell script shellScript
		
		set trackNameMatch to regexMatch(curlResult, "€€€"trackName€€€":€€€"([^€€€"]*)€€€"") of me
		set artistNameMatch to regexMatch(curlResult, "€€€"artistName€€€":€€€"([^€€€"]*)€€€"") of me
		set collectionNameMatch to regexMatch(curlResult, "€€€"collectionName€€€":€€€"([^€€€"]*)€€€"") of me
		
		try
			set newTrackName to item 2 of trackNameMatch
			set newArtistName to item 2 of artistNameMatch
			set newAlbumName to item 2 of collectionNameMatch
		on error
			display dialog "‹È‚Ìî•ñ‚ªiTunes Storeã‚ÉŒ©‚Â‚©‚è‚Ü‚¹‚ñ‚Å‚µ‚½B" buttons {"OK"} default button 1
			return
		end try
		
		if name of props = newTrackName and artist of props = newArtistName and album of props = newAlbumName then
			display dialog "‚±‚Ì‹È‚Ìî•ñ‚Ì’u‚«Š·‚¦‚Í•K—v‚È‚¢‚æ‚¤‚Å‚·B" buttons {"OK"} default button 1
		else
			set dialogMessage to "ˆÈ‰º‚Ìî•ñ‚Å’u‚«Š·‚¦‚Ü‚·B" & return & "‚æ‚ë‚µ‚¯‚ê‚ÎuOKv‚ğƒNƒŠƒbƒN‚µ‚Ä‚­‚¾‚³‚¢B" & return & return & return Ê
				& "yŒ»İz" & return & return Ê
				& "ƒ^ƒCƒgƒ‹F " & return & name of props & return & return Ê
				& "ƒA[ƒeƒBƒXƒgF " & return & artist of props & return & return Ê
				& "ƒAƒ‹ƒoƒ€F " & return & album of props & return & return Ê
				& return & " «««««««««« " & return & return & return Ê
				& "y’u‚«Š·‚¦Œãz" & return & return Ê
				& "ƒ^ƒCƒgƒ‹F " & return & newTrackName & return & return Ê
				& "ƒA[ƒeƒBƒXƒgF " & return & newArtistName & return & return Ê
				& "ƒAƒ‹ƒoƒ€F " & return & newAlbumName
			display dialog dialogMessage
			
			set name of current track to newTrackName
			set artist of current track to newArtistName
			set album of current track to newAlbumName
		end if
	end tell
end run

on urlEncode(inData)
	set scpt to "php -r 'echo rawurlencode(" & quote & inData & quote & ");'"
	return (do shell script scpt) as string
end urlEncode

on regexMatch(sourceText as text, pattern as text)
	set regularExpression to current application's NSRegularExpression's regularExpressionWithPattern:pattern options:0 |error|:(missing value)
	set sourceString to current application's NSString's stringWithString:sourceText
	set matches to regularExpression's matchesInString:sourceText options:0 range:{location:0, |length|:count sourceText}
	
	if (count matches) = 0 then return {}
	
	set match to matches's objectAtIndex:0
	set matchResult to {}
	repeat with i from 0 to (match's numberOfRanges as integer) - 1
		set end of matchResult to (sourceString's substringWithRange:(match's rangeAtIndex:i)) as text
	end repeat
	return matchResult
end regexMatch
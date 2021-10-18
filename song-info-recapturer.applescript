use scripting additions
use framework "Foundation"

on run
	tell application "iTunes"
		-- set allSongs to every track in playlist "曲名を再構築したいプレイリスト"
		-- repeat with i from 1 to (count of allSongs) 〜 end repeat
		-- set props to properties of item i of allSongs
		
		set props to properties of current track
		
		set encodedName to urlEncode(name of props & " " & artist of props & " " & album of props) of me
		set newLocation to "http://itunes.apple.com/search?term=" & encodedName & "&country=JP&lang=ja_jp"
		set shellScript to "curl " & quote & newLocation & quote
		set curlResult to do shell script shellScript
		
		set trackNameMatch to regexMatch(curlResult, "\\\"trackName\\\":\\\"([^\\\"]*)\\\"") of me
		set artistNameMatch to regexMatch(curlResult, "\\\"artistName\\\":\\\"([^\\\"]*)\\\"") of me
		set collectionNameMatch to regexMatch(curlResult, "\\\"collectionName\\\":\\\"([^\\\"]*)\\\"") of me
		
		try
			set newTrackName to item 2 of trackNameMatch
			set newArtistName to item 2 of artistNameMatch
			set newAlbumName to item 2 of collectionNameMatch
		on error
			display dialog "曲の情報がiTunes Store上に見つかりませんでした。" buttons {"OK"} default button 1
			return
		end try
		
		if name of props = newTrackName and artist of props = newArtistName and album of props = newAlbumName then
			display dialog "この曲の情報の置き換えは必要ないようです。" buttons {"OK"} default button 1
		else
			set dialogMessage to "以下の情報で置き換えます。" & return & "よろしければ「OK」をクリックしてください。" & return & return & return ¬
				& "【現在】" & return & return ¬
				& "タイトル： " & return & name of props & return & return ¬
				& "アーティスト： " & return & artist of props & return & return ¬
				& "アルバム： " & return & album of props & return & return ¬
				& return & " ↓↓↓↓↓↓↓↓↓↓ " & return & return & return ¬
				& "【置き換え後】" & return & return ¬
				& "タイトル： " & return & newTrackName & return & return ¬
				& "アーティスト： " & return & newArtistName & return & return ¬
				& "アルバム： " & return & newAlbumName
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
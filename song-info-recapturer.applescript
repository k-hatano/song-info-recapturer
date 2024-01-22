-- 使用法: iTunesで曲名を取得し直したい曲を再生中の状態にして、本スクリプトを実行してください。

use scripting additions
use framework "Foundation"

on run
	if application "Music" is not running then
		display dialog "ミュージックアプリが起動していません。" & return & "使用するには、ミュージックアプリ上で情報を再取得したい曲を再生中にしてください。" buttons {"OK"} default button 1
	end if
	tell application "Music"
		-- set allSongs to every track in playlist "曲名を再構築したいプレイリスト"
		-- repeat with i from 1 to (count of allSongs) 〜 end repeat
		-- set props to properties of item i of allSongs
		
		set props to current track
		
		set encodedName to encodeForUrl(name of props & " " & artist of props & " " & album of props) of me
		set newLocation to "http://itunes.apple.com/search?term=" & encodedName & "&country=JP&lang=ja_jp"
		set shellScript to "curl " & quote & newLocation & quote
		set curlResult to do shell script shellScript
		
		set parsedJSON to parseJSON(curlResult) of me
		set resultCount to getValueForKeyPath(parsedJSON, "resultCount") of me
		if resultCount = "0" then
			display dialog "曲の情報がiTunes Store上に見つかりませんでした。" & "検索条件を曲名のみとして、再検索しますか？"
			set researched to true
		else
			set researched to false
		end if
		
		if researched = true then
			set encodedName to encodeForUrl(name of props) of me
			set newLocation to "http://itunes.apple.com/search?term=" & encodedName & "&country=JP&lang=ja_jp"
			set shellScript to "curl " & quote & newLocation & quote
			set curlResult to do shell script shellScript
			
			set parsedJSON to parseJSON(curlResult) of me
			set resultCount to getValueForKeyPath(parsedJSON, "resultCount") of me
			if resultCount = "0" then
				display dialog "曲の情報がiTunes Store上に見つかりませんでした。"
				return
			end if
		end if
		
		set newTrackName to getValueForKeyPath(parsedJSON, "results.trackName") of me
		set newArtistName to getValueForKeyPath(parsedJSON, "results.artistName") of me
		set newAlbumName to getValueForKeyPath(parsedJSON, "results.collectionName") of me
		
		if name of props = newTrackName and artist of props = newArtistName and album of props = newAlbumName then
			display dialog "この曲の情報の置き換えは必要ないようです。" buttons {"OK"} default button 1
		else
			if resultCount > 1 then
				set multipleWarningMessage to return & return & "※結果が複数（" & resultCount & "件）見つかっています。異なる曲の内容が表示されていないか必ず確認してください。"
			else
				set multipleWarningMessage to ""
			end if
			set dialogMessage to "以下の情報で置き換えます。" & return & "よろしければ「OK」をクリックしてください。" & return & return & "※やり直しはできませんので、必ず内容を目視確認してください。" & multipleWarningMessage & return & return & return ¬
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

on encodeForUrl(source)
	set sourceString to current application's NSString's stringWithString:source
	set result to sourceString's stringByAddingPercentEscapesUsingEncoding:(current application's NSUTF8StringEncoding)
	return result
end encodeForUrl

on parseJSON(source)
	set sourceString to current application's NSString's stringWithString:source
	set sourceData to sourceString's dataUsingEncoding:(current application's NSUTF8StringEncoding)
	set result to current application's NSJSONSerialization's JSONObjectWithData:sourceData options:(current application's NSJSONReadingAllowFragments) |error|:0
	return result
end parseJSON

on getValueForKeyPath(source, targetKeyPath)
	set result to source's valueForKeyPath:targetKeyPath
	if result's isKindOfClass:(current application's NSArray) then
		return (result's objectAtIndex:0) as text
	else
		return result as text
	end if
end getValueForKeyPath

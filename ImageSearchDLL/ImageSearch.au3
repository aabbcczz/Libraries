#include-once
; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with Image Search
;                 Require that the ImageSearchDLL.dll be loadable
;
; ------------------------------------------------------------------------------

;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearchArea, _ImageSearch
; Parameter(s):
;                   $findImage - the image file location or HBitmap to locate on the
;									desktop or in the Specified HBitmap
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;					forceBW - 1 for forcing black/white comparison
;					maxUnmatchedPercentage - the percentage of unmatched pixels that can be tolerated.
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
;					$HBMP - optional hbitmap to search in. sending 0 will search the desktop.
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================
Func _ImageSearch($findImage,$resultPosition, ByRef $x, ByRef $y, $forceBW = 0, $tolerance = 0, $maxUnmatchedPercentage = 0, $HBMP=0)
   return _ImageSearchArea($findImage,$resultPosition,0,0,@DesktopWidth,@DesktopHeight,$x,$y,$tolerance, $maxUnmatchedPercentage, $HBMP)
EndFunc

Func _ImageSearchArea($findImage,$resultPosition,$x1,$y1,$right,$bottom, ByRef $x, ByRef $y, $forceBW = 0, $tolerance = 0, $maxUnmatchedPercentage = 0, $HBMP=0)
   ;MsgBox(0,"asd","" & $x1 & " " & $y1 & " " & $right & " " & $bottom)
   Local $option = ""
   If $tolerance>0 Then $option = "*V" & $tolerance & " " & $option
   If $maxUnmatchedPercentage > 0 Then $option = "*U" & $maxUnmatchedPercentage & " " & $option
   If $forceBW <> 0 Then $option = "*B " & $option

   ; ConsoleWrite("option " & $option & @CRLF)

   If IsString($findImage) Then
		$result = DllCall("ImageSearchDLL.dll","str","ImageSearchFile","str", $findImage, "str", $option, "int",$x1,"int",$y1,"int",$right,"int",$bottom, "handle", $HBMP)
	Else
		$result = DllCall("ImageSearchDLL.dll","str","ImageSearchHandle","handle", $findImage, "str", $option, "int",$x1,"int",$y1,"int",$right,"int",$bottom, "handle", $HBMP)
	EndIf

	; If error exit
	if $result[0]="0" then return 0

	; Otherwise get the x,y location of the match and the size of the image to
	; compute the centre of search
	$array = StringSplit($result[0],"|")

   $x=Int(Number($array[2]))
   $y=Int(Number($array[3]))
   if $resultPosition=1 then
	  $x=$x + Int(Number($array[4])/2)
	  $y=$y + Int(Number($array[5])/2)
   endif
   return 1
EndFunc

Func _BitmapHash($HBMP)
   Local $result

   If $HBMP = 0 Then
	  Return 0
   EndIf

   $result = DllCall("ImageSearchDLL.dll","uint","BitmapHash", "handle", $HBMP)

   If @error <> 0 Then
	  Return 0xFFFFFFFF
   EndIf

   Return $result[0]
 EndFunc

;===============================================================================
;  Load Picture from file
;===============================================================================
Func _LoadPictureFromFile($sFile)
    If Not IsString($sFile) Then
        Return 0
    EndIf
    
    Local $iImageType = 0
    $result = DllCall("ImageSearchDLL.dll", "handle", "LoadPictureFromFile", "str", $sFile, "int", 0, "int", 0, "int*", $iImageType, "int", 0, "bool", False)
    
    If @error<> 0 Then
        Return 0
    EndIf
    
    Return $result[0]
EndFunc



;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch, _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the image file location or HBitmap to locate on the
;									desktop or in the Specified HBitmap
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;					forceBW - 1 for forcing black/white comparison
;					maxUnmatchedPercentage - the percentage of unmatched pixels that can be tolerated.
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
;					$HBMP - optional hbitmap to search in. sending 0 will search the desktop.
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage,$waitSecs,$resultPosition, ByRef $x, ByRef $y, $forceBW = 0, $tolerance = 0, $maxUnmatchedPercentage = 0, $HBMP=0)
	$waitSecs = $waitSecs * 1000
	$startTime=TimerInit()
	While TimerDiff($startTime) < $waitSecs
		sleep(100)
		$result=_ImageSearch($findImage,$resultPosition,$x, $y, $forceBW, $tolerance, $maxUnmatchedPercentage, $HBMP)
		if $result > 0 Then
			return 1
		EndIf
	WEnd
	return 0
EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImages - the ARRAY of images to locate on the desktop
;                              - ARRAY[0] is set to the number of images to loop through
;								 ARRAY[1] is the first image, it could be image file location of HBitmap.
;
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;					forceBW - 1 for forcing black/white comparison
;					maxUnmatchedPercentage - the percentage of unmatched pixels that can be tolerated.
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
;					$HBMP - optional hbitmap to search in. sending 0 will search the desktop.
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImagesSearch($findImages,$waitSecs,$resultPosition, ByRef $x, ByRef $y, $forceBW = 0, $tolerance = 0, $maxUnmatchedPercentage = 0, $HBMP=0)
	$waitSecs = $waitSecs * 1000
	$startTime=TimerInit()
	While TimerDiff($startTime) < $waitSecs
		for $i = 1 to $findImages[0]
			sleep(100)
			$result=_ImageSearch($findImages[$i],$resultPosition,$x, $y, $forceBW, $tolerance, $maxUnmatchedPercentage, $HBMP)
			if $result > 0 Then
				return $i
			EndIf
		Next
	WEnd
	return 0
EndFunc


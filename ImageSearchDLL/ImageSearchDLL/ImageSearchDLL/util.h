/*
AutoHotkey

Copyright 2003-2007 Chris Mallett (support@autohotkey.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
*/


#ifndef util_h
#define util_h

#define DLLSPEC extern "C" __declspec (dllexport)

#include "stdafx.h" // pre-compiled headers
//#include "defines.h"

///////////////////////////////////////////////////////////////////////////////////////////
// aFilespec: file path and name. If it is empty string "", NULL will be returned
//
// (aWidth, aHeight) values
//	(>0, >0) load piciture and scaled to expected size (aWidth, aHeight)
//	(0, >=0) (>=0, 0) load picture in original size
//	(-1, >0) load picture and scaled to (?, aHeight), but keep the height:width ratio
//	(>0, -1) load picture and scaled to (aWidth, ?), but keep the height:width ratio
//	(-1, 0), (0, -1), (-1, -1) Equals to (0, 0)
//
// aImageType will be set to IMAGE_BITMAP, IMAGE_ICON, ... please refer to <WinUser.h>
//
// If aIconNumber > 0, an HICON or HCURSOR is returned (both should be interchangeable), never an HBITMAP.
// However, aIconNumber==1 is treated as a special icon upon which LoadImage is given preference over ExtractIcon
// for .ico/.cur/.ani files.
// Otherwise, .ico/.cur/.ani files are normally loaded as HICON (unless aUseGDIPlusIfAvailable is true or
// something else unusual happened such as file contents not matching file's extension).  This is done to preserve
// any properties that HICONs have but HBITMAPs lack, namely the ability to be animated and perhaps other things.
DLLSPEC HBITMAP WINAPI LoadPictureFromFile(const char *aFilespec, int aWidth, int aHeight, int &aImageType, int aIconNumber, bool aUseGDIPlusIfAvailable);

DLLSPEC HBITMAP WINAPI LoadPictureFromHandle(HBITMAP hBitmap);

DLLSPEC UINT32 WINAPI BitmapHash(HBITMAP hBitmap);

// DLLSPEC char* WINAPI ImageSearch(int aLeft, int aTop, int aRight, int aBottom, char *aImageFile, HBITMAP hbitmap_search = NULL);

///
/// the format of option string is ([\*(option)[value]][ |\t]+)+. for example: "*W50 *U30 *V10 *TransYellow"
/// All supported options are:
///		*B : force comparsion as black and white. each pixel will be converted to grayscale (0-255) firstly,
///			 if grayscale < 128, the color will be converted to 0x000000, otherwise it will be converted to 0xFFFFFF
///		*Wxxx: specify the width parameter used in LoadPictureFromFile. xxx should be an integer.
///     *Hxxx: specify the height paramter used in LoadPictureFromFile. xxx should be an integer.
///		*Vxxx: specify the variation used for comparison pixel colore in each channel. xxx should be an integer between 0 and 255.
///				for example, if *V16 is specified, assume the RED channel of 2 pixels are 0xF0 and 0xFF, then the channels will be
///				treated as equal.
///		*Uxxx: specify the maximum percent of unmatched pixels that can be tolerated. xxx should be
///				between 0 and 100. for example:
///					*U50 means at most 50% mismatched pixels can be tolerated.
///		*ICONxxx: specifiy the IconNumber parameter used in LoadPictureFromFile. xxx should be an integer.
///		*TRANSxxx: specify the transparent color in pattern image.
///					xxx could be color string in "Black", "Silver", "Gray", "White", "Maroon", "Red", "Purple",
///					"Fuchisa", "Green", "Lime", "Olive", "Yellow", "Navy", "Blue", "Teal", "Aqua", "Default",
///					or a HEX string that specify the RGB color, such as "0xC0D0F0"
///					
/// Return value is a string.
///		if image is found, return string is formated as "1|loc_x|loc_y|width|height". e.g. "1|10|15|100|100"
///		otherwise, return string is "0";
///
DLLSPEC char* WINAPI ImageSearchFile(const char * aImageFile, const char * option, int aLeft, int aTop, int aRight, int aBottom, HBITMAP hImageSearch = NULL);

DLLSPEC char* WINAPI ImageSearchHandle(HBITMAP hPatternImage, const char * option, int aLeft, int aTop, int aRight, int aBottom, HBITMAP hImageSearch = NULL);



#endif

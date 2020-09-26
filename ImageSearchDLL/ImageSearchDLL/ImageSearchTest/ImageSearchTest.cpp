// ImageSearchTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "pch.h"
#include <iostream>
#include "..\ImageSearchDLL\util.h"

int main()
{
	const char * fileName = "test.jpg";
	int imageType = 0;

	HBITMAP hBitmap = LoadPictureFromFile(const_cast<char *>(fileName), 0, 0, imageType, 0, false);
	if (hBitmap == NULL)
	{
		printf("load picture failed\n");
	}
	else
	{
		UINT32 hash = BitmapHash(hBitmap);
		printf("bitmap hash is %x\n", hash);

		DeleteObject(hBitmap);
	}
}

#include <stdio.h>
#include <stdlib.h>
#include "bitmap.h"

int  load_bitmap (FILE *fp, BitmapFileHeader *bf, 
				 BitmapInfoHeader *bi, 
				 ColorPallette *cp);
void readBMFHeader(BitmapFileHeader *bf, FILE *fp);
void readBMIHeader(BitmapInfoHeader *bi, FILE *fp);
void dump_pixels (FILE *fp);

int main (int argc, char **argv) {
	FILE *fp;

	unsigned char rbuf;
	int i, count,lcount;
	int error;
	BitmapFileHeader bf;
	BitmapInfoHeader bi;
	ColorPallette *cp;

	if(argc == 1){
		printf("[info] no input\n");
		printf("\tUsage:");
		printf("bmp2hex [bitmap]\n");
		return 0;
	}
	fp = fopen(*++argv, "r");
	if(fp == NULL) {
		printf("Failed to open input.\n");
		return 0;
	}
	error = load_bitmap(fp, &bf, &bi, cp);
	if(error) {
		printf("Failed to load bitmap image : %d\n", error);
		return 0;
	}
	dump_pixels(fp);
	return 0;
}

int load_bitmap (FILE *fp, 
				 BitmapFileHeader *bf, 
				 BitmapInfoHeader *bi, 
				 ColorPallette *cp) {
	int i;
	unsigned long cpn;

	readBMFHeader(bf, fp);
	readBMIHeader(bi, fp);
	if(bf->Type != 0x4d42) {
		printf("Input file is not BMP.\n");
		return 1;
	}
	// malloc for Color Pallete
	cpn = 1;
	if(bi->BitCount != 24){
		cpn <<= bi->BitCount;
		cp = (ColorPallette*) malloc(cpn*4*sizeof(unsigned char));
		for(i = 0; i < cpn; i++){
			fread(&(cp->red), 1, 1, fp);
			fread(&(cp->green), 1, 1, fp);
			fread(&(cp->blue), 1, 1, fp);
			fread(&(cp->reserved), 1, 1, fp);
		}
	}
	return 0;
}

void readBMFHeader(BitmapFileHeader *bf, FILE *fp){
	unsigned char bufc;
	unsigned short bufs;
	unsigned long bufl;
	fread(&bufs, 2, 1, fp);
	bf->Type = bufs;
	fread(&bufl, 4, 1, fp);
	bf->Size = bufl;
	fread(&bufs, 2, 1, fp);
	fread(&bufs, 2, 1, fp);
	bf->Reserved1 = 0;
	bf->Reserved2 = 0;
	fread(&bufl, 4, 1, fp);
	bf->OffBits = bufl;
	return;
}

void readBMIHeader(BitmapInfoHeader *bi, FILE *fp){
	unsigned char bufc;
	unsigned short bufs;
	unsigned long bufl;
	fread(&bufl, 4, 1, fp);
	bi->Size = bufl;
	fread(&bufl, 4, 1, fp);
	bi->Width = (signed long)bufl;
	fread(&bufl, 4, 1, fp);
	bi->Height = (signed long)bufl;
	fread(&bufs, 2, 1, fp);
	bi->Planes = bufs;
	fread(&bufs, 2, 1, fp);
	bi->BitCount = bufs;
	fread(&bufl, 4, 1, fp);
	bi->Compression = bufl;
	fread(&bufl, 4, 1, fp);
	bi->SizeImage = bufl;
	fread(&bufl, 4, 1, fp);
	bi->XPixPerMeter = (signed long)bufl;
	fread(&bufl, 4, 1, fp);
	bi->YPixPerMeter = (signed long)bufl;
	fread(&bufl, 4, 1, fp);
	bi->ClrUsed = bufl;
	fread(&bufl, 4, 1, fp);
	bi->ClrImportant = bufl;
	return;
}

void dump_pixels (FILE *fp) {
	unsigned char buf;
	while(fread(&buf, 1, 1, fp) != 0) {
		printf("%02x\n", buf);
	}
	return;
}

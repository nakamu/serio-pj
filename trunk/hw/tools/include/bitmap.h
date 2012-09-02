typedef struct{
		unsigned short Type;  /* Must be "BM" */	//2
		unsigned long Size; /* Byte */						//6
		unsigned short Reserved1; /* 0 */					//8
		unsigned short Reserved2; /* 0 */					//10
		unsigned long OffBits;  /* where the picture data begins? */	//14
}BitmapFileHeader;
  
typedef struct{
		unsigned long Size;	//4
		long Width;					//8
		long Height;				//12
		unsigned short Planes;	//14
		unsigned short BitCount;	//16
		unsigned long Compression;	//20
		unsigned long SizeImage;	//24
		long XPixPerMeter;				//28
		long YPixPerMeter;				//32
		unsigned long ClrUsed;		//36
		unsigned long ClrImportant;	//40
}BitmapInfoHeader;

typedef struct{
		unsigned char blue;
		unsigned char green;
		unsigned char red;
		unsigned char reserved;
}ColorPallette;


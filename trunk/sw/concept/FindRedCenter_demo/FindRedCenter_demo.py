 
class RGB:
	def __init__(self, r, g, b):
		self.r = r
		self.g = g
		self.b = b

class RedCenterFinder:
	def __init__(self, w, h):
		self.w = w
		self.h = h
		self.clear()

	def clear(self):
		self.sumR = 0
		self.sumX = 0
		self.sumY = 0
		self.curX = 0
		self.curY = 0

	def addPixel(self, rgb):
		if self.curY >= self.h:
			raise IndexError, "pixel index out of range"

		self.sumR += rgb.r
		self.sumX += (self.curX+1) * rgb.r
		self.sumY += (self.curY+1) * rgb.r
		self.curX += 1
		if self.curX >= self.w:
			self.curY += 1
			self.curX = 0

	def loadImage(self, rgbList):
		for pixel in rgbList:
			self.addPixel(pixel)

	def getRedCenter(self):
		if self.curY != self.h:
			raise RuntimeError, "pixel data is not enough (" + str(self.curX)+" , "+str(self.curY)+")"
		return (float(self.sumX) / self.sumR - 1, float(self.sumY) / self.sumR - 1)


# import時には以下のコードは実行されない
if __name__ == "__main__":
	rgbData = ((100,0,0),(0,0,0),(100,0,0),(0,0,0),(0,0,0),(0,0,0),(100,0,0),(0,0,0),(100,0,0))
	image = [RGB(r,g,b) for (r,g,b) in rgbData]

	class PixelProvider:
		def __init__(self, image):
			self.image = image
			self.index = 0
		
		def getPixel(self):
			self.index += 1
			return self.image[self.index-1]
			
	
	# 画像全体をメモリに入れてやる方法
	finder = RedCenterFinder(3,3)
	finder.loadImage(image)
	print finder.getRedCenter()

	finder.clear()
	# ピクセルずつ読み込みながらやる方法
	provider = PixelProvider(image)
	for j in range(3):
		for i in range(3):
			finder.addPixel(provider.getPixel())
	print finder.getRedCenter()
	

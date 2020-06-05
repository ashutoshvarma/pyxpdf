//========================================================================
//
// BitmapOutputDev.h
//
// Copyright 2020 Ashutosh Varma <ashutoshvarma11@live.com>
//
//========================================================================

#ifndef BITMAPOUTPUTDEV_H
#define BITMAPOUTPUTDEV_H

#include <aconf.h>

#ifdef USE_GCC_PRAGMAS
#pragma interface
#endif

#include <vector>
#include <memory>
#include <stdio.h>
#include "gtypes.h"
#include "OutputDev.h"
#include "SplashTypes.h"

class GfxImageColorMap;
class GfxState;
class SplashBitmap;


struct PDFImage {
    int pageNum = 0;
    std::unique_ptr<SplashBitmap> bitmap;
    SplashColorMode mode;
    double hDPI = 0;
    double vDPI = 0;
    int bpc = 0;
};


//------------------------------------------------------------------------
// BitmapOutputDev
//------------------------------------------------------------------------

class BitmapOutputDev: public OutputDev {
public:

  BitmapOutputDev(std::vector<PDFImage> *image_listA);

  // Destructor.
  virtual ~BitmapOutputDev();

  // Check if file was successfully created.
  virtual GBool isOk() { return ok; }

  // Does this device use tilingPatternFill()?  If this returns false,
  // tiling pattern fills will be reduced to a series of other drawing
  // operations.
  virtual GBool useTilingPatternFill() { return gTrue; }

  // Does this device use beginType3Char/endType3Char?  Otherwise,
  // text in Type 3 fonts will be drawn with drawChar/drawString.
  virtual GBool interpretType3Chars() { return gFalse; }

  // Does this device need non-text content?
  virtual GBool needNonText() { return gTrue; }

  //---- get info about output device

  // Does this device use upside-down coordinates?
  // (Upside-down means (0,0) is the top left corner of the page.)
  virtual GBool upsideDown() { return gTrue; }

  // Does this device use drawChar() or drawString()?
  virtual GBool useDrawChar() { return gFalse; }

  //----- initialization and control
  virtual void startPage(int pageNum, GfxState *state);

  //----- path painting
  virtual void tilingPatternFill(GfxState *state, Gfx *gfx, Object *strRef,
				 int paintType, int tilingType, Dict *resDict,
				 double *mat, double *bbox,
				 int x0, int y0, int x1, int y1,
				 double xStep, double yStep);

  //----- image drawing
  virtual void drawImageMask(GfxState *state, Object *ref, Stream *str,
			     int width, int height, GBool invert,
			     GBool inlineImg, GBool interpolate);
  virtual void drawImage(GfxState *state, Object *ref, Stream *str,
			 int width, int height, GfxImageColorMap *colorMap,
			 int *maskColors, GBool inlineImg, GBool interpolate);
  virtual void drawMaskedImage(GfxState *state, Object *ref, Stream *str,
			       int width, int height,
			       GfxImageColorMap *colorMap,
			       Stream *maskStr, int maskWidth, int maskHeight,
			       GBool maskInvert, GBool interpolate);
  virtual void drawSoftMaskedImage(GfxState *state, Object *ref, Stream *str,
				   int width, int height,
				   GfxImageColorMap *colorMap,
				   Stream *maskStr,
				   int maskWidth, int maskHeight,
				   GfxImageColorMap *maskColorMap,
				   double *matte, GBool interpolate);

private:
  std::vector<PDFImage> &image_list;
  int curPageNum;		// current page number
  GBool ok;			// set up ok?
};

#endif

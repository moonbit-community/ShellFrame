///|
extern "C" fn magick_wand_genesis() = "MagickWandGenesis"

///|
extern "C" fn magick_wand_terminus() = "MagickWandTerminus"

///|
#external
type MagickWand

///|
type SizeT = UInt64

///|
type SSizeT = Int64

///|
extern "C" fn magick_wand_new() -> MagickWand = "SFStubNewMagickWand"

///|
enum MagickBooleanType {
  MagickFalse = 0
  MagickTrue = 1
} derive(Debug)

///|
impl Show for MagickBooleanType with output(self, logger) {
  match self {
    MagickFalse => logger.write_string("MagickFalse")
    MagickTrue => logger.write_string("MagickTrue")
  }
}

///|
#borrow(wand, filename)
extern "C" fn magick_wand_read_image(
  wand : MagickWand,
  filename : Bytes,
) -> MagickBooleanType = "SFStubMagickReadImage"

///|
#borrow(wand, filename)
extern "C" fn magick_wand_write_image(
  wand : MagickWand,
  filename : Bytes,
) -> MagickBooleanType = "SFStubMagickWandWriteImage"

///|
#borrow(wand)
extern "C" fn magick_wand_get_image_width(wand : MagickWand) -> SizeT = "SFStubMagickGetImageWidth"

///|
#borrow(wand)
extern "C" fn magick_wand_get_image_height(wand : MagickWand) -> SizeT = "SFStubMagickGetImageHeight"

///|
#borrow(wand, pixels)
extern "C" fn magick_wand_export_image_pixels(
  wand : MagickWand,
  x : SSizeT,
  y : SSizeT,
  columns : SizeT,
  rows : SizeT,
  pixels : FixedArray[Byte],
) -> MagickBooleanType = "SFStubMagickExportImagePixels"

///|
#borrow(wand, pixels)
extern "C" fn magick_wand_import_image_pixels(
  wand : MagickWand,
  x : SSizeT,
  y : SSizeT,
  columns : SizeT,
  rows : SizeT,
  pixels : FixedArray[Byte],
) -> MagickBooleanType = "SFStubMagickImportImagePixels"

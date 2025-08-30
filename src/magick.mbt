///|
extern "C" fn magick_wand_genesis() = "MagickWandGenesis"

///|
extern "C" fn magick_wand_terminus() = "MagickWandTerminus"

///|
#external
type MagickWand

typealias UInt64 as size_t

typealias Int64 as ssize_t

///|
extern "C" fn magick_wand_new() -> MagickWand = "SFStubNewMagickWand"

///|
enum MagickBooleanType {
  MagickFalse = 0
  MagickTrue = 1
} derive(Show)

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
extern "C" fn magick_wand_get_image_width(
  wand : MagickWand,
) -> size_t = "SFStubMagickGetImageWidth"

///|
#borrow(wand)
extern "C" fn magick_wand_get_image_height(
  wand : MagickWand,
) -> size_t = "SFStubMagickGetImageHeight"

///|
#borrow(wand, pixels)
extern "C" fn magick_wand_export_image_pixels(
  wand : MagickWand,
  x : ssize_t,
  y : ssize_t,
  columns : size_t,
  rows : size_t,
  pixels : FixedArray[Byte],
) -> MagickBooleanType = "SFStubMagickExportImagePixels"

///|
#borrow(wand, pixels)
extern "C" fn magick_wand_import_image_pixels(
  wand : MagickWand,
  x : ssize_t,
  y : ssize_t,
  columns : size_t,
  rows : size_t,
  pixels : FixedArray[Byte],
) -> MagickBooleanType = "SFStubMagickImportImagePixels"

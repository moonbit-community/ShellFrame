///|
fn get_quantization_matrix() -> FixedArray[FixedArray[Int]] {
  let matrix = FixedArray::makei(8, _ => FixedArray::make(8, 0))
  let values = [
    [16, 11, 10, 16, 24, 40, 51, 61],
    [12, 12, 14, 19, 26, 58, 60, 55],
    [14, 13, 16, 24, 40, 57, 69, 56],
    [14, 17, 22, 29, 51, 87, 80, 62],
    [18, 22, 37, 56, 68, 109, 103, 77],
    [24, 35, 55, 64, 81, 104, 113, 92],
    [49, 64, 78, 87, 103, 121, 120, 101],
    [72, 92, 95, 98, 112, 100, 103, 99],
  ]
  for i = 0; i < 8; i = i + 1 {
    for j = 0; j < 8; j = j + 1 {
      matrix[i][j] = values[i][j]
    }
  }
  matrix
}

///|
fn calculate_block_variance(
  block : FixedArray[FixedArray[Double]],
  n : Int,
) -> Double {
  let mut sum = 0.0
  let mut sum_sq = 0.0
  let total = n * n

  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let val = block[i][j]
      sum = sum + val
      sum_sq = sum_sq + val * val
    }
  }

  let mean = sum / total.to_double()
  let variance = sum_sq / total.to_double() - mean * mean
  variance
}

///|
fn adaptive_quantization_matrix(
  base_matrix : FixedArray[FixedArray[Int]],
  quality : Int,
  variance : Double,
  channel : Int,
) -> FixedArray[FixedArray[Double]] {
  let scaled_matrix = FixedArray::makei(8, _ => FixedArray::make(8, 0.0))
  let base_scale_factor = if quality < 50 {
    5000.0 / quality.to_double()
  } else {
    200.0 - 2.0 * quality.to_double()
  }

  let variance_factor = if variance > 0.1 {
    0.8
  } else if variance > 0.05 {
    0.9
  } else {
    1.2
  }

  let chroma_scale = if channel == 0 { 1.0 } else { 1.5 }

  for i = 0; i < 8; i = i + 1 {
    for j = 0; j < 8; j = j + 1 {
      let scaled_value = {
        let v = base_matrix[i][j].to_double() *
          base_scale_factor *
          variance_factor *
          chroma_scale /
          100.0
        if v < 1.0 {
          1.0
        } else {
          v
        }
      }
      scaled_matrix[i][j] = scaled_value
    }
  }
  scaled_matrix
}

///|
fn scale_quantization_matrix(
  base_matrix : FixedArray[FixedArray[Int]],
  quality : Int,
) -> FixedArray[FixedArray[Double]] {
  let scaled_matrix = FixedArray::makei(8, _ => FixedArray::make(8, 0.0))
  let scale_factor = if quality < 50 {
    5000.0 / quality.to_double()
  } else {
    200.0 - 2.0 * quality.to_double()
  }

  for i = 0; i < 8; i = i + 1 {
    for j = 0; j < 8; j = j + 1 {
      let scaled_value = {
        let v = base_matrix[i][j].to_double() * scale_factor / 100.0
        if v < 1.0 {
          1.0
        } else {
          v
        }
      }
      scaled_matrix[i][j] = scaled_value
    }
  }
  scaled_matrix
}

///|
fn quantize_dct_block(
  dct_block : FixedArray[FixedArray[Double]],
  q_matrix : FixedArray[FixedArray[Double]],
) -> FixedArray[FixedArray[Double]] {
  let quantized = FixedArray::makei(8, _ => FixedArray::make(8, 0.0))
  for i = 0; i < 8; i = i + 1 {
    for j = 0; j < 8; j = j + 1 {
      quantized[i][j] = (dct_block[i][j] / q_matrix[i][j]).round()
    }
  }
  quantized
}

///|
fn dequantize_dct_block(
  quantized_block : FixedArray[FixedArray[Double]],
  q_matrix : FixedArray[FixedArray[Double]],
) -> FixedArray[FixedArray[Double]] {
  let dequantized = FixedArray::makei(8, _ => FixedArray::make(8, 0.0))
  for i = 0; i < 8; i = i + 1 {
    for j = 0; j < 8; j = j + 1 {
      dequantized[i][j] = quantized_block[i][j] * q_matrix[i][j]
    }
  }
  dequantized
}

///|
fn dct_1d(input : FixedArray[Double], n : Int) -> FixedArray[Double] {
  let output = FixedArray::make(n, 0.0)
  for u = 0; u < n; u = u + 1 {
    let mut sum = 0.0
    let alpha_u = if u == 0 { 1.0 / 2.0.sqrt() } else { 1.0 }
    for x = 0; x < n; x = x + 1 {
      let cos_term = @math.cos(
        @math.PI * u.to_double() * (2 * x + 1).to_double() / (2 * n).to_double(),
      )
      sum = sum + input[x] * cos_term
    }
    output[u] = alpha_u * sum * (2.0 / n.to_double()).sqrt()
  }
  output
}

///|
fn idct_1d(input : FixedArray[Double], n : Int) -> FixedArray[Double] {
  let output = FixedArray::make(n, 0.0)
  for x = 0; x < n; x = x + 1 {
    let mut sum = 0.0
    for u = 0; u < n; u = u + 1 {
      let alpha_u = if u == 0 { 1.0 / 2.0.sqrt() } else { 1.0 }
      let cos_term = @math.cos(
        @math.PI * u.to_double() * (2 * x + 1).to_double() / (2 * n).to_double(),
      )
      sum = sum + alpha_u * input[u] * cos_term
    }
    output[x] = sum * (2.0 / n.to_double()).sqrt()
  }
  output
}

///|
fn dct_2d(
  input : FixedArray[FixedArray[Double]],
  n : Int,
) -> FixedArray[FixedArray[Double]] {
  let temp = FixedArray::makei(n, _ => FixedArray::make(n, 0.0))
  let output = FixedArray::makei(n, _ => FixedArray::make(n, 0.0))

  for i = 0; i < n; i = i + 1 {
    let row_dct = dct_1d(input[i], n)
    for j = 0; j < n; j = j + 1 {
      temp[i][j] = row_dct[j]
    }
  }

  for j = 0; j < n; j = j + 1 {
    let col = FixedArray::make(n, 0.0)
    for i = 0; i < n; i = i + 1 {
      col[i] = temp[i][j]
    }
    let col_dct = dct_1d(col, n)
    for i = 0; i < n; i = i + 1 {
      output[i][j] = col_dct[i]
    }
  }
  output
}

///|
fn idct_2d(
  input : FixedArray[FixedArray[Double]],
  n : Int,
) -> FixedArray[FixedArray[Double]] {
  let temp = FixedArray::makei(n, _ => FixedArray::make(n, 0.0))
  let output = FixedArray::makei(n, _ => FixedArray::make(n, 0.0))

  for i = 0; i < n; i = i + 1 {
    let col = FixedArray::make(n, 0.0)
    for j = 0; j < n; j = j + 1 {
      col[j] = input[i][j]
    }
    let col_idct = idct_1d(col, n)
    for j = 0; j < n; j = j + 1 {
      temp[i][j] = col_idct[j]
    }
  }

  for j = 0; j < n; j = j + 1 {
    let row = FixedArray::make(n, 0.0)
    for i = 0; i < n; i = i + 1 {
      row[i] = temp[i][j]
    }
    let row_idct = idct_1d(row, n)
    for i = 0; i < n; i = i + 1 {
      output[i][j] = row_idct[i]
    }
  }
  output
}

///|
fn rgb_to_ycbcr(r : Double, g : Double, b : Double) -> (Double, Double, Double) {
  let y = 0.299 * r + 0.587 * g + 0.114 * b
  let cb = -0.168736 * r - 0.331264 * g + 0.5 * b + 0.5
  let cr = 0.5 * r - 0.418688 * g - 0.081312 * b + 0.5
  (y, cb, cr)
}

///|
fn ycbcr_to_rgb(
  y : Double,
  cb : Double,
  cr : Double,
) -> (Double, Double, Double) {
  let cb_adj = cb - 0.5
  let cr_adj = cr - 0.5
  let r = y + 1.402 * cr_adj
  let g = y - 0.344136 * cb_adj - 0.714136 * cr_adj
  let b = y + 1.772 * cb_adj
  (r, g, b)
}

///|
fn pixels_to_double(
  pixels : FixedArray[Byte],
  width : Int,
  height : Int,
) -> FixedArray[FixedArray[FixedArray[Double]]] {
  let pixels_double = FixedArray::makei(3, _ => {
    FixedArray::makei(height, _ => FixedArray::make(width, 0.0))
  })
  for j = 0; j < height; j = j + 1 {
    for k = 0; k < width; k = k + 1 {
      let idx = (j * width + k) * 3
      let r = pixels[idx].to_double() / 255.0
      let g = pixels[idx + 1].to_double() / 255.0
      let b = pixels[idx + 2].to_double() / 255.0
      let (y, cb, cr) = rgb_to_ycbcr(r, g, b)
      pixels_double[0][j][k] = y
      pixels_double[1][j][k] = cb
      pixels_double[2][j][k] = cr
    }
  }
  pixels_double
}

///|
fn double_to_pixels(
  pixels_double : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
) -> FixedArray[Byte] {
  let pixels = FixedArray::make(3 * height * width, b'\x00')
  for j = 0; j < height; j = j + 1 {
    for k = 0; k < width; k = k + 1 {
      let y = pixels_double[0][j][k]
      let cb = pixels_double[1][j][k]
      let cr = pixels_double[2][j][k]
      let (r, g, b) = ycbcr_to_rgb(y, cb, cr)

      let r_clamped = {
        let v = r * 255.0
        if v < 0.0 {
          0.0
        } else if v > 255.0 {
          255.0
        } else {
          v
        }
      }
      let g_clamped = {
        let v = g * 255.0
        if v < 0.0 {
          0.0
        } else if v > 255.0 {
          255.0
        } else {
          v
        }
      }
      let b_clamped = {
        let v = b * 255.0
        if v < 0.0 {
          0.0
        } else if v > 255.0 {
          255.0
        } else {
          v
        }
      }

      let idx = (j * width + k) * 3
      pixels[idx] = r_clamped.to_int().to_byte()
      pixels[idx + 1] = g_clamped.to_int().to_byte()
      pixels[idx + 2] = b_clamped.to_int().to_byte()
    }
  }
  pixels
}

///|
fn apply_dct_to_image(
  pixels_double : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
  quality : Int,
) -> FixedArray[FixedArray[FixedArray[Double]]] {
  let block_size = 8
  let blocks_h = height / block_size
  let blocks_w = width / block_size

  let pixels_dct = FixedArray::makei(3, _ => {
    FixedArray::makei(height, _ => FixedArray::make(width, 0.0))
  })

  for channel = 0; channel < 3; channel = channel + 1 {
    for block_y = 0; block_y < blocks_h; block_y = block_y + 1 {
      for block_x = 0; block_x < blocks_w; block_x = block_x + 1 {
        let block = FixedArray::makei(block_size, _ => {
          FixedArray::make(block_size, 0.0)
        })
        for y = 0; y < block_size; y = y + 1 {
          for x = 0; x < block_size; x = x + 1 {
            let img_y = block_y * block_size + y
            let img_x = block_x * block_size + x
            if img_y < height && img_x < width {
              let pixel_val = if channel == 0 {
                pixels_double[channel][img_y][img_x] * 255.0 - 128.0
              } else {
                (pixels_double[channel][img_y][img_x] - 0.5) * 255.0
              }
              block[y][x] = pixel_val
            }
          }
        }

        let dct_block = dct_2d(block, block_size)
        let variance = calculate_block_variance(block, block_size)
        let base_matrix = get_quantization_matrix()
        let q_matrix = adaptive_quantization_matrix(
          base_matrix, quality, variance, channel,
        )
        let quantized_block = quantize_dct_block(dct_block, q_matrix)

        for y = 0; y < block_size; y = y + 1 {
          for x = 0; x < block_size; x = x + 1 {
            let img_y = block_y * block_size + y
            let img_x = block_x * block_size + x
            if img_y < height && img_x < width {
              pixels_dct[channel][img_y][img_x] = quantized_block[y][x]
            }
          }
        }
      }
    }
  }
  pixels_dct
}

///|
fn apply_dct_raw(
  pixels_double : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
) -> FixedArray[FixedArray[FixedArray[Double]]] {
  let block_size = 8
  let blocks_h = height / block_size
  let blocks_w = width / block_size

  let pixels_dct = FixedArray::makei(3, _ => {
    FixedArray::makei(height, _ => FixedArray::make(width, 0.0))
  })

  for channel = 0; channel < 3; channel = channel + 1 {
    for block_y = 0; block_y < blocks_h; block_y = block_y + 1 {
      for block_x = 0; block_x < blocks_w; block_x = block_x + 1 {
        let block = FixedArray::makei(block_size, _ => {
          FixedArray::make(block_size, 0.0)
        })
        for y = 0; y < block_size; y = y + 1 {
          for x = 0; x < block_size; x = x + 1 {
            let img_y = block_y * block_size + y
            let img_x = block_x * block_size + x
            if img_y < height && img_x < width {
              block[y][x] = pixels_double[channel][img_y][img_x] * 255.0 - 128.0
            }
          }
        }

        let dct_block = dct_2d(block, block_size)

        for y = 0; y < block_size; y = y + 1 {
          for x = 0; x < block_size; x = x + 1 {
            let img_y = block_y * block_size + y
            let img_x = block_x * block_size + x
            if img_y < height && img_x < width {
              pixels_dct[channel][img_y][img_x] = dct_block[y][x]
            }
          }
        }
      }
    }
  }
  pixels_dct
}

///|
fn apply_idct_to_image(
  pixels_dct : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
  quality : Int,
) -> FixedArray[FixedArray[FixedArray[Double]]] {
  let block_size = 8
  let blocks_h = height / block_size
  let blocks_w = width / block_size

  let pixels_idct = FixedArray::makei(3, _ => {
    FixedArray::makei(height, _ => FixedArray::make(width, 0.0))
  })

  for channel = 0; channel < 3; channel = channel + 1 {
    for block_y = 0; block_y < blocks_h; block_y = block_y + 1 {
      for block_x = 0; block_x < blocks_w; block_x = block_x + 1 {
        let quantized_block = FixedArray::makei(block_size, _ => {
          FixedArray::make(block_size, 0.0)
        })
        for y = 0; y < block_size; y = y + 1 {
          for x = 0; x < block_size; x = x + 1 {
            let img_y = block_y * block_size + y
            let img_x = block_x * block_size + x
            if img_y < height && img_x < width {
              quantized_block[y][x] = pixels_dct[channel][img_y][img_x]
            }
          }
        }

        let base_matrix = get_quantization_matrix()
        let q_matrix = scale_quantization_matrix(base_matrix, quality)
        let dequantized_block = dequantize_dct_block(quantized_block, q_matrix)
        let idct_block = idct_2d(dequantized_block, block_size)

        for y = 0; y < block_size; y = y + 1 {
          for x = 0; x < block_size; x = x + 1 {
            let img_y = block_y * block_size + y
            let img_x = block_x * block_size + x
            if img_y < height && img_x < width {
              let pixel_value = if channel == 0 {
                (idct_block[y][x] + 128.0) / 255.0
              } else {
                idct_block[y][x] / 255.0 + 0.5
              }
              pixels_idct[channel][img_y][img_x] = pixel_value
            }
          }
        }
      }
    }
  }
  pixels_idct
}

///|
fn zigzag_order() -> FixedArray[(Int, Int)] {
  [
    (0, 0),
    (0, 1),
    (1, 0),
    (2, 0),
    (1, 1),
    (0, 2),
    (0, 3),
    (1, 2),
    (2, 1),
    (3, 0),
    (4, 0),
    (3, 1),
    (2, 2),
    (1, 3),
    (0, 4),
    (0, 5),
    (1, 4),
    (2, 3),
    (3, 2),
    (4, 1),
    (5, 0),
    (6, 0),
    (5, 1),
    (4, 2),
    (3, 3),
    (2, 4),
    (1, 5),
    (0, 6),
    (0, 7),
    (1, 6),
    (2, 5),
    (3, 4),
    (4, 3),
    (5, 2),
    (6, 1),
    (7, 0),
    (7, 1),
    (6, 2),
    (5, 3),
    (4, 4),
    (3, 5),
    (2, 6),
    (1, 7),
    (2, 7),
    (3, 6),
    (4, 5),
    (5, 4),
    (6, 3),
    (7, 2),
    (7, 3),
    (6, 4),
    (5, 5),
    (4, 6),
    (3, 7),
    (4, 7),
    (5, 6),
    (6, 5),
    (7, 4),
    (7, 5),
    (6, 6),
    (5, 7),
    (6, 7),
    (7, 6),
    (7, 7),
  ]
}

///|
fn run_length_encode(data : FixedArray[Byte]) -> FixedArray[Byte] {
  let mut compressed = []
  let mut i = 0

  while i < data.length() {
    let current = data[i]
    let mut count = 1

    while i + count < data.length() && data[i + count] == current && count < 255 {
      count = count + 1
    }

    if count > 3 || current == b'\x00' {
      compressed = compressed + [b'\xff', count.to_byte(), current]
    } else {
      for j = 0; j < count; j = j + 1 {
        compressed = compressed + [current]
      }
    }
    i = i + count
  }

  let result = FixedArray::make(compressed.length(), b'\x00')
  for i = 0; i < compressed.length(); i = i + 1 {
    result[i] = compressed[i]
  }
  result
}

///|
fn compress_coefficients(
  pixels_dct : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
) -> FixedArray[Byte] {
  let block_size = 8
  let blocks_h = height / block_size
  let blocks_w = width / block_size
  let zigzag = zigzag_order()

  let total_coeffs = blocks_h * blocks_w * 3 * 64
  let raw_data = FixedArray::make(total_coeffs, b'\x00')
  let mut idx = 0

  for block_y = 0; block_y < blocks_h; block_y = block_y + 1 {
    for block_x = 0; block_x < blocks_w; block_x = block_x + 1 {
      for channel = 0; channel < 3; channel = channel + 1 {
        for i = 0; i < 64; i = i + 1 {
          let (y, x) = zigzag[i]
          let img_y = block_y * block_size + y
          let img_x = block_x * block_size + x
          if img_y < height && img_x < width {
            let coeff = pixels_dct[channel][img_y][img_x]
            let quantized = coeff.to_int()
            let clamped = if quantized > 127 {
              127
            } else if quantized < -128 {
              -128
            } else {
              quantized
            }
            raw_data[idx] = clamped.to_byte()
          } else {
            raw_data[idx] = b'\x00'
          }
          idx = idx + 1
        }
      }
    }
  }

  run_length_encode(raw_data)
}

///|
fn save_dct_binary(
  pixels_dct : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
  filename : String,
) -> Unit {
  let data = compress_coefficients(pixels_dct, width, height)

  try {
    @fs.write_bytes_to_file(filename, Bytes::from_array(data))
    println("Saved compressed DCT to \{filename} (\{data.length()} bytes)")
  } catch {
    e =>
      println("Failed to save DCT binary: \{@debug.render(@debug.to_repr(e))}")
  }
}

///|
fn visualize_dct(
  pixels_dct : FixedArray[FixedArray[FixedArray[Double]]],
  width : Int,
  height : Int,
) -> FixedArray[FixedArray[FixedArray[Double]]] {
  let pixels_visual = FixedArray::makei(3, _ => {
    FixedArray::makei(height, _ => FixedArray::make(width, 0.0))
  })

  for channel = 0; channel < 3; channel = channel + 1 {
    let mut min_val = pixels_dct[channel][0][0]
    let mut max_val = pixels_dct[channel][0][0]

    for j = 0; j < height; j = j + 1 {
      for k = 0; k < width; k = k + 1 {
        let val = pixels_dct[channel][j][k]
        if val < min_val {
          min_val = val
        }
        if val > max_val {
          max_val = val
        }
      }
    }

    let range = max_val - min_val
    if range > 0.0 {
      for j = 0; j < height; j = j + 1 {
        for k = 0; k < width; k = k + 1 {
          pixels_visual[channel][j][k] = (pixels_dct[channel][j][k] - min_val) /
            range
        }
      }
    }
  }
  pixels_visual
}

///|
fn main {
  magick_wand_genesis()
  println("Processing image...")

  let wand = magick_wand_new()
  let filename = "examples/peppers.png"
  let filename = @encoding.encode(filename, encoding=UTF8)
  let result = magick_wand_read_image(wand, filename)
  println("Read image: \{result}")

  let width = magick_wand_get_image_width(wand)
  let height = magick_wand_get_image_height(wand)
  println("Image dimensions: \{width}x\{height}")

  let pixels = FixedArray::make(width.to_int() * height.to_int() * 3, b'\x00')
  let result = magick_wand_export_image_pixels(
    wand, 0, 0, width, height, pixels,
  )
  println("Export pixels: \{result}")

  let pixels_double = pixels_to_double(pixels, width.to_int(), height.to_int())

  println("Processing raw DCT (no quantization)...")
  let pixels_dct_raw = apply_dct_raw(
    pixels_double,
    width.to_int(),
    height.to_int(),
  )
  let pixels_dct_visual_raw = visualize_dct(
    pixels_dct_raw,
    width.to_int(),
    height.to_int(),
  )
  let pixels_dct_bytes_raw = double_to_pixels(
    pixels_dct_visual_raw,
    width.to_int(),
    height.to_int(),
  )

  let result = magick_wand_import_image_pixels(
    wand, 0, 0, width, height, pixels_dct_bytes_raw,
  )
  println("Import raw DCT visualization pixels: \{result}")

  let dct_raw_filename = "examples/out/peppers_dct.png"
  let dct_raw_filename = @encoding.encode(dct_raw_filename, encoding=UTF8)
  let result = magick_wand_write_image(wand, dct_raw_filename)
  println("Save raw DCT image: \{result}")

  let quality_levels = [10, 30, 50, 80, 95]

  for i = 0; i < quality_levels.length(); i = i + 1 {
    let quality = quality_levels[i]
    println("Processing quality level: \{quality}...")

    let pixels_dct = apply_dct_to_image(
      pixels_double,
      width.to_int(),
      height.to_int(),
      quality,
    )

    save_dct_binary(
      pixels_dct,
      width.to_int(),
      height.to_int(),
      "examples/out/peppers_compressed_q\{quality}.bin",
    )

    let pixels_dct_visual = visualize_dct(
      pixels_dct,
      width.to_int(),
      height.to_int(),
    )
    let pixels_dct_bytes = double_to_pixels(
      pixels_dct_visual,
      width.to_int(),
      height.to_int(),
    )

    let result = magick_wand_import_image_pixels(
      wand, 0, 0, width, height, pixels_dct_bytes,
    )
    println("Import DCT visualization pixels: \{result}")

    let dct_filename = "examples/out/peppers_dct_q\{quality}.png"
    let dct_filename = @encoding.encode(dct_filename, encoding=UTF8)
    let result = magick_wand_write_image(wand, dct_filename)
    println("Save DCT image (quality \{quality}): \{result}")

    let pixels_idct = apply_idct_to_image(
      pixels_dct,
      width.to_int(),
      height.to_int(),
      quality,
    )
    let pixels_idct_bytes = double_to_pixels(
      pixels_idct,
      width.to_int(),
      height.to_int(),
    )

    let result = magick_wand_import_image_pixels(
      wand, 0, 0, width, height, pixels_idct_bytes,
    )
    println("Import IDCT pixels: \{result}")

    let idct_filename = "examples/out/peppers_compressed_q\{quality}.png"
    let idct_filename = @encoding.encode(idct_filename, encoding=UTF8)
    let result = magick_wand_write_image(wand, idct_filename)
    println("Save compressed image (quality \{quality}): \{result}")
  }

  println("Processing complete!")
  println("Raw DCT image: examples/out/peppers_dct.png")
  println("Generated compressed images with different quality levels:")
  for i = 0; i < quality_levels.length(); i = i + 1 {
    let quality = quality_levels[i]
    println(
      "Quality \{quality}: examples/out/peppers_compressed_q\{quality}.png",
    )
  }

  magick_wand_terminus()
}

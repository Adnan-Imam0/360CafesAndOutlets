class ImageOptimizer {
  /// Optimizes Cloudinary URLs by injecting transformation parameters.
  ///
  /// [url]: The original image URL.
  /// [width]: The desired width in pixels (optional).
  /// [height]: The desired height in pixels (optional).
  ///
  /// Returns the optimized URL or the original if not a Cloudinary URL.
  static String optimize(String? url, {int? width, int? height}) {
    if (url == null || url.isEmpty) return '';

    // Only optimize Cloudinary URLs
    if (!url.contains('res.cloudinary.com')) {
      return url;
    }

    // Default transformations:
    // f_auto: Automatically select best format (WebP/AVIF)
    // q_auto: Automatically adjust quality/compression
    // c_fill: specific crop mode (optional, good for thumbnails)
    List<String> transformations = ['f_auto', 'q_auto'];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (width != null || height != null) transformations.add('c_fill');

    final transformationString = transformations.join(',');

    // Insert parameters after '/upload/'
    // Cloudinary format: .../upload/v12345/id.jpg
    // Optimized: .../upload/f_auto,q_auto,w_300/v12345/id.jpg

    // Check if '/upload/' exists
    final uploadIndex = url.indexOf('/upload/');
    if (uploadIndex == -1) return url;

    // Split and insert
    final start = url.substring(0, uploadIndex + 8); // includes '/upload/'
    final end = url.substring(uploadIndex + 8);

    return '$start$transformationString/$end';
  }
}

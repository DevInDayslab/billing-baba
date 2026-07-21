enum ImageVariant {
  thumbnail('thumbnail'),
  medium('medium'),
  original('original');

  const ImageVariant(this.apiValue);
  final String apiValue;
}

import 'package:billing_baba/shared/media/image_variant.dart';

enum ImageDisplayContext {
  grid(ImageVariant.thumbnail),
  list(ImageVariant.thumbnail),
  galleryThumb(ImageVariant.thumbnail),
  detail(ImageVariant.medium),
  dialog(ImageVariant.medium),
  preview(ImageVariant.medium),
  zoom(ImageVariant.original),
  print(ImageVariant.original);

  const ImageDisplayContext(this.preferredVariant);
  final ImageVariant preferredVariant;
}

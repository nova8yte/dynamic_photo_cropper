import 'dart:ui' as ui;

Future<ui.Image> outImage({
  ui.Image? image,
  required double outWidth,
  required double outHeight,
  required double bottom,
  required double top,
  required double drawX,
  required double drawY,
  required double rotation,
  required double scale,
}) {
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder, ui.Rect.fromLTRB(0, 0, outWidth, outHeight));

  if (image != null) {
    var temp = outHeight / (bottom - top);

    canvas.translate(outWidth / 2 + drawX * temp, outHeight / 2 + drawY * temp);
    canvas.rotate(rotation);
    canvas.scale(scale * temp);
    canvas.drawImage(image, ui.Offset(-image.width / 2, -image.height / 2), ui.Paint());
  }
  ui.Picture picture = recorder.endRecording();
  return picture.toImage(outWidth.toInt(), outHeight.toInt());
}

library image_cropper;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui show Image;
import 'cropper_image_out.dart' if (dart.library.html) 'src/cropper_image_web_out.dart' as imgOut;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';

const Color _defualtMaskColor = Color.fromARGB(160, 0, 0, 0);

class CropperController {
  CropperImageElement? _element;

  rotateImage(double degree) {
    _element!._rotateObject(degree);
  }

  Future<ui.Image>? outImage() {
    return _element?._outImage();
  }
}

class CropperImage extends RenderObjectWidget {
  CropperImage(
    this.image, {
    Key? key,
    this.controller,
    this.limitations = true,
    this.isCircular = false,
    this.backgroundColor = Colors.black,
    this.maskColor = _defualtMaskColor,
    this.lineColor = Colors.white,
    this.lineWidth = 3,
    this.aspectRatio,
    this.outHeight = 256,
    this.outWidth = 256,
    this.maskPadding = 50.0,
    this.round = 30.0,
  }) : super(key: key);

  ///  [ImageProvider] of the cropped image
  final ImageProvider image;

  ///  [bool] border limitations, calculates borders for the image movement (if too big it WON'T RENDER)
  final bool limitations;

  ///  [bool] value used to set output path type
  final bool isCircular;

  ///  [Color] of the background ：Colors.black
  final Color backgroundColor;

  ///  [Color] of the mask ：#00000080
  final Color maskColor;

  ///  [Color] of the mask line ：Colors.white
  final Color lineColor;

  ///  [double] lineWidth：3
  final double lineWidth;

  /// [double] is used as image out/mask aspect ratio value : 2/3
  final double? aspectRatio;

  ///  [double] outWidth is used as cropping : 256

  final double outWidth;

  ///  [double] outHeight is used as cropping : 256

  final double outHeight;

  ///  maskPadding ：50
  final double maskPadding;

  /// [double] round is used as rounding value ：30
  final double round;

  final CropperController? controller;

  @override
  CropperImageElement createElement() {
    return CropperImageElement(this);
  }

  @override
  CropperImageRender createRenderObject(BuildContext context) {
    return CropperImageRender()
      ..limitations = limitations
      ..isCircular = isCircular
      ..backgroundColor = backgroundColor
      ..maskColor = maskColor
      ..lineColor = lineColor
      ..lineWidth = lineWidth
      ..aspectRatio = aspectRatio
      ..outWidth = outWidth
      ..outHeight = outHeight
      ..maskPadding = maskPadding
      ..round = round;
  }

  @override
  void updateRenderObject(BuildContext context, CropperImageRender renderObject) {
    renderObject
      ..limitations = limitations
      ..isCircular = isCircular
      ..backgroundColor = backgroundColor
      ..maskColor = maskColor
      ..lineColor = lineColor
      ..lineWidth = lineWidth
      ..aspectRatio = aspectRatio
      ..outWidth = outWidth
      ..outHeight = outHeight
      ..maskPadding = maskPadding
      ..round = round;
    renderObject.markNeedsPaint();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('image', image));
    properties.add(DiagnosticsProperty<bool>('limitations', limitations));
    properties.add(DiagnosticsProperty<bool>('isCircular', isCircular));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('maskColor', maskColor));
    properties.add(ColorProperty('lineColor', lineColor));
    properties.add(DoubleProperty('lineWidth', lineWidth));
    properties.add(DoubleProperty("aspectRatio", aspectRatio));
    properties.add(DoubleProperty('outWidth', outWidth));
    properties.add(DoubleProperty('outHeight', outHeight));
    properties.add(DoubleProperty('maskPadding', maskPadding));
    properties.add(DoubleProperty('round', round));
  }
}

class CropperImageElement extends RenderObjectElement {
  ImageProvider? _image;

  CropperImageElement(CropperImage widget) : super(widget);

  @override
  CropperImageRender get renderObject => super.renderObject as CropperImageRender;

  @override
  CropperImage get widget => super.widget as CropperImage;

  @override
  void forgetChild(Element child) {
    assert(null == child);
  }

  @override
  void insertChildRenderObject(RenderObject child, slot) {}

  @override
  void moveChildRenderObject(RenderObject child, slot) {}

  @override
  void removeChildRenderObject(RenderObject child) {}

  void _resolveImage() {
    if (null == _image) {
      return;
    }
    final ImageStream stream = _image!.resolve(createLocalImageConfiguration(this));
    late var listener;
    listener = ImageStreamListener((image, synchronousCall) {
      renderObject.image = image.image;
      stream.removeListener(listener);
    }, onError: (exception, stackTrace) {
      stream.removeListener(listener);
    });
    stream.addListener(listener);
  }

  @override
  void update(CropperImage newWidget) {
    super.update(newWidget);
    if (_image != newWidget.image) {
      _image = widget.image;
      _resolveImage();
    }
    newWidget.controller?._element = this;
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _image = widget.image;
    widget.controller?._element = this;
    _resolveImage();
  }

  _rotateObject(double deegree) => renderObject.updateRotation(deegree);

  Future<ui.Image> _outImage() {
    return imgOut.outImage(
      image: renderObject.image,
      outWidth: widget.outWidth,
      outHeight: widget.outHeight,
      bottom: renderObject.bottom,
      top: renderObject.top,
      drawX: renderObject.drawX,
      drawY: renderObject.drawY,
      rotation: renderObject.rotation,
      scale: renderObject.scale,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('_image', _image));
  }
}

class Pointer {
  final int? device;
  final double? dx;
  final double? dy;

  Pointer({this.device, this.dx, this.dy});

  @override
  String toString() {
    return 'Pointer{device: $device, dx: $dx, dy: $dy}';
  }
}

class CropperImageRender extends RenderProxyBox {
  ui.Image? _image;
  bool _limitations = true;

  set limitations(bool value) {
    _limitations = value;
    if (_limitations) {
      rotation = 0;
    }
  }

  bool get limitations => _limitations;

  bool isCircular = false;
  double backBoxSize = 10.0;
  Color backgroundColor = Colors.black;
  Color maskColor = Color.fromARGB(80, 0, 0, 0);
  Color lineColor = Colors.white;
  double lineWidth = 3;
  double? aspectRatio = 2 / 3;
  double outWidth = 256.0;
  double outHeight = 256.0;
  double maskPadding = 20.0;
  double round = 8.0;

  double scale = 0;
  late double centerX;
  late double centerY;
  double drawX = 0;
  double drawY = 0;
  late double bottom;
  late double left;
  late double right;
  late double top;
  double rotation = 0;

  Pointer? _old1, _old2, _new1, _new2;

  set image(ui.Image? image) {
    _image = image;
    markNeedsPaint();
  }

  num toRadian(num degrees) => (degrees * math.pi) / 180;

  num toDegrees(num radian) => (radian * 180.0) / math.pi;

  updateRotation(double degrees) {
    double currentRotation = toDegrees(this.rotation) as double;
    double newRotation = toRadian(degrees) as double;
    this.rotation = this.rotation + newRotation;

    markNeedsPaint();
  }

  ui.Image? get image => _image;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerScrollEvent) {
      handleScrollEvent(event);
    } else if (event is PointerDownEvent) {
      handleDownEvent(event);
    } else if (event is PointerMoveEvent) {
      handleMoveEvent(event);
    } else if (event is PointerUpEvent) {
      handleUpEvent(event);
    }
  }

  void handleScrollEvent(PointerScrollEvent event) {
    if (null == _old1 && null == _old2) {
      if (event.scrollDelta.dy < 0) {
        scale -= 0.05;
      } else if (event.scrollDelta.dy > 0) {
        scale += 0.05;
      }
    } else if (!limitations) {
      if (event.scrollDelta.dy < 0) {
        rotation -= 0.05;
      } else if (event.scrollDelta.dy > 0) {
        rotation += 0.05;
      }
    }
    markNeedsPaint();
  }

  void handleDownEvent(PointerDownEvent event) {
    if (null == _old1 && _old2?.device != event.device) {
      _old1 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    } else if (null == _old2 && _old1!.device != event.device) {
      _old2 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    }
  }

  void handleMoveEvent(PointerMoveEvent event) {
    if (_old1?.device == event.device) {
      _new1 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    } else if (_old2?.device == event.device) {
      _new2 = Pointer(device: event.device, dx: event.position.dx, dy: event.position.dy);
    }

    if (null != _old1 && null != _old2 && null != _new1 && null != _new2) {
      var newLine = math.sqrt(math.pow(_new1!.dx! - _new2!.dx!, 2) + math.pow(_new1!.dy! - _new2!.dy!, 2));
      var oldLine = math.sqrt(math.pow(_old1!.dx! - _old2!.dx!, 2) + math.pow(_old1!.dy! - _old2!.dy!, 2));
      this.scale *= (newLine / oldLine);

      this.drawX += ((_new1!.dx! - _old1!.dx!) + (_new2!.dx! - _old2!.dx!)) / 2;
      this.drawY += ((_new1!.dy! - _old1!.dy!) + (_new2!.dy! - _old2!.dy!)) / 2;

      if (!limitations) {
        var k1 = (_old1!.dx! - _old2!.dx!) / (_old1!.dy! - _old2!.dy!);
        var k2 = (_new1!.dx! - _new2!.dx!) / (_new1!.dy! - _new2!.dy!);

        var temp = ((k2 - k1) / (1 + k1 * k2) * math.pi / 2);
        if (!temp.isNaN) {
          this.rotation -= temp;
        }
      }
      markNeedsPaint();
    } else if ((null != _old1 && null != _new1) || (null != _old2 && null != _new2)) {
      this.drawX += ((_new1 ?? _new2)!.dx! - (_old1 ?? _old2)!.dx!);
      this.drawY += ((_new1 ?? _new2)!.dy! - (_old1 ?? _old2)!.dy!);
      markNeedsPaint();
    }
    if (_old1?.device == event.device) {
      _old1 = _new1;
    } else if (_old2?.device == event.device) {
      _old2 = _new2;
    }
  }

  void handleUpEvent(PointerUpEvent event) {
    if (_old1?.device == event.device) {
      _old1 = _new1 = null;
    } else if (_old2?.device == event.device) {
      _old2 = _new2 = null;
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void performLayout() {}

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size == Size.zero) {
      return;
    }
    var canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
//    canvas.drawColor(Colors.blue, BlendMode.color);
    _onPadding(size);
    _createBack(canvas, size);
    if (null != _image) {
      _onPosition();
      canvas.save();
      canvas.translate(centerX + drawX, centerY + drawY);
      canvas.rotate(rotation);
      canvas.scale(scale);
      canvas.drawImage(_image!, Offset(-_image!.width / 2, -_image!.height / 2), Paint());
      canvas.restore();
    }

    _craeteMask(canvas, size);
    canvas.restore();
  }

  _createBack(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = backgroundColor);
  }

  _craeteMask(Canvas canvas, Size size) {
    if (isCircular) {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addOval(Rect.fromLTRB(left, top, right, bottom))
            ..close(),
          Paint()
            ..color = maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addOval(Rect.fromLTRB(left, top, right, bottom))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke);
    } else {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addRRect(RRect.fromLTRBXY(left, top, right, bottom, round, round))
            ..close(),
          Paint()
            ..color = maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addRRect(RRect.fromLTRBXY(left, top, right, bottom, round, round))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke);
    }
  }

  _onPadding(Size size) {
    var fw = size.width / outWidth;
    var fh = size.height / outHeight;
    if (fw > fh) {
      fw = fh;
    }
    var width = outWidth * fw / 2 - maskPadding;
    var height = outHeight * fw / 2 - maskPadding;
    centerX = size.width / 2;
    centerY = size.height / 2;
    left = centerX - width;
    right = centerX + width;
    top = centerY - height;
    bottom = centerY + height;
  }

  _onPosition() {
    if (limitations) {
      if (5 < scale) {
        scale = 5;
      }

      var fw = (right - left) / _image!.width;
      var fh = (bottom - top) / _image!.height;
      if (fw < fh) {
        fw = fh;
      }
      if (scale < fw) {
        scale = fw;
      }

      var width = _image!.width * scale / 2;
      if (left < centerX + drawX - width) {
        drawX = left - centerX + width;
      }
      if (right > centerX + drawX + width) {
        drawX = right - centerX - width;
      }

      var height = _image!.height * scale / 2;
      if (top < centerY + drawY - height) {
        drawY = top - centerY + height;
      }
      if (bottom > centerY + drawY + height) {
        drawY = bottom - centerY - height;
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('limitations', limitations));
    properties.add(DiagnosticsProperty<bool>('isCircular', isCircular));
    properties.add(DoubleProperty('backBoxSize', backBoxSize));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('maskColor', maskColor));
    properties.add(ColorProperty('lineColor', lineColor));
    properties.add(DoubleProperty('lineWidth', lineWidth));
    properties.add(DoubleProperty('outWidth', outWidth));
    properties.add(DoubleProperty('outHeight', outHeight));
    properties.add(DoubleProperty('maskPadding', maskPadding));
    properties.add(DoubleProperty('round', round));
  }
}

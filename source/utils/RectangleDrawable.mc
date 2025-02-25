import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class RectangleDrawable extends WatchUi.Drawable {
  private var _screenShape as System.ScreenShape =
    System.getDeviceSettings().screenShape;

  private var _relativeX as Float?;
  private var _relativeY as Float?;
  private var _relativeWidth as Float?;
  private var _relativeHeight as Float?;
  private var _color as Number;

  function setColor(color as Number) {
    self._color = color;
  }

  function initialize(params as Dictionary?) {
    Drawable.initialize(params);

    self._relativeX = params.get(:relativeX) as Float?;
    self._relativeY = params.get(:relativeY) as Float?;
    self._relativeWidth = params.get(:relativeWidth) as Float?;
    self._relativeHeight = params.get(:relativeHeight) as Float?;

    var color = params.get(:color) as Number?;
    self._color = color ? color : Graphics.COLOR_WHITE;
  }

  function draw(dc as Dc) {
    var screenWidth = dc.getWidth();
    var screenHeight = dc.getHeight();
    if (_relativeX != null) {
      locX = Math.round(screenWidth * _relativeX);
    }

    if (_relativeY != null) {
      locY = Math.round(screenHeight * _relativeY);
    }

    if (_relativeWidth != null) {
      width = Math.round(screenWidth * _relativeWidth);
    }

    if (_relativeHeight != null) {
      height = Math.round(screenHeight * _relativeHeight);
    }

    dc.setColor(self._color, Graphics.COLOR_TRANSPARENT);
    if (_screenShape == System.SCREEN_SHAPE_RECTANGLE) {
      dc.fillRoundedRectangle(
        locX,
        locY,
        width,
        height,
        Math.round(screenWidth * 0.025)
      );
    } else {
      dc.fillRectangle(locX, locY, width, height);
    }
  }
}

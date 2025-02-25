import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class RectangleDrawable extends WatchUi.Drawable {
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
      locX = screenWidth * _relativeX;
    }

    if (_relativeY != null) {
      locY = screenHeight * _relativeY;
    }

    if (_relativeWidth != null) {
      width = screenWidth * _relativeWidth;
    }

    if (_relativeHeight != null) {
      height = screenHeight * _relativeHeight;
    }

    dc.setColor(self._color, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(locX, locY, width, height);
  }
}

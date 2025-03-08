import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class AQIcaBaseView extends WatchUi.View {
  // Screen
  private var _screenShape as System.ScreenShape =
    System.getDeviceSettings().screenShape;
  private var _screenWidth as Float =
    System.getDeviceSettings().screenWidth.toFloat();
  private var _screenHeight as Float =
    System.getDeviceSettings().screenHeight.toFloat();

  // Page indicator properties
  private var _fancyScroll as Boolean?;
  private var _index as Number?;
  private var _totalPages as Number?;
  private var _currentSystemTimerMs as Number = 0;

  private var _x as Number = Math.ceil(_screenWidth / 20).toNumber();
  private var _y as Number = Math.ceil(_screenHeight / 3.25).toNumber();
  private var _spacingY as Number = Math.round(_screenHeight / 8).toNumber();
  private var _outerRadius as Number = Math.round(_screenWidth / 31).toNumber();
  private var _innerRadius as Number = Math.round(_screenWidth / 39).toNumber();
  private var _borderWidth as Number = Math.round(_screenWidth / 78).toNumber();
  private var _foreground_color as Number = Graphics.COLOR_WHITE;
  private var _background_color as Number = Graphics.COLOR_BLACK;

  function initialize(index as Number?, totalPages as Number?) {
    self._fancyScroll =
      Application.Properties.getValue("FancyScroll") as Boolean?;
    self._index = index;
    self._totalPages = totalPages;

    if (_screenShape == System.SCREEN_SHAPE_ROUND) {
      _x = Math.round(_x * 1.8).toNumber();
    }

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    if (_fancyScroll != null && _fancyScroll) {
      _currentSystemTimerMs = System.getTimer();
    }
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    if (_index == null || _totalPages == null) {
      return;
    }

    if (_fancyScroll != null && _fancyScroll) {
      if (System.getTimer() - _currentSystemTimerMs >= 400) {
        return;
      }

      var tmpY = _y;
      for (var i = 0; i < _totalPages; i++) {
        // Border
        dc.setColor(_background_color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_x, tmpY, _outerRadius + _borderWidth);

        // Outer fill
        dc.setColor(_foreground_color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_x, tmpY, _outerRadius);

        if (i != _index) {
          // Inner fill
          dc.setColor(_background_color, Graphics.COLOR_TRANSPARENT);
          dc.fillCircle(_x, tmpY, _innerRadius);
        }

        tmpY += _spacingY;
      }
    } else {
      drawPageDownTriangle(dc);
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  private function drawPageDownTriangle(dc as Graphics.Dc) {
    var sizeFactor = Math.floor(dc.getWidth() / 100).toNumber();
    var pointX = dc.getWidth() * 0.5;
    var pointY = dc.getHeight() * 0.99;

    // Create the polygon points array
    var points = [
      [pointX - 4 * sizeFactor, pointY - 4 * sizeFactor],
      [pointX + 4 * sizeFactor, pointY - 4 * sizeFactor],
      [pointX, pointY],
    ];

    // Draw the triangle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon(points);

    // Draw the triangle outline (so it is visible if it goes outside of the chart)
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(points[0][0] - 1, points[0][1], points[1][0] + 1, points[1][1]);
    dc.drawLine(points[1][0] + 1, points[1][1], points[2][0], points[2][1] + 1);
    dc.drawLine(points[2][0], points[2][1] + 1, points[0][0] - 1, points[0][1]);
  }
}

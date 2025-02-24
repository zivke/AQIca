import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class AQIcaBaseView extends WatchUi.View {
  // Screen size
  private var _screenWidth as Float =
    System.getDeviceSettings().screenWidth.toFloat();
  private var _screenHeight as Float =
    System.getDeviceSettings().screenHeight.toFloat();

  // Page indicator properties
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
    self._index = index;
    self._totalPages = totalPages;

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    _currentSystemTimerMs = System.getTimer();
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    if (_index == null || _totalPages == null) {
      return;
    }

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
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}

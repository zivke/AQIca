import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class AQIcaBaseView extends WatchUi.View {
  private var _index as Number?;
  private var _totalPages as Number?;
  private var _showPageIndicator = true;

  private var _timer as Timer.Timer;

  function initialize(index as Number?, totalPages as Number?) {
    self._index = index;
    self._totalPages = totalPages;

    View.initialize();

    _timer = new Timer.Timer();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    if (_index == null || _totalPages == null) {
      return;
    }

    if (_showPageIndicator == false) {
      _showPageIndicator = true;
      return;
    }

    _timer.start(method(:erasePageIndicator), 500, false);

    var x = 10;
    var y = 55;
    var spacingY = 20;
    var outer_radius = 5;
    var inner_radius = 4;
    var border_width = 2;
    var foreground_color = Graphics.COLOR_WHITE;
    var background_color = Graphics.COLOR_BLACK;

    for (var i = 0; i < _totalPages; i++) {
      // Border
      dc.setColor(background_color, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(x, y, outer_radius + border_width);

      // Outer fill
      dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(x, y, outer_radius);

      if (i != _index) {
        // Inner fill
        dc.setColor(background_color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, inner_radius);
      }

      y += spacingY;
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {
    _timer.stop();
  }

  function erasePageIndicator() as Void {
    _showPageIndicator = false;
    WatchUi.requestUpdate();
  }
}

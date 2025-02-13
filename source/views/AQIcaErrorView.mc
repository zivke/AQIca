import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaErrorView extends WatchUi.View {
  private var _text as String;

  function initialize(message as String?) {
    self._text = message != null ? message : "Unknown error";

    View.initialize();
  }

  function onLayout(dc as Dc) as Void {}

  function onShow() as Void {}

  function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var errorString = new WatchUi.TextArea({
      :text => _text,
      :backgroundColor => Graphics.COLOR_BLACK,
      :color => Graphics.COLOR_WHITE,
      :font => Graphics.FONT_MEDIUM,
      :justification => Graphics.TEXT_JUSTIFY_CENTER |
      Graphics.TEXT_JUSTIFY_VCENTER,
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :width => dc.getWidth() * 0.8,
      :height => dc.getHeight() * 0.8,
    });
    errorString.draw(dc);
  }

  function onHide() as Void {}
}

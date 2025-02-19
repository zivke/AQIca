import Toybox.Graphics;
import Toybox.WatchUi;

class AQIcaDetailsView extends WatchUi.View {
  private var _aqiData as AqiData;

  function initialize(aqiData as AqiData) {
    self._aqiData = aqiData;

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
    dc.clear();

    var errorString = new WatchUi.Text({
      :text => "BLABLABLA",
      :color => Graphics.COLOR_WHITE,
      :font => Graphics.FONT_SMALL,
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
    });
    errorString.draw(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}
}

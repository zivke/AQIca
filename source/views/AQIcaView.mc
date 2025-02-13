import Toybox.Graphics;
import Toybox.WatchUi;

class AQIcaView extends WatchUi.View {
  private var _aqiData as AqiData?;

  function initialize(aqiData as AqiData) {
    self._aqiData = aqiData;

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Set the AQI label value
    var aqiLabel = View.findDrawableById("AqiValue") as Text?;
    if (aqiLabel != null) {
      if (_aqiData.getAqi() != null) {
        aqiLabel.setText(_aqiData.getAqi().format("%d").toString());
      }
    }

    // Set the PM 2.5 label value
    var pm25Label = View.findDrawableById("Pm25Value") as Text?;
    if (pm25Label != null) {
      if (_aqiData.getPm25() != null) {
        pm25Label.setText(_aqiData.getPm25().format("%d").toString());
      }
    }

    // Set the PM 10 label value
    var pm10Label = View.findDrawableById("Pm10Value") as Text?;
    if (pm10Label != null) {
      if (_aqiData.getPm10() != null) {
        pm10Label.setText(_aqiData.getPm10().format("%d").toString());
      }
    }

    // Set the City label value
    var cityTextArea = View.findDrawableById("CityValue") as Text?;
    if (cityTextArea != null) {
      cityTextArea.setText(_aqiData.getCity());
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}

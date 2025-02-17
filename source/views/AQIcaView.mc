import Toybox.Graphics;
import Toybox.Lang;
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
      var iaqi = _aqiData.getIaqi();
      if (iaqi != null) {
        if (iaqi.hasKey("pm25")) {
          var pm25 = iaqi.get("pm25") as Dictionary;
          if (pm25.hasKey("v")) {
            var pm25Value = pm25.get("v") as Number;
            pm25Label.setText(pm25Value.format("%d").toString());
          }
        }
      }
    }

    // Set the PM 10 label value
    var pm10Label = View.findDrawableById("Pm10Value") as Text?;
    if (pm10Label != null) {
      var iaqi = _aqiData.getIaqi();
      if (iaqi != null) {
        if (iaqi.hasKey("pm10")) {
          var pm10 = iaqi.get("pm10") as Dictionary;
          if (pm10.hasKey("v")) {
            var pm10Value = pm10.get("v") as Number;
            pm10Label.setText(pm10Value.format("%d").toString());
          }
        }
      }
    }

    // Set the City label value
    var stationNameTextArea =
      View.findDrawableById("StationNameValue") as Text?;
    if (stationNameTextArea != null) {
      stationNameTextArea.setText(_aqiData.getStationName());
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}

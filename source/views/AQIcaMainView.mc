import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaMainView extends WatchUi.View {
  private var _aqiData as AqiData;

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

    // Set the Air Pollution Level label value
    var aplLabel = View.findDrawableById("AirPollutionLevelLabel") as Text?;
    if (aplLabel != null) {
      aplLabel.setText(getAirPollutionLevelLabel(_aqiData.getAqi()));
    }

    // Set the PM 2.5 label value
    var pm25Label = View.findDrawableById("Pm25Value") as Text?;
    if (pm25Label != null && _aqiData.getPm25() != null) {
      pm25Label.setText(_aqiData.getPm25().format("%d").toString());
    }

    // Set the PM 10 label value
    var pm10Label = View.findDrawableById("Pm10Value") as Text?;
    if (pm10Label != null && _aqiData.getPm10() != null) {
      pm10Label.setText(_aqiData.getPm10().format("%d").toString());
    }

    // Set the station distance label value
    var distanceLabel = View.findDrawableById("DistanceValue") as Text?;
    var distanceKm = _aqiData.getStationDistanceKm();
    if (distanceLabel != null && distanceKm != null) {
      if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
        var distanceMi = distanceKm / 1.609344;
        distanceLabel.setText(distanceMi.format("%.1f").toString() + "mi");
      } else {
        distanceLabel.setText(distanceKm.format("%.1f").toString() + "km");
      }
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  private function getAirPollutionLevelLabel(aqi as Number?) as String {
    if (aqi == null || aqi < 0) {
      return "Unknown";
    } else if (aqi <= 50) {
      return "Good";
    } else if (aqi <= 100) {
      return "Moderate";
    } else if (aqi <= 150) {
      return "Sensitive";
    } else if (aqi <= 200) {
      return "Unhealthy";
    } else if (aqi <= 300) {
      return "V. Unhealthy";
    } else {
      return "Hazardous";
    }
  }
}

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaDetailsView extends AQIcaBaseView {
  private var _aqiData as AqiData;

  function initialize(
    aqiData as AqiData,
    index as Number?,
    totalPages as Number?
  ) {
    self._aqiData = aqiData;

    AQIcaBaseView.initialize(index, totalPages);
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.DetailsLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    AQIcaBaseView.onShow();
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Set the dominant pollutant label value
    var dominantPollutantLabel =
      View.findDrawableById("DominantPollutantValue") as Text?;
    if (dominantPollutantLabel != null) {
      dominantPollutantLabel.setText(_aqiData.getDominantPollutant());
    }

    // Set the CO label value
    var coLabel = View.findDrawableById("CoValue") as Text?;
    if (coLabel != null) {
      if (_aqiData.getCo() != null) {
        coLabel.setText(_aqiData.getCo().format("%.1f").toString());
      }
    }

    // Set the NO2 label value
    var no2Label = View.findDrawableById("No2Value") as Text?;
    if (no2Label != null) {
      if (_aqiData.getNo2() != null) {
        no2Label.setText(_aqiData.getNo2().format("%.1f").toString());
      }
    }

    // Set the O3 label value
    var o3Label = View.findDrawableById("O3Value") as Text?;
    if (o3Label != null) {
      if (_aqiData.getO3() != null) {
        o3Label.setText(_aqiData.getO3().format("%.1f").toString());
      }
    }

    // Set the SO2 label value
    var so2Label = View.findDrawableById("So2Value") as Text?;
    if (so2Label != null) {
      if (_aqiData.getSo2() != null) {
        so2Label.setText(_aqiData.getSo2().format("%.1f").toString());
      }
    }

    // Call the parent onUpdate function to redraw the layout
    AQIcaBaseView.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}
}

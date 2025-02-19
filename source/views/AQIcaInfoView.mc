import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;

class AQIcaInfoView extends WatchUi.View {
  private var _aqiData as AqiData;

  function initialize(aqiData as AqiData) {
    self._aqiData = aqiData;

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.InfoLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    if (_aqiData.getStatus().getCode() == Status.DONE) {
      WatchUi.switchToView(
        new AQIcaMainView(_aqiData),
        null,
        WatchUi.SLIDE_IMMEDIATE
      );
    }

    // Set the info title
    var infoTitleLabel = View.findDrawableById("InfoTitle") as Text?;
    if (infoTitleLabel != null) {
      var infoTitle = "INFO";
      if (_aqiData.getStatus().hasError()) {
        infoTitle = "ERROR";
      }
      infoTitleLabel.setText(infoTitle);
    }

    // Set the info text area value
    var infoTextArea = View.findDrawableById("InfoMessageValue") as Text?;
    if (infoTextArea != null) {
      infoTextArea.setText(_aqiData.getStatus().getMessage());
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}
}

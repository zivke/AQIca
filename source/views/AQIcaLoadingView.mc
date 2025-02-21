import Toybox.Graphics;
import Toybox.WatchUi;

class AQIcaLoadingView extends WatchUi.View {
  private var _aqiData as AqiData;
  private var _viewLoop as AQIcaViewLoop?;

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
        _viewLoop = new AQIcaViewLoop([
          new AQIcaMainView(_aqiData),
          new AQIcaDetailsView(_aqiData),
          new AQIcaInfoView("Measuring\nstation:", _aqiData.getStationName()),
          new AQIcaInfoView("Data\nsource:", _aqiData.getAttributions()),
        ]);
        _viewLoop.show();
    } else {
      var title;
      if (_aqiData.getStatus().hasError()) {
        title = "ERROR";
      } else {
        title = "INFO";
      }

      // Set the info title
      var infoTitleLabel = View.findDrawableById("InfoTitle") as Text?;
      if (infoTitleLabel != null) {
        infoTitleLabel.setText(title);
      }

      // Set the info text area value
      var infoTextArea = View.findDrawableById("InfoMessageValue") as TextArea?;
      if (infoTextArea != null) {
        infoTextArea.setText(_aqiData.getStatus().getMessage());
      }

      // Call the parent onUpdate function to redraw the layout
      View.onUpdate(dc);
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}

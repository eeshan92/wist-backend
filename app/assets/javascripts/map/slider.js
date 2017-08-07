$(function() {
  var el, newPoint, newPlace, offset;
   
  // Select all range inputs, watch for change
  $("input[type='range']").change(function() {

  // Cache this for efficiency
  el = $(this);

  // Measure width of range input
  width = el.width();

  // Figure out placement percentage between left and right of input
  newPoint = (el.val() - el.attr("min")) / (el.attr("max") - el.attr("min"));

  offset = -1;

  // Prevent bubble from going beyond left or right (unsupported browsers)
  if (newPoint < 0) { newPlace = 0; }
  else if (newPoint > 1) { newPlace = width; }
  else { newPlace = width * newPoint + offset; offset -= newPoint; }

  var today = new Date().setHours(0,0,0,0),
      time = new Date(today + (el.val() * 60000)),
      options = { hour: "2-digit", minute: "2-digit"};

  // Move bubble
  el
    .next("output")
    .css({
      left: newPlace,
      marginLeft: offset + "%"
    })
    .text(time.toLocaleTimeString('en-US', options));
  })

  // Fake a change to position bubble at page load
  .trigger('change');
});

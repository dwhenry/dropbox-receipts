$(function() {
  function readURL(input) {

    if (input.files && input.files[0]) {
      var reader = new FileReader();

      reader.onload = function (e) {
        $('.image-preview').attr('src', e.target.result);
      };

      reader.readAsDataURL(input.files[0]);
    }
  }

  $(".image-input").change(function () {
    readURL(this);
    var path = $(this).val().split('\\');

    $(this).next('.custom-file-control').addClass("selected").html(path[path.length-1]);
  });

  $(".image-save").click(function() {
    var handler, xhr;
    handler = function(event) {
      var _status = event.target.status;
      var _response = event.target.responseText;
      if (_status >= 200 && _status < 300) {
        $('.camera-actions').html(_response);
        return { status: 'success', response: _response }
      } else {
        var _error = event.target.statusText || "Unknown error";
        return { status: 'error', response: _response, error: _error }
      }
    };

    var ajax = new XMLHttpRequest();
    ajax.open('POST', '/receipts');
    ajax.timeout = 0;
    var csrf_token = $('meta[name="csrf-token"]').attr("content");
    if (csrf_token) {
      ajax.setRequestHeader("X-CSRF-Token", csrf_token);
    }
    ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    ajax.onload = handler;
    ajax.onerror = handler;
    ajax.onabort = handler;
    ajax.send("img_data="+$('.image-preview').attr('src'));
  });
});

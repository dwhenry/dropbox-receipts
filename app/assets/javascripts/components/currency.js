$(function() {
  $('.currency').change(function() {
    $(this).val(parseFloat($(this).val()).toFixed(2));
  });
});

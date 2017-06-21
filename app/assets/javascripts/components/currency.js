$(function() {
  $('body').on('change', '.currency', function() {
    $(this).val(parseFloat($(this).val()).toFixed(2));
  });
});

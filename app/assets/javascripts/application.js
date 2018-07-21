// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require tether
//= require bootstrap

//= require_tree ./theme
//= require ./components/currency
//= require ./components/file_uploader
//= require ./components/jpeg_camera.js
//= require select2-full

$(".enhanced-select").select2({
  theme: "bootstrap"
});

$(".enhanced-combo").select2({
  theme: "bootstrap",
  tags: true
});

$(".new-link").click(function(e) {
  e.preventDefault();
  window.location = $(this).data('href');
  return false;
});

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
//= require_tree .

// $(function(){
//   $('.tag-input').tokenInput('/autocomplete/tag.json', {
//     tokenValue: 'name',
//     preventDuplicates: true,
//   });
// });
$(function(){
  $('.script-only').removeClass('script-only');
});
//
// $(function(){
//   $('.source-input').tokenInput('/autocomplete/source.json', {
//     //use name rather than id because otherwise we have trouble handling newly
//     //created tags
//     tokenValue: 'name',
//     preventDuplicates: true
//   });
// });

$(document).ready(function(){
  $('.click_dropdown_header').click(function() {
    // $(this).siblings('.hidden').toggle('fold', 1000);
    // window.alert('called');
    // var sibs1 = $(this).siblings('.hidden');
    // var sibs2 = $(this).siblings('.not-hidden');
    // window.alert(sibs.length);
    // sibs1.toggleClass('hidden not-hidden');
    // sibs2.toggleClass('hidden not-hidden');
    // var sibs = $(this).siblings('.hidden');
    // window.alert(sibs.length);
    // sibs.toggle('fold', 1000);
    $(this).toggleClass('hide-header');
  });
});

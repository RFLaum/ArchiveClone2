$(document).ready(function(){
  $("#user_delete_avatar").change(function(){
    inputToggle($('#user_avatar'), $(this).is(':checked'));
  });

  $('#user_avatar').change(function(){
    inputToggle($('#user_delete_avatar'), $(this).prop('files').length > 0);
  });
});

function inputToggle(elt, disabled){
  elt.prop('disabled', disabled);
  var labelFor = $("label[for='" + elt.prop('id') + "']");
  if (disabled){
    labelFor.addClass('disabled');
    elt.addClass('disabled');
  }
  else {
    labelFor.removeClass('disabled');
    elt.removeClass('disabled');
  }
}

(function(){

var html5upload = false;

var self = spud.admin.photos = {
  init: function(){
    // event handlers
    $('.spud_admin_photo_ui_thumbs_sortable').sortable({
      connectWith:'.spud_admin_photo_ui_thumbs_sortable'
    });
    $('body').on('submit', '#spud_admin_photo_album_form', submittedPhotoAlbumForm);
    $('body').on('submit', '#spud_admin_photo_gallery_form', submittedPhotoGalleryForm);
    $('body').on('submit', '#spud_admin_photo_form', submittedPhotoForm);
    $('body').on('click', '.spud_admin_photos_btn_remove', clickedPhotoRemoveFromAlbum);
    $('body').on('click', '.spud_admin_photo_ui_thumbs_selectable .spud_admin_photo_ui_thumb', selectedPhotoUiThumb);
    $('body').on('click', '#spud_admin_photo_album_action_library', clickedPhotoLibrary);
    $('body').on('click', '#spud_admin_photo_album_action_upload, .spud_admin_photo .spud_admin_photos_btn_edit', clickedPhotoAddOrEdit);
    $('body').on('click', '.spud_admin_photo_library_add_selected', addSelectedPhotosFromLibrary);
    $('body').on('click', '.spud_admin_photo_library_delete_selected', deleteSelectedPhotosFromLibrary);

    // html5 drag and drop file
    if(typeof(FormData) != 'undefined' && typeof(XMLHttpRequest) != 'undefined' && (droparea = document.getElementById('spud_admin_photo_upload_queue'))){
      html5upload = true;
      $('#spud_admin_photo_upload_queue').show();
      droparea.addEventListener('dragenter', stopDndPropagation, false);
      droparea.addEventListener('dragexit', stopDndPropagation, false);
      droparea.addEventListener('dragover', stopDndPropagation, false);
      droparea.addEventListener('drop', droppedFile, false);

      // prevent accidental drops outside the queue
      var body = document.getElementsByTagName("body")[0];
      body.addEventListener('dragenter', stopDndPropagation, false);
      body.addEventListener('dragexit', stopDndPropagation, false);
      body.addEventListener('dragover', stopDndPropagation, false);
      body.addEventListener('drop', stopDndPropagation, false);
    }
  },

  getFileSizeHumanized: function(bytes) {
    var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if(bytes === 0){
      return 'n/a';
    }
    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)), 10);
    return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
  },

  /* Handle file uploads passed via iframe (legacy support)
  * -------------------------------------------------------- */
  photoLegacyUploadErrors: function(html){
    $('#spud_admin_photo_form').replaceWith(html);
  },

  photoLegacyUploadComplete: function(id, html){
    var element = $('#spud_admin_photo_' + id);
    if(element.length > 0){
      element.replaceWith(html);
    }
    else{
      var target = $('#spud_admin_photos_selected, #spud_admin_photos');
      target.prepend(html);
    }
    spud.admin.modal.hide();
  }
};

var submittedPhotoAlbumForm = function(e){

};

var submittedPhotoGalleryForm = function(e){
  $('#spud_admin_photo_albums_available .spud_admin_photo_ui_thumb').remove();
};

var clickedPhotoRemoveFromAlbum = function(e){
  $(this).parents('.spud_admin_photo_ui_thumb').fadeOut(200, function(){
    $(this).remove();
  });
  return false;
};

var validatePhoto = function(file) {
  var errors = [];
  if(file) {
    var allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/bmp"];
    if(allowedTypes.indexOf(file.type) < 0) {
      errors.push("Unsupported file format");
    }
    var maxAllowedSize = spud.admin.photos.max_image_upload_size_bytes;
    if(maxAllowedSize && file.size > maxAllowedSize) {
      errors.push("Your file size of " + self.getFileSizeHumanized(file.size) + " exceeded the maximum limit of " + spud.admin.photos.max_image_upload_size_humanized);
    }
  }
  else {
    errors.push("No file found");
  }
  return errors;
};

var selectedPhotoUiThumb = function(e){
  var thumb = $(this);
  if(thumb.hasClass('spud_admin_photo_ui_thumb_selected')){
    $(this).removeClass('spud_admin_photo_ui_thumb_selected');
  }
  else{
    $(this).addClass('spud_admin_photo_ui_thumb_selected');
  }
};

var markPhotoAsDeleted = function(photo_id){
  var photo = $('#spud_admin_photo_' + photo_id);
  photo.fadeOut(200, function(){
    photo.remove();
  });
};

var markPhotoAlbumAsDeleted = function(photo_album_id){
  var photo_album = $('#spud_admin_photo_album_' + photo_album_id);
  photo_album.fadeOut(200, function(){
    photo_album.remove();
  });
};

var markPhotoGalleryAsDeleted = function(photo_gallery_id){
  var photo_gallery = $('#spud_admin_photo_gallery_' + photo_gallery_id);
  photo_gallery.fadeOut(200, function(){
    photo_gallery.remove();
  });
};

/*
* Single-Photo Form Upload
-------------------------------- */

var generateFileUploadErrors = function(errors, opts) {

  if(typeof errors == "string") {
    errors = [errors];
  }
  var totalErrors = errors.length;
  var errorMsg = totalErrors + " errors prohibited you from saving:";
  if(totalErrors == 1) {
    errorMsg = "1 error prohibited you from saving:";
  }
  if(opts && opts.showAsDialog) {
    alert(errorMsg + '\n\t' + errors.join('\n\t'));
    return false;
  }

  $(".spud_admin_form_error_list").remove();
  $("#spud_admin_photo_form").find("[for=spud_photo_photo]").css("color","black");
  $("#spud_admin_photo_form").before('<div class="spud_admin_form_error_list"><ul><h4>' + errorMsg +'</h4></ul></div>');
  $("#spud_admin_photo_form").find("[for=spud_photo_photo]").css("color","red");
  for(var i = 0; i < errors.length; i++) {
    $(".spud_admin_form_error_list > ul").append("<li>"+ errors[i] + "</li>");
  }
  return false;
};

var submittedPhotoForm = function(e){
  // disable submit button
  // not working in updated bootstrap!
  // var submit = $(this).find('input[type=submit]');
  // submit.attr('disabled', 'disabled').val(submit.attr('data-loading-text'));

  if(html5upload){
    // create a FormData object and attach form values
    var fd = new FormData();
    var form = $(this);
    fd.append('_method', form.find('[name=_method]').val());
    fd.append('authenticity_token', form.find('[name=authenticity_token]').val());
    fd.append('spud_photo[title]', form.find('#spud_photo_title').val());
    fd.append('spud_photo[caption]', form.find('#spud_photo_caption').val());

    // progress bar to send events to
    var progressBar;
    var file = form.find('#spud_photo_photo')[0].files[0];
    var photoValidationErrors = validatePhoto(file);
    if(photoValidationErrors.length) {
      return generateFileUploadErrors(photoValidationErrors);
    }
    
    progressBar = progressBarForUpload(file.name);
    fd.append('spud_photo[photo]', file);
    form.append(progressBar);

    // send FormData object as ajax request
    var xhr = new XMLHttpRequest();
    xhr.upload.addEventListener('progress', function(e){ onPhotoUploadProgress(e, progressBar); }, false);
    xhr.addEventListener('load', function(e){ onPhotoUploadComplete(e, progressBar); }, false);
    xhr.addEventListener('error', function(e){ onPhotoUploadFailure(e, progressBar); }, false);
    xhr.addEventListener('abort', function(e){ onPhotoUploadCancel(e, progressBar); }, false);
    xhr.open('POST', form.attr('action'));
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.send(fd);
    return false;
  }
};

/*
* Upload Progress Monitoring
-------------------------------- */

var progressBarForUpload = function(fileName){
  var html = [
    '<div class="spud_admin_photo_progress">',
      '<h6>',
        '<span class="spud_admin_photo_progress_filename">'+fileName+'</span>: ',
        '<span class="spud_admin_photo_progress_status">Uploading</span>',
      '</h6>',
      '<div class="progress">',
        '<div class="progress-bar progress-bar-striped active" style="width: 0;"></div>',
      '</div>',
    '</div>'
  ].join('');
  return $(html);
};

var onPhotoUploadProgress = function(e, progressBar){
  var percent = Math.round(e.loaded * 100 / e.total);
  progressBar.find('.progress-bar').css({width: percent + '%'});
  if(percent == 100){
    progressBar.find('.spud_admin_photo_progress_status').text('Processing');
  }
};

var onPhotoUploadComplete = function(e, progressBar){
  // success
  var photo = $.parseJSON(e.target.response);
  if(e.target.status == 200){
    progressBar.find('.spud_admin_photo_progress_status').text('Done!');
    progressBar.find('.progress-bar').removeClass('progress-bar-striped active').addClass('progress-bar-success');
    var element = $('#spud_admin_photo_' + photo.id);
    if(element.length > 0){
      element.replaceWith(photo.html);
    }
    else{
      var target = $('#spud_admin_photos_selected, #spud_admin_photos');
      target.prepend(photo.html).fadeIn(200);
    }
    spud.admin.modal.hide();
  }
  // validation error
  else{
    $("#modal_window .modal-body").html(photo.html);
  }
};

var onPhotoUploadCancel = function(e, progressBar){
  progressBar.find('.spud_admin_photo_progress_status').text('Done!');
  progressBar.find('.progress').addClass('progress-danger');
};

var onPhotoUploadFailure = function(e, progressBar){
  if(typeof(console) == 'object'){
    console.error('An unexpected error occurred during upload', e);
  }
};

/*
* Photo Upload/Edit Form
------------------------------- */
var clickedPhotoAddOrEdit = function(e){
  var url = this.href;
  $.ajax({
    url:url,
    success:photoUploadFormLoaded
  });
  return false;
};

var photoUploadFormLoaded = function(html){
  spud.admin.modal.displayWithOptions({
    title: 'Upload Photo',
    html: html
  });
  $(".admin-photo-form-max-size").text('Maximum upload size: '+ spud.admin.photos.max_image_upload_size_humanized);
};

/*
* Add From Photo Library
------------------------------- */

var clickedPhotoLibrary = function(e){
  var url = this.href;
  $.ajax({
    url:url,
    success:photoLibraryLoaded
  });
  return false;
};

var photoLibraryLoaded = function(html){
  var dialog = $('#modal_window');
  $('#spud_admin_photos_selected .spud_admin_photo_ui_thumb').each(function(){
    var id = $(this).attr('id');
    var dupe = dialog.find('#'+id);
    if(dupe){
      dupe.remove();
    }
  });
  spud.admin.modal.displayWithOptions({
    title: 'My Photo Library',
    html: html,
    buttons:{
      'spud_admin_photo_library_add_selected btn-primary': 'Add Selected',
      'spud_admin_photo_library_delete_selected btn-danger': 'Delete Selected'
    }
  });
};

var addSelectedPhotosFromLibrary = function(e){
  $('#spud_admin_photo_library .spud_admin_photo_ui_thumb_selected')
    .removeClass('spud_admin_photo_ui_thumb_selected')
    .prependTo('#spud_admin_photos_selected')
    .hide()
    .fadeIn(200);
  spud.admin.modal.hide();
};

var deleteSelectedPhotosFromLibrary = function(e){
  var ids = $.map($('.spud_admin_photo_ui_thumb_selected'), function(val, i){
    return $(val).attr('rel');
  });
  $.ajax({
    type: 'POST',
    url: '/admin/photos/mass_destroy',
    data: {spud_photo_ids:ids},
    success: function(data, textStatus, jqXHR){
      $('.spud_admin_photo_ui_thumb_selected').fadeOut(200, function(){
        $(this).remove();
      });
    },
    error: function(jqXHR, textStatus, errorThrown){
      console.log('An error occurred:');
      console.log(arguments);
    }
  });
};

/*
* Drag & Drop File Upload Queue
-------------------------------- */

var fileQueue = [];
var fileQueueStarted = false;

// prevent default browser behavior of opening the dropped file
var stopDndPropagation = function(e){
  e.stopPropagation();
  e.preventDefault();
};

// add files to queue. starts queue if not started already
var droppedFile = function(e){
  e.stopPropagation();
  e.preventDefault();
  $('#spud_admin_photo_upload_queue').show();
  var files = e.dataTransfer.files;
  var i = 0;
  while(i < files.length){
    var file = files[i];
    var photoValidationErrors = validatePhoto(file);
    if(photoValidationErrors.length) {
      return generateFileUploadErrors(photoValidationErrors, {showAsDialog: true});
    }
    fileQueue.push(file);
    i++;
  }
  updateQueueCountLabel();
  if(!this.fileQueueStarted){
    uploadNextPhoto();
    if(fileQueue.length > 0){
      uploadNextPhoto();
    }
  }
};

var updateQueueCountLabel = function(){
  $('#spud_admin_photo_upload_queue_label span').text(fileQueue.length);
};

var uploadNextPhoto = function(){
  if(fileQueue.length === 0){
    fileQueueStarted = false;
    return;
  }

  // formdata object
  fileQueueStarted = true;
  var file = fileQueue.pop();
  var fd = new FormData();
  fd.append('spud_photo[photo]', file);

  var csrf = $('meta[name=csrf-token]').prop('content');
  fd.append('authenticity_token', csrf);

  // create a progress bar
  var progressBar = progressBarForUpload(file.name);
  $('#spud_admin_photo_upload_queue_bars').prepend(progressBar);

  // send formdata as xhr
  var xhr = new XMLHttpRequest();
  xhr.upload.addEventListener('progress', function(e){ onPhotoUploadProgress(e, progressBar); }, false);
  xhr.addEventListener('load', function(e){ onQueuedPhotoUploadComplete(e, progressBar); }, false);
  xhr.addEventListener('error', function(e){ onPhotoUploadFailure(e, progressBar); }, false);
  xhr.addEventListener('abort', function(e){ onPhotoUploadCancel(e, progressBar); }, false);
  xhr.open('POST', '/admin/photos');
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  xhr.send(fd);
};

var onQueuedPhotoUploadComplete = function(e, progressBar){
  onPhotoUploadComplete(e, progressBar);
  updateQueueCountLabel();
  uploadNextPhoto();
};

})();

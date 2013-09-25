
$(document).ready(function() {
    
    var dropZone = $('#dropZone'),
        maxFileSize = 1000000; // максимальный размер фалйа - 1 мб.
    
    // Проверка поддержки браузером
    if (typeof(window.FileReader) == 'undefined') {
        dropZone.text('Browser is not support upload!');
        dropZone.addClass('error');
    }
    
    // Добавляем класс hover при наведении
    dropZone[0].ondragover = function() {
        dropZone.addClass('hover');
        return false;
    };
    
    // Убираем класс hover
    dropZone[0].ondragleave = function() {
        dropZone.removeClass('hover');
        return false;
    };
    
    // Обрабатываем событие Drop
    dropZone[0].ondrop = function(event) {
        event.preventDefault();
        dropZone.removeClass('hover');
        dropZone.addClass('drop');
        
        var file = event.dataTransfer.files[0];
        
        // Проверяем размер файла
        if (file.size > maxFileSize) {
            dropZone.text('File is too big!');
            dropZone.addClass('error');
            return false;
        }
        
        // Создаем запрос
        var formData = new FormData();
        var xhr = new XMLHttpRequest();
        formData.append('files', file);
        xhr.open('POST', '/upload');
        xhr.setRequestHeader('X-FILE-NAME', file.name);
        xhr.upload.addEventListener('progress', uploadProgress, false);
        xhr.onreadystatechange = stateChange;
        xhr.send(formData);
    };
    
    // Show upload percent
    function uploadProgress(event) {
        var percent = parseInt(event.loaded / event.total * 100);
        dropZone.text('Upload: ' + percent + '%');
    }
    
    // Пост обрабочик
    function stateChange(event) {
        if (event.target.readyState == 4) {
            if (event.target.status == 200) {
                dropZone.text('Upload is done!');
                alert(event.target.responseText);
            } else {
                dropZone.text('Error!');
                dropZone.addClass('error');
            }
        }
    }
    
});



// function post(json, url, callback){
//         var data = JSON.stringify(json);
//         $.post( url, {"json": data}, callback, "json");
// };


// function process_file(){   
//   if (document.getElementById("name").value == "")
//     return;
//   var _json = {
//      "action" : "cut_url",
//      "url"   : document.getElementById("name").value
//   };
//   post(_json, "http://cnp.su/cut_url", cb_login);
// };         

  
// function cb_login(json){
//   var concat_url = location.hostname + "/" + json.id;
//   document.getElementById("name").value = concat_url;
//   jQuery('#qrdiv').qrcode(concat_url);
//   var do_elem = document.getElementById("do");
//   do_elem.innerHTML = "yet"
//   do_elem.src = location.hostname;
//   do_elem.onclick = add_more;
//   do_elem.title = "Add more URL"
//   check_params();
// };
tab = "";
var t = "";
var file_fields_count = 2;

function checkTabs(){
tab = $('active_tabs').innerHTML;
t = $('active_tabs').innerHTML;
tb = $('active_tabs').innerHTML;
}

function add_a_file_field(){
    var my_span = document.createElement('span');
    my_span.innerHTML = '<br/><input id="comment_documents_document'+file_fields_count+'" name="comment_documents[document'+file_fields_count+']" size="57" style="margin-top:15px;" type="file">';
    $('file_fields_div').appendChild(my_span);
    file_fields_count = file_fields_count + 1;
}
var file_fields_count = 1;

function add_a_file_field(){
    var my_div = document.createElement('div');
    my_div.setAttribute('id', 'div'+file_fields_count);
    my_div.innerHTML = '<input onchange="$(\'div_file'+file_fields_count+'\').innerHTML = ($(this).value); $(\'cross'+file_fields_count+'\').style.display = \'block\';" id="comment_documents_document'+file_fields_count+'" name="comment_documents[document'+file_fields_count+']" size="57" style="margin-top:15px; display:none;" type="file"><div style="clear:both;"></div><div id="div_file'+file_fields_count+'" style="float:left; padding: 0 5px 0 5px;"></div><div id="cross'+file_fields_count+'" style="float:right;display: none;margin-right:100px;"><img width="15" height="15" src="/images/cross.png" onclick="$(\'comment_documents_document'+file_fields_count+'\').value = \'\'; $(\'div_file'+file_fields_count+'\').innerHTML = \'\'; $(\'cross'+file_fields_count+'\').style.display = \'none\'; $(\'file_fields_div\').removeChild($(\'div'+file_fields_count+'\'));" alt="Cross"></div>';
    my_div.setAttribute('style', 'padding:10px');
    $('file_fields_div').appendChild(my_div);
    $('comment_documents_document'+file_fields_count).click();
    file_fields_count = file_fields_count + 1;
}

function add_a_file_field_on_idea(){
    var my_div = document.createElement('div');
    my_div.setAttribute('id', 'div'+file_fields_count);
    my_div.innerHTML = '<input onchange="$(\'div_file'+file_fields_count+'\').innerHTML = ($(this).value); $(\'cross'+file_fields_count+'\').style.display = \'block\';" id="idea_documents_document'+file_fields_count+'" name="idea_documents[document'+file_fields_count+']" size="57" style="margin-top:15px; display:none;" type="file"><div style="clear:both;"></div><div id="div_file'+file_fields_count+'" style="float:left; padding: 0 5px 0 5px;"></div><div id="cross'+file_fields_count+'" style="float:right;display: none;margin-right:100px;"><img width="15" height="15" src="/images/cross.png" onclick="$(\'idea_documents_document'+file_fields_count+'\').value = \'\'; $(\'div_file'+file_fields_count+'\').innerHTML = \'\'; $(\'cross'+file_fields_count+'\').style.display = \'none\'; $(\'file_fields_div_for_idea\').removeChild($(\'div'+file_fields_count+'\'));" alt="Cross"></div>';
    my_div.setAttribute('style', 'padding:10px');
    $('file_fields_div_for_idea').appendChild(my_div);
    $('idea_documents_document'+file_fields_count).click();
    file_fields_count = file_fields_count + 1;
}
function poll_url(url, timeout) {
    $.get(url, function(data) {
        if(timeout <= 0) {
            $('#content').stop().scrollTo('#screen-1', 400);
            alert("I guess you're just not cool enough to get busitized.");
        } else {
            if(data.completed) {
                $('#screen-4 .inner').html(data.html);
                $('#content').stop().scrollTo('#screen-4', 400);
                window.history.pushState("", "Busitized Photo", data.url);
            } else {
                setTimeout(function() {poll_url(url, timeout - 1);}, 1000);
            }
        }
    });
}

function busitize() {
    var val = $("#busey-level").slider("value");
    
    $.get('/grab_photos.json?busey_level=' + val, function(data) {
        if(data.success) {
            var url = '/poll_completion/' + data.task_id + '.json';
            poll_url(url, 20);
        } else {
            alert(data.message);
        }
    });
}

function poll(){
    $.ajax({ url: "server", success: function(data){
        //Update your dashboard gauge
        salesGauge.setValue(data.value);

    }, dataType: "json", complete: poll, timeout: 30000 });
};

function share(picture) {
    // calling the API ...
    var obj = {
      method: 'feed',
      link: 'https://developers.facebook.com/docs/reference/dialogs/',
      picture: picture,
      name: 'Gary Busey',
      caption: 'Get a little Busey in your life',
      description: 'I found some extra Busey lying around and wanted to share it with the world.'
    };

    FB.ui(obj, function(){});
}


$(document).ready(function() {
    
    $(".sharefacebook").click(function(){
        var url = $(this).attr('data-uri');
        share(url);
    });
 });
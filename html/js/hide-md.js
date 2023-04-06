$('#show-text').click(function () {
    if ($('.about-text-hidden').hasClass('fade') == true) {
        $('.about-text-hidden').removeClass('fade')
        .addClass('active');
        if ($(this).innerHTML == "mehr anzeigen") {
            $(this).html("weniger anzeigen");
        } else {
            $(this).html("show less");
        }
        
    } else {
        $('.about-text-hidden').removeClass('active')
        .addClass('fade');
        if ($(this).innerHTML == "weniger anzeigen") {
            $(this).html("mehr anzeigen");
        } else {
            $(this).html("show more");
        }
    }  
});
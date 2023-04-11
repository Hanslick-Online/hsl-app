$('#show-text').click(function () {
    if ($('.about-text-hidden').hasClass('fade-lang') == true) {
        $('.about-text-hidden').removeClass('fade-lang')
        .addClass('active');
        if ($(this).text() == "mehr anzeigen") {
            $(this).html("weniger anzeigen");
        } else {
            $(this).html("show less");
        }
        
    } else {
        $('.about-text-hidden').removeClass('active')
        .addClass('fade-lang');
        if ($(this).text() == "weniger anzeigen") {
            $(this).html("mehr anzeigen");
        } else {
            $(this).html("show more");
        }
    }  
});
$('#show-text').click(function () {
    if ($('.about-text-hidden').hasClass('fade') == true) {
        $('.about-text-hidden').removeClass('fade')
        .addClass('active');
        $(this).html("weniger anzeigen");
    } else {
        $('.about-text-hidden').removeClass('active')
        .addClass('fade');
        $(this).html("mehr anzeigen");
    }  
});
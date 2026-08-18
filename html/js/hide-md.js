$(document).on('click', '.show-text', function () {
    const trigger = $(this);
    const introBlock = trigger.closest('.intro_text');
    const hiddenText = introBlock.find('.about-text-hidden');
    const showMore = trigger.data('showMore');
    const showLess = trigger.data('showLess');

    if (hiddenText.first().hasClass('fade-lang')) {
        hiddenText.removeClass('fade-lang').addClass('active');
        trigger.text(showLess);
    } else {
        hiddenText.removeClass('active').addClass('fade-lang');
        trigger.text(showMore);
    }
});
$('#login-button').click(function (event) {
    event.preventDefault();
    $('form').fadeOut(800);
    $('.wrapper').addClass('form-success');
});

if (document.location.search.match(/type=embed/gi)) {
    window.parent.postMessage('resize', "*");
  }
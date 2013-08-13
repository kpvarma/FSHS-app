$(document).ready(function() {
  
	$('a.auth').click(function(e) {
    
		e.preventDefault();
    var href = $('a.auth').attr('href');
    var authWindow = window.open(href, '', 'width=720,height=555');
		var timer = setInterval(checkAuth, 500);
    
    function checkAuth(){
      
      if (authWindow.closed) {
        clearInterval(timer);
        window.location = '/hootsuite/landing_page?api_token=' + authWindow.apiToken + "&" + window.location.href.slice(window.location.href.indexOf('?') + 1);
      }
    }
    
	});
});

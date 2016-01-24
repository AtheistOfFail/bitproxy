$(document).ready(function(){
	$("#download_btn").click(function(e){
		e.preventDefault();
		$("#download_btn").attr("href",$("#download_btn").attr("href")+ "?file=" + $("#torrent_input").val().trim());
		window.location = $("#download_btn").attr("href");
	})
})
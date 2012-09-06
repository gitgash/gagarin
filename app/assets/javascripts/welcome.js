var unvisible;
$(document).ready(function(){
	init_carusel();

  function init_carusel(){
  	$("#carousel1").CloudCarousel(		
  		{			
  		reflHeight: 76,
  		reflGap:1,
  		xPos: document.body.clientWidth / 2,
  		yPos: document.body.clientHeight / 2 - 230,
  		xRadius: document.body.clientWidth / 2 - 150,
  		yRadius:140,
  		speed:0.15,
  		reflOpacity:0.5,
  		mouseWheel:true
  		}
  	);
  };

  var str1="";
  var result;
  var res;

  var massiv = new Array();

  function search(){
    for(var i = 1; i < 15; i += 2) {
      $("#div" + i).html('');
    }
  	var str = document.getElementById("search_text").value;
    var carusel = document.getElementById("carousel1");
    var result  = document.getElementById("result");
    var j = 0;
  
  	carusel.style.width=document.body.clientWidth+"px";
    carusel.style.height=(document.body.clientHeight - 10)+"px";
	
    if (str1 == str) {
      carusel.innerHTML = '';
    };
  
    carusel.style.display = "none";
    $('#spinner').show();
    $.ajax({
      type: "POST",
      url: "result.json",
      data: "search=" + str,
      success: function(msg){
        str1 = str;
        var data = eval(msg);
        carusel.innerHTML = "";
        for(var i = 0; i < data.length; i += 2) {
          massiv[j] = i + 1;
	  	    carusel.innerHTML += '<img class="cloudcarousel" src="' + (data[i]) + '" data-src=\"' + (data[i + 1]) + '" data-id="' + (i + 1) + '"/>';
          $("#div" + (i + 1)).load('http://' + data[i + 1] + '&fordiv=1');
          j++;
        }
		    init_carusel();
	    }
    });
  };
  
  function unvisible(src, id) {
    $("#carousel1").hide();
    $("#theSearch").hide();
    res = $("#div" + id).show();
  };

  function back() {
    res.hide();
    $("#carousel1").show();
    $("#theSearch").show();
  };
  
  $('.submit-button').click(search);

  $('.backButton').live('click', back);

  $('.cloudcarousel').live('click', function() {
    unvisible($(this).data('src'), $(this).data('id'));
  });

  $(document).keydown(function(event){
    if(event.keyCode==13){
      search();
    }
  });
});

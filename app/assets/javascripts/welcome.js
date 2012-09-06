var unvisible;
$(document).ready(function(){
	init_carusel();

  function init_carusel(){
  	$("#carousel1").CloudCarousel(		
  		{			
  		reflHeight: 76,
  		reflGap:1,
  		xPos: document.body.clientWidth/2,
  		yPos: document.body.clientHeight/2-230,
  		yRadius:240,
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
    for(var i=1;i<15;i+=2){
      document.getElementById(""+i).innerHTML = '<div id = "'+i+'" style="z-index:2500;position:relative;top:10%;display:none;">';
      document.getElementById(""+i).innerHTML+= '</div>';
      
    }
  	var str = document.getElementById("search_text").value;
    var carusel = document.getElementById("carousel1");
    var result  = document.getElementById("result");
    var id_page;
    var j=0;
  
  	carusel.style.width=document.body.clientWidth+"px";
    carusel.style.height=(document.body.clientHeight - 10)+"px";
	
    if(str1==str) {
      carusel.innerHTML = "<div id = \"carousel1\"   style='position:relative;width:1024px;height:512px;overflow:scroll;z-index:5;display:none;background-image:url('/assets/background.gif') no-repeat center center fixed;background-size:cover;'>";
      carusel.innerHTML+="</div>";
    
    };
  
      carusel.style.display = "none";
      $('#spinner').show();
      $.ajax({
        type: "POST",
        url: "result.json",
        data: "search="+str,
        success: function(msg){
          str1 = str;
          var data = eval(msg);
          carusel.innerHTML="";
          for(var i=0;i<data.length;i+=2){
            id_page = Math.random()*5;
            massiv[j]=i+1;
            // carusel.innerHTML+="<img class='cloudcarousel' src='"+(data[i])+"' onClick='unvisible(\""+(data[i+1])+"\","+(i+1)+")'/>";
  	  	    carusel.innerHTML += "<img class='cloudcarousel' src='"+(data[i])+"' data-src=\""+(data[i+1])+"\" data-id=\""+(i+1)+"\"/>";
            $("#"+(i+1)).load('http://'+data[i+1]+'&fordiv=1');
            j++;
          }
  		    init_carusel();
  	   }
	  
      });
  
  };
  
  function unvisible(src,id){
    // document.getElementById("carousel1").style.visibility = "hidden";
    // document.getElementById("theSearch").style.visibility = "hidden";
    $("#carousel1").hide();
    $("#theSearch").hide();
    res = document.getElementById(""+id);
    res.style.display = "block";
  };

  function back(){
    res.style.display = "none";
    res.style.top = "50px";
    // res.style.boxShadow = "0px 0px 3px black";
    // res.style.boxRadius = "20px";
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

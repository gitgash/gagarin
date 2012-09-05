$(document).ready(function(){
				
	//init_carusel();	
  $(document).keydown(function(event){
  if(event.keyCode==13){
    search();
  }
  });
	
});


function init_carusel(){
	// This initialises carousels on the container elements specified, in this case, carousel1.
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
  document.bgColor="black";
};
var str1;

function search(){
	var str = document.getElementById("search_text").value;
	var carusel = document.getElementById("carousel1");
	carusel.style.width=document.body.clientWidth+"px";
  carusel.style.height=document.body.clientHeight+"px";
	
	if(str1!=str){
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
		      //carusel.innerHTML+="<a target='_self' href='http://"+data[i+1]+"'><img class = 'cloudcarousel' src='"+(data[i])+"' /></a>";		
	  	    carusel.innerHTML+="<img class = 'cloudcarousel' src='"+(data[i])+"' onClick='unvisible(\""+(data[i+1])+"\")'/>";
        }
		  init_carusel();
	   }
	  });
  }
};

function unvisible(src){
  alert(src);  
}









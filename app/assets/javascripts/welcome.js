$(document).ready(function(){
				
	//init_carusel();	
				   
	
});


function init_carusel(){
	// This initialises carousels on the container elements specified, in this case, carousel1.
	$("#carousel1").CloudCarousel(		
		{			
		reflHeight: 56,
		reflGap:1,
		xPos: document.body.clientWidth/2,
		yPos: document.body.clientHeight/2-200,
		yRadius:240,
		speed:0.15,
		reflOpacity:0.3,
		mouseWheel:true
		}
	);
};

function search(){
	var str = document.getElementById("search_text").value;
	var carusel = document.getElementById("carousel1");
	carusel.style.width=document.body.clientWidth+"px";
	carusel.style.height=document.body.clientHeight+"px";
	//alert(carusel.style.width);
	
	$.ajax({
	  type: "POST",
	  url: "result.json",
	  data: "search="+str,
	  success: function(msg){
	  	document.getElementById("search_text").value="";
	  	var data = eval(msg);
	  	carusel.innerHTML="";
	  	for(var i=0;i<data.length;i+=2){
		    carusel.innerHTML+="<a target='_blank' href='http://"+data[i+1]+"'><img class = 'cloudcarousel' src='"+(data[i])+"' /></a>";		
	  	}
		init_carusel();
		carusel.style.display = "block";
	 }
	});
};









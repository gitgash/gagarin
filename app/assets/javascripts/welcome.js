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
var result;
var massiv = new Array();
function search(){
	var str = document.getElementById("search_text").value;
  var carusel = document.getElementById("carousel1");
  var result  = document.getElementById("result");
  var id_page;
  var j=0;
  
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
          id_page = Math.random()*5;
          massiv[j]=id_page;
		      //carusel.innerHTML+="<a target='_self' href='http://"+data[i+1]+"'><img class = 'cloudcarousel' src='"+(data[i])+"' /></a>";		
	  	    carusel.innerHTML+="<img class = 'cloudcarousel' src='"+(data[i])+"' onClick='unvisible(\""+(data[i+1])+"\","+id_page+")'/>";
          result.innerHTML+="<frameset id='"+id_page+"' rows='100%' cols='*' style='visibility:hidden;'><frame src=\"http://"+(data[i+1])+"\" scrolling='no' noresize></frameset>";
          //<iframe id='"+id_page+"' src=\"http://"+(data[i+1])+"\" width=\"630px\" height='300px' class='l-projects_shadow' style=\"visibility:hidden;z-index:10000;\">Ваш браузер не поддерживает iframe</iframe>";
          j++;
        }
		  init_carusel();
	   }
	  });
  }
};

function unvisible(src,id){
  var this_win = document.getElementById(id).style.top;
  var dH = 0+this_win;

  document.getElementById("result").style.display = "block";
  
  
  for(var i=0;i<massiv.length;i++){
    if(massiv[i]!=id){
      document.getElementById(massiv[i]).style.display = "none";
    }
  }
  
  document.getElementById(id).style.top = -dH-document.body.clientHeight;
  
  document.getElementById(id).style.visibility = "visible";
  document.getElementById("carousel1").style.visibility = "hidden";
  document.getElementById("theSearch").style.visibility = "hidden";
}









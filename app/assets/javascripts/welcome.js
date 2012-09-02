$(document).ready(function(){
						   
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
	
	//init_carusel();
	
});





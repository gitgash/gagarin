$(document).ready(function(){
						   
	// This initialises carousels on the container elements specified, in this case, carousel1.
	$("#carousel1").CloudCarousel(		
		{			
			xPos: 512,
			yPos: 128,
			buttonLeft: $("#left-but"),
			buttonRight: $("#right-but"),
			altBox: $("#alt-text"),
			titleBox: $("#title-text"),
			mouseWheel: true
		}
	);
});



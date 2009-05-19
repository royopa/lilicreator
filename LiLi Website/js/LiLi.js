window.addEvent('domready', function(){
	// Bottom Rapid Links Deployment
	$('BottomRapidLinks').addEvents({
		'mouseenter': function(){
			this.set('tween', {
				duration: 1000,
				transition: Fx.Transitions.Bounce.easeOut 
			}).tween('height', '150px');
		},
		'mouseleave': function(){
			this.set('tween', {}).tween('height', '20px');
		}
	});
});
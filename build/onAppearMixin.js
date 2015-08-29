function isElementInViewport (el) {

    var rect = el.getBoundingClientRect();
    var gRect = {
        height: (window.innerHeight || document.documentElement.clientHeight),
        width: (window.innerWidth || document.documentElement.clientWidth)
    }

    return (
        (rect.bottom >= gRect.height && rect.top <= gRect.height ||
        rect.top <= 0 && rect.bottom > 0 ||
        rect.top >=0 && rect.bottom <= gRect.height) &&
        (rect.right >= gRect.width && rect.left <= gRect.width ||
        rect.left <= 0 && rect.right > 0 ||
        rect.left >=0 && rect.right <= gRect.width)
    );
}

module.exports = {
	onAppearHandler: function (el, onAppear, onDisappear, context) {
        var visible = false;
        
        var handler = function (event) {
            var newVis = isElementInViewport(el);
            if (newVis != visible) {
                visible = newVis;
                (visible ? onAppear : onDisappear).call(context, el, event);    
            }
			
		};
        if (window.addEventListener) {
            addEventListener('DOMContentLoaded', handler, false); 
            addEventListener('load', handler, false); 
            addEventListener('scroll', handler, false); 
            addEventListener('resize', handler, false); 
        } else if (window.attachEvent)  {
            attachEvent('onDOMContentLoaded', handler); // IE9+ :(
            attachEvent('onload', handler);
            attachEvent('onscroll', handler);
            attachEvent('onresize', handler);
        }
        return function cleanUp() {
            if (window.removeEventListener) {
                removeEventListener('DOMContentLoaded', handler); 
                removeEventListener('load', handler); 
                removeEventListener('scroll', handler); 
                removeEventListener('resize', handler); 
            } else if (window.detachEvent)  {
                detachEvent('onDOMContentLoaded', handler); // IE9+ :(
                detachEvent('onload', handler);
                detachEvent('onscroll', handler);
                detachEvent('onresize', handler);
            }
        };
	},
    isVisible: function (el) {
        return isElementInViewport(el);
    }
}
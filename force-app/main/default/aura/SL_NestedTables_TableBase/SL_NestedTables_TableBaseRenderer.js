({
    afterRender : function(cmp, help) {
       
        this.superAfterRender();
      
        // this is done in renderer because we don't get
        // access to the window element in the helper js.
        
        // per John Resig, we should not take action on every scroll event
        // as that has poor performance but rather we should take action periodically.
        // http://ejohn.org/blog/learning-from-twitter/
        var didScroll = false;
        var element = cmp.getConcreteComponent().find('infiniteScrollDiv').getElement();
        
        element.onscroll = function() {
            didScroll = true;
        };
       
        // periodically attach the scroll event listener
        // so that we aren't taking action for all events
        var scrollCheckIntervalId = setInterval( $A.getCallback( function() {
            // since this function is called asynchronously outside the component's lifecycle
            // we need to check if the component still exists before trying to do anything else
            if(didScroll && cmp.isValid() && cmp.get('v.isInfiniteScrollEnabled') ) {
                didScroll = false;
                if (element && element.scrollHeight - element.scrollTop === element.clientHeight) {
                    
                    help.loadMoreRecords(cmp, help);
                }
            }
            
        }), 1000);
        cmp.set( 'v.scrollCheckIntervalId', scrollCheckIntervalId );
    },
    
    unrender : function(cmp, help) {
        this.superUnrender();
        var scrollCheckIntervalId = cmp.get( 'v.scrollCheckIntervalId' );
        
        if (!$A.util.isUndefinedOrNull(scrollCheckIntervalId)) {
            window.clearInterval(scrollCheckIntervalId);
        }
    }
})
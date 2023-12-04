/**
 * Created by jerridkimball on 2018-05-18.
 */
({
    doInit: function(cmp, evt, hlpr) {
        var isExpandedByDefault = cmp.get("v.isExpandedByDefault");
        
        if (isExpandedByDefault) {
            cmp.set("v.isExpanded", true);
        }
    },

    toggleExpanded: function(cmp, evt, hlpr) {
        var isExpanded = cmp.get("v.isExpanded");

        cmp.set("v.isExpanded", (isExpanded) ? false : true);
    },
})
({
  testsfclick : function(cmp, ev, help)
  {
    var sfId = ev.currentTarget.dataset.sfid;
    var navEvt = $A.get("e.force:navigateToSObject");

    if(navEvt != null)
    {
      navEvt.setParams({
        "recordId": sfId,
        "slideDevName": "detail"
      });
      navEvt.fire();
    }else
    {
      window.location.href = '/'+sfId;
    }
  }
})
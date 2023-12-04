({
  init: function (cmp, event, helper) {
    console.log("Init");
    console.log("Starting Val: " + cmp.get("v.returnVal"));

    var pageRef = cmp.get("v.pageReference");
    var state = pageRef.state;
    var recordTypeVar = state.recordTypeId;
    var base64Context = state.inContextOfRef;
    // For some reason, the string starts with "1.", if somebody knows why,
    // this solution could be better generalized.
    if (typeof base64Context !== "undefined") {
      if (base64Context.startsWith("1.")) {
        base64Context = base64Context.substring(2);
        var addressableContext = JSON.parse(window.atob(base64Context));
        var accountId = addressableContext.attributes.recordId;
        cmp.set("v.recordId", accountId);
      }
    }
    cmp.set("v.RecordTypeId", recordTypeVar);
    //If Contact is created from Account page new contact button
    if(typeof accountId !== "undefined") {
        var action = cmp.get("c.getPrepopulatedFields");
        action.setParams({ accountId: cmp.get("v.recordId") });
    }else{//If contact is created from Contact tab new button (Added for SC-008687)
        var action = cmp.get("c.getUserFields");
      }
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Success");
        var responseString = response.getReturnValue();
        cmp.set("v.returnVal", responseString);
        console.log("Account Id: " + accountId);
        console.log("RecordTypeId: " + recordTypeVar);
        console.log("Response: " + responseString);
        var pageRef = {
          type: "standard__objectPage",
          attributes: {
            objectApiName: "Contact",
            actionName: "new"
          },
          state: {
            recordTypeId: recordTypeVar,
            nooverride: "1",
            defaultFieldValues: responseString
          }
        };
        var workspaceAPI = cmp.find("workspace");
        var navService = cmp.find("navService");
        workspaceAPI.isConsoleNavigation().then(function (isConsole) {
          var focusedTabId;
          if (isConsole) {
            workspaceAPI
              .getFocusedTabInfo()
              .then(function (response) {
                focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
              })
              .catch(function (error) {
                console.log(error);
              });
            console.log("Closing Tab: " + focusedTabId);

            navService.generateUrl(pageRef).then(function (cmpURL) {
              workspaceAPI.openTab({
                url: cmpURL,
                focus: true
              });
            });
          } else {
            navService.navigate(pageRef);
          }
        });
      } else if (state === "INCOMPLETE") {
        console.log("inComplete");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });

    $A.enqueueAction(action);

    action = cmp.get("c.getAccountInfo");
    action.setParams({ accountId: cmp.get("v.recordId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Success");
        var responseString = response.getReturnValue();
        cmp.set("v.accountObject", responseString);
        console.log("Response: " + responseString);
      } else if (state === "INCOMPLETE") {
        console.log("inComplete");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });

    $A.enqueueAction(action);
  },

  gotoPage: function (cmp, event, helper) {
    var accountId = cmp.get("v.recordId");
    var recordTypeVar = cmp.get("v.RecordTypeId");
    var defaultVals = cmp.get("v.returnVal");
    console.log("Account Id: " + accountId);
    console.log("RecordTypeId: " + recordTypeVar);
    var pageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Contact",
        actionName: "new"
      },
      state: {
        recordTypeId: recordTypeVar,
        nooverride: "1",
        defaultFieldValues: defaultVals
      }
    };
    var workspaceAPI = cmp.find("workspace");
    var navService = cmp.find("navService");
    workspaceAPI.isConsoleNavigation().then(function (isConsole) {
      var focusedTabId;
      if (isConsole) {
        workspaceAPI
          .getFocusedTabInfo()
          .then(function (response) {
            focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
          })
          .catch(function (error) {
            console.log(error);
          });
        console.log("Closing Tab: " + focusedTabId);

        navService.generateUrl(pageRef).then(function (cmpURL) {
          workspaceAPI.openTab({
            url: cmpURL,
            focus: true
          });
        });
      } else {
        navService.navigate(pageRef);
      }
    });
  },

  return: function (cmp, event, helper) {
    var pageRef;
    var accountId = cmp.get("v.recordId");
    console.log("Record Id: " + accountId);
    if (typeof accountId !== "undefined") {
      pageRef = {
        type: "standard__recordPage",
        attributes: {
          recordId: accountId,
          objectApiName: "Account",
          actionName: "view"
        }
      };
    } else {
      pageRef = {
        type: "standard__objectPage",
        attributes: {
          objectApiName: "Contact",
          actionName: "home"
        }
      };
    }
    cmp.find("navService").navigate(pageRef);
  }
});
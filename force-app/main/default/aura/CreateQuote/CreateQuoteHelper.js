({
  setInitValues: function(component) {
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    
    component.find("primary").set("v.value", true);
    component.find("startDate").set("v.value", today);

    const opportunityId = component.get("v.recordId");
    const helper = this;

    this.callApex(component, "c.getOpportunityData", {
      opportunityId: opportunityId
    }).then(function(response) {      	
      const { opportunity } = response; 
      component.find("opportunity2").set("v.value", opportunity.Id);
      component.find("account").set("v.value", opportunity.AccountId);
      //Code added by Sourav to handle multiple language based on Market Object
      if(opportunity.Market__r.Change_Language_Flag__c == true){
            component.set("v.countryflag", true);
            component.find("calanguage").set("v.value", opportunity.Customer_Language__c);
          	component.find("intSpeed").set("v.value", opportunity.Internet_Speed_Available__c);
      }else{
          component.set("v.countryflag", false);
          component.find("language").set("v.value", opportunity.Customer_Language__c);         
      }
      component
      .find("address")
      .set("v.value", response.soldToAddress.Id);

      // Code added by Rahul to handle veterinary contact condition
      if(opportunity.Market__r.Authorized_Zoetis_Signature_for_VR__c)
      {
        component.set("v.vrIsEnabled", true);
        // If Veterinary Contact is populated, disable the checkbox
        if(opportunity.Doctor_Contact__c )
        {
          component.set("v.vrIsDisabled", true);
          component.set("v.vrIsChecked", true);
        }
      } 
      /* CPQATG-1299 Deprecate Distributor and Leasing Agent feature

      // Get the distributors and the leasing agents associated to the Market
      helper.callApex(component, "c.getDistributorsAndLeasingAgents", {
        marketId: opportunity.Market__c
      }).then(function(market) {
        console.log('getDistributorsAndLeasingAgents > response', market);       
             
        //Arrays that are gooing to be used for populating the
        // 'Distributor' and 'Leasing Agent' drop-down lists

        let distributors = [];
        let leasingAgents = [];

        // Add the default 'empty' values to both arrays
        distributors.push({label: '', value: ''});
        leasingAgents.push({label: '', value: ''});

        if (market && market.Distributors__r) {
          distributors = distributors.concat(market.Distributors__r.map(dist => ({ label: dist.Name, value: dist.Id})));
        }

        if (market && market.Leasing_Agents__r) {
          leasingAgents = leasingAgents.concat(market.Leasing_Agents__r.map(la => ({ label: la.Name, value: la.Id })));
        }

        console.log('distributors', distributors);

        component.set("v.distributors", distributors);
        component.set("v.leasingAgents", leasingAgents);        
        
        component.set('v.selectedDistributor', opportunity.Distributor_Add__c);
        console.log('selectedDistributor', opportunity.Distributor_Add__c);        

      });

      */

    });
    // Send action off to be executed
  },
  validateInputs: function(component) {
    const errors = [];

    const startDate = component.find("startDate").get("v.value");
    if (!startDate|| startDate == null) {
      errors.push("Start Date can't be empty.");
    }
    const account = component.find("account").get("v.value");
    if (!account) {
      errors.push("Account can't be empty.");
    }
    //const countryflag = component.get("v.countryflag");
      if((component.get("v.countryflag")) == true){
          const intSpeed = component.find("intSpeed").get("v.value");
          if (!intSpeed) {
              errors.push("Internet Speed can't be empty for Canada");
          }
      }
    /*Removing Sold To from layout due to filtered lookup issues
    const address = component.find("address").get("v.value");
    if (!address) {
      errors.push("Sold To Account Address can't be empty.");
    }*/
    if( (component.get("v.vrIsDisabled")) == false && (component.get("v.vrIsChecked")) == true){
      errors.push("Please update Veterinary contact on opportunity before creating a VR quote");
    }

    return errors;
  },
  createQuote: function(component) {
    const primary = component.find("primary").get("v.value");
    const opportunity2 = component.find("opportunity2").get("v.value");
    const startDate = component.find("startDate").get("v.value");
    const account = component.find("account").get("v.value");
    let language = null;
    let intSpeed = null;
      if(component.get("v.countryflag") == true){
          language = component.find("calanguage").get("v.value");
          intSpeed = component.find("intSpeed").get("v.value");
      }else{
          language = component.find("language").get("v.value");
      }
      //const address = component.get("v.address");
    
    /*let leasingAgentId = component
      .find("leasingAgentId")
      .get("v.value");
    let distributorId = component
      .find("distributorId")
      .get("v.value");
      
    if (leasingAgentId === '') {
        leasingAgentId = null; 
    }
      
    if (distributorId === '') {
        distributorId = null;
    }*/
    
    const address = component
      .find("address")
      .get("v.value");
    const closeModal = $A.get("e.force:closeQuickAction");
    this.callApex(component, "c.createQuote", {
      primary: primary,
      opportunityId: opportunity2,
      startDate: startDate,
      accountId: account,
      addressId: address,
        language:language,
        intSpeed:intSpeed
        
      //leasingAgenId: leasingAgentId,
      //distributorId: distributorId
    }).then(function(response) {
      var toastEvent = $A.get("e.force:showToast");
      let params = { message: response.Message };
      if (response.Status === "OK") {
        $A.get("e.force:refreshView").fire();
        params.title = "Success!";
        params.type = "success";
        toastEvent.setParams(params);
        toastEvent.fire();
        closeModal.fire();
      } else {
        params.title = "Error!";
        params.type = "error";
        toastEvent.setParams(params);
        toastEvent.fire();
      }
      //toastEvent.setParams(params);
      //toastEvent.fire();
      //closeModal.fire();
    });

    // Send action off to be executed
  },
  callApex: function(component, methodName, params) {
    component.set("v.loaded", true);
    return new Promise(
      $A.getCallback(function(resolve, reject) {
        var action = component.get(methodName);

        if (params) {
          action.setParams(params);
        }

        action.setCallback(this, function(results) {
          console.log(methodName + " results", results);

          if (results.getState() === "SUCCESS") {
            console.log("results:", results.getReturnValue());
            resolve(results.getReturnValue());
          } else if (results.getState() === "ERROR") {
            console.log("callApex() ERROR", results.getError());
            $A.log("Errors", results.getError());
            reject(results.getError());
          }
          component.set("v.loaded", false);
        });

        $A.enqueueAction(action);
      })
    );
  }
});
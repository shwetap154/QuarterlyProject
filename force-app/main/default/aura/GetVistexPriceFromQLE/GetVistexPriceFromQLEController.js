({
  doInit: function (component, event, helper) {
    // Show loading message
    helper.showLoadingMessage(component, $A.get('$Label.c.Getting_pricing_information_message'));

    var quoteId = component.get('v.recordId');

    helper
      .callApex(component, 'c.getVistexPriceFromLightning', {
        quoteId: quoteId,
        includeAddons: false
      })
      .then(function (response) {
        console.log('Response from APEX Controller', response);

        // SUCCESS
        if (response.Status == 'OK') {
          // If there's nothing to show (no add-ons) just return to QLE.
          if (
            (!response.AutomaticAddons || response.AutomaticAddons.length < 1) &&
            (!response.ManualAddons || response.ManualAddons.length < 1) &&
            (!response.DiscountedAddonGroups || response.DiscountedAddonGroups.length < 1) &&
            (!response.RxDxConsumables || response.RxDxConsumables.length < 1)
          ) {
            helper.redirectToQLE(quoteId);
          } else {
            // Get ship to locations
            helper.callApex(component, 'c.getShipToConfiguration', { quoteId: quoteId }).then(function (shipToLocations) {
              component.set('v.shipToLocations', shipToLocations);

              component.set('v.pricingCallResult', response);
              component.set('v.loading', false);
            });
          }
        }
        // INFO
        else if (response.Status == 'Warn') {
          console.log('getVistexPriceFromLightning MESSAGE', response.Message);
          helper.showErrorMessage(component, 'warning', response.Message);
        } else {
          console.log('getVistexPriceFromLightning - HANDLED ERROR');
          helper.showErrorMessage(component, 'error', response.Message, response.AdditionalErrorInfo);
        }
      })
      .catch(function (err) {
        console.log('err', err);
        let message = err && !!err[0] ? err[0].message : '';
        console.error('getVistexPriceFromLightning - UNHANDLED ERROR: ' + message);
        helper.showErrorMessage(component, 'error', $A.get('$Label.c.There_was_an_error_on_the_Vistex_call'));
      });
  },
  handleDoneClick: function (component, event, helper) {
    // Show loading message
    helper.showLoadingMessage(component, $A.get('$Label.c.Applying_Add_on_Configuration'));

    // Get the quote id to make the call
    const quoteId = component.get('v.recordId');

    // Get the manual addon configuration
    var addonConfiguration = component.get('v.addonQtyConfiguration');
    var approvalConfig = component.get('v.addonApprovalConfiguration');

    // If nothing was configured.
    if (!addonConfiguration) {
      addonConfiguration = {};
    }
    if (!approvalConfig) {
      approvalConfig = {};
    }

    // Check if there is at least one group of addons that is not valid
    if (Object.values(addonConfiguration).some((config) => !config.isValid)) {
      console.log('Quantity Error!');
      return;
    }

    // Everything is OK, start processing...

    // Get the array of the Ship To Configuration
    let shipToConfig = Object.values(addonConfiguration).reduce((acc, config) => {
      return [...acc, ...config.shipToQuantity];
    }, []);

    // Only send ship tos with Quantity > 0
    shipToConfig = shipToConfig.filter((config) => config.Quantity > 0);

    // Approval configuration
    let apprConfig = Object.values(approvalConfig).filter((appr) => appr.ApprovalRequired);

    // Apply the configuration to the manual addons
    const manualAddons = Object.values(addonConfiguration).reduce((acc, config) => {
      if (config.addons && config.addons.length > 0) {
        return [...acc, ...config.addons];
      }
      return [...acc];
    }, []);

    console.log('shipToConfig', shipToConfig);
    console.log('manualAddons', manualAddons);
    console.log('apprConfig', apprConfig);

    helper
      .callApex(component, 'c.addManualAddonsToQuote', {
        quoteId: quoteId,
        addons: manualAddons,
        shipToQuantities: shipToConfig,
        approvalConfig: apprConfig
      })
      .then(function (response) {
        console.log('Response from APEX Controller', response);

        // SUCCESS
        if (response == '') {
          console.log('addManualAddonsToQuote - SUCCESS!');

          // Show loading message
          helper.showLoadingMessage(component, $A.get('$Label.c.Getting_pricing_information_message'));

          helper
            .callApex(component, 'c.getVistexPriceFromLightning', {
              quoteId: quoteId,
              includeAddons: true
            })
            .then(function (response) {
              console.log('Response from APEX Controller', response);

              // SUCCESS
              if (response.Status == 'OK') {
                helper.redirectToQLE(quoteId);
              }
              // INFO
              else if (response.Status == 'Warn') {
                console.log('getVistexPriceFromLightning MESSAGE', response.Message);
                helper.showErrorMessage(component, 'warning', response.Message);
              } else {
                console.log('getVistexPriceFromLightning - HANDLED ERROR');
                helper.showErrorMessage(component, 'error', response.Message, response.AdditionalErrorInfo);
              }
            })
            .catch(function (err) {
              console.log('err', err);
              let message = err && !!err[0] ? err[0].message : '';
              console.error('getVistexPriceFromLightning - UNHANDLED ERROR: ' + message);
              helper.showErrorMessage(component, 'error', $A.get('$Label.c.There_was_an_error_on_the_Vistex_call'), message);
            });
        }
        // ERRROR
        else {
          console.log('addManualAddonsToQuote - ERROR: ' + response);
          helper.showErrorMessage(component, 'error', $A.get('$Label.c.Error_on_applying_Add_ons_configuration'), response);
        }
      })
      .catch(function (err) {
        let message = err[0].message;
        console.error('addManualAddonsToQuote - UNHANDLED ERROR: ' + message);
        helper.showErrorMessage(component, 'error', $A.get('$Label.c.Error_on_applying_Add_ons_configuration'), message);
      });

    component.set('v.loading', false);
    //helper.redirectToQLE(quoteId);
  },
  handleExpandCollapseErrorDetail: function (component, event, helper) {
    let btnGetVistexPrice = event.getSource();
    let divErrorParent = component.find('divErrorParent');
    let divErrorMessage = component.find('divErrorMessage');

    if (btnGetVistexPrice.get('v.iconName') === 'utility:chevronright') {
      btnGetVistexPrice.set('v.iconName', 'utility:chevrondown');
      divErrorMessage.set('v.aria-hidden', 'false');
      $A.util.addClass(divErrorParent, 'slds-is-open');
    } else {
      btnGetVistexPrice.set('v.iconName', 'utility:chevronright');
      divErrorMessage.set('v.aria-hidden', 'true');
      $A.util.removeClass(divErrorParent, 'slds-is-open');
    }
  },
  handleReturnClick: function (component, event, helper) {
    const quoteId = component.get('v.recordId');
    helper.redirectToQLE(quoteId);
  },
  handleAddonQuantityChange: function (component, event, helper) {
    // get current configuraiton
    var curretConfig = component.get('v.addonQtyConfiguration');
    var approvalConfig = component.get('v.addonApprovalConfiguration');

    if (!curretConfig) {
      curretConfig = {};
    }
    if (!approvalConfig) {
      approvalConfig = {};
    }

    var groupId = event.getParam('groupId');

    // Update the configuration based on the ID of the group
    curretConfig[groupId] = {
      isValid: event.getParam('isValid'),
      groupIndex: event.getParam('groupIndex'),
      groupId: event.getParam('groupId'),
      addons: event.getParam('addons'),
      shipToQuantity: event.getParam('shipToQuantity')
    };

    component.set('v.addonQtyConfiguration', curretConfig);

    // Get approval details (for Rx/Dx add-ons)
    var approvalDetails = event.getParam('approvalDetails');
    if (approvalDetails) {
      console.log('approvalDetails.ApprovalRequired', approvalDetails.ApprovalRequired);
      approvalConfig[groupId] = approvalDetails;
    }

    // Set the current configuration
    component.set('v.addonQtyConfiguration', curretConfig);
    component.set('v.addonApprovalConfiguration', approvalConfig);

    // Check if there is at least one group of addons that is not valid
    var isConfigurationInvalid = Object.values(curretConfig).some((config) => !config.isValid);
    component.set('v.configurationIsNotValid', isConfigurationInvalid);

    console.log('handleAddonQuantityChange > isConfigurationInvalid', isConfigurationInvalid);

    // Set message
    component.set('v.configurationErrorMessage', isConfigurationInvalid ? $A.get('$Label.c.Quantities_are_over_the_Maximum') : '');
  },
  handleAutomaticAddonQuantityChange: function (component, event, helper) {
    // get current configuraiton
    var curretConfig = component.get('v.addonQtyConfiguration');

    if (!curretConfig) {
      curretConfig = {};
    }

    var groupId = event.getParam('groupId');

    // Update the configuration based on the ID of the group
    curretConfig[groupId] = {
      isValid: event.getParam('isValid'),
      groupId: event.getParam('groupId'),
      shipToQuantity: event.getParam('shipToQuantity')
    };

    console.log('Current config: ', curretConfig);

    // Set the current configuration
    component.set('v.addonQtyConfiguration', curretConfig);

    // Check if there is at least one group of addons that is not valid
    var isConfigurationInvalid = Object.values(curretConfig).some((config) => !config.isValid);
    component.set('v.configurationIsNotValid', isConfigurationInvalid);

    // Set message
    component.set('v.configurationErrorMessage', isConfigurationInvalid ? $A.get('$Label.c.Quantities_are_over_the_Maximum') : '');
  }
});
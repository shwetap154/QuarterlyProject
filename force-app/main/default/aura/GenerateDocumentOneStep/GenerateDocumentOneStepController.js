({
  doInit: function (component, event, helper) {
    var quoteId = component.get('v.recordId');

    helper
      .callApex(component, 'c.generateDocument', {
        quoteId: quoteId
      })
      .then(function (response) {
        console.log('Response from APEX Controller', response);

        // SUCCESS
        if (response) {
          console.log('generateDocument - SUCCESS!');

          if (response.ExistingDocuments > 0) {
            helper.showWarningErrorMessage(component, $A.get('$Label.c.Remove_Existing_Documents'), 'warning');
          } else if (response.ExistingAgreements > 0) {
            helper.showWarningErrorMessage(component, $A.get('$Label.c.Remove_Existing_Agreements'), 'warning');
          } else {
            component.set('v.saveDocumentJobId', response.JobId);

            var interval = setInterval(
              $A.getCallback(function () {
                var jobId = component.get('v.saveDocumentJobId');

                helper
                  .callApex(component, 'c.getDocumentGenerationStatus', {
                    jobId: jobId,
                    quoteId: quoteId
                  })
                  .then(function (response) {
                    if (response) {
                      console.log('Job Status: ', response);

                      // Queued, Processing, Aborted, Failed, Preparing, Holding
                      if (response.Done) {
                        clearInterval(interval);

                        component.set('v.quoteDocumentId', response.QuoteDocumentId);
                        component.set('v.statusText', $A.get('$Label.c.Generating_Agreement'));

                        var quoteId = component.get('v.recordId');
                        var quoteDocId = response.QuoteDocumentId;

                        helper
                          .callApex(component, 'c.generateAgreement', {
                            quoteId: quoteId,
                            quoteDocumentId: quoteDocId
                          })
                          .then(function (response) {
                            if (response) {
                              helper.redirectToUrl(response);
                            } else {
                              helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Agreement'), 'error');
                            }
                          })
                          .catch(function (err) {
                            console.error('Error on generateAgreement: ', err);
                            helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Agreement'), 'error');
                          });
                      } else if (response.Error) {
                        console.log('Error on getting Job Status: ' + response.ErrorMessage);
                        clearInterval(interval);
                        helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Document'), 'error');
                      } else {
                        // continue polling
                      }
                    } else {
                      console.log('Error on getting Job Status: ', response);
                      clearInterval(interval);
                      helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Document'), 'error');
                    }
                  })
                  .catch(function (err) {
                    console.error('Error on getting Job Status: ', err);
                    clearInterval(interval);
                    helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Document'), 'error');
                  });
              }),
              3000
            );
          }
        }
        // ERRROR
        else {
          console.log('generateDocument - ERROR: ' + response);
          helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Document'), 'error');
        }
      })
      .catch(function (err) {
        let message = err[0].message;
        console.error('generateDocument - UNHANDLED ERROR: ' + message);
        helper.showWarningErrorMessage(component, $A.get('$Label.c.Error_Generating_Document'), 'error');
      });
  }
});
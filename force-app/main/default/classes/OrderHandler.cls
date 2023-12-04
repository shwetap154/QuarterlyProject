/**
 * @description       :
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-29-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 **/
//Created By : Suvankar
// 

public without sharing class OrderHandler implements TriggerInterface {
    
          List<Id> conIdList = new List<Id>();
          Set<Id> orderIdset = new Set<Id>();
          Set<Id> distIdset = new Set<Id>();
          Map<string, string> conMap = new Map<string, string>();
          Map<string, string> accMap = new Map<string, string>();
          Map<string, Contact> objConMap = new Map<string, Contact>();
          Map<string, List<string>> ConEmailMap = new Map<string, List<string>>();
          Map<string, AlphaMarketCountry__c> csMap = new Map<string, AlphaMarketCountry__c>();
          Map<string, string> uProfileMap = new Map<string, string>();
          public static  EmailTemplate emailTemplateDLSpanish;
          public static EmailTemplate EmailTemplateZoetisSpanish;
          public static  EmailTemplate EmailTemplateStatusSpanish;
         
    
          Static{
                for(EmailTemplate template: [SELECT Id, Name FROM EmailTemplate WHERE Name in ('Distributor New Order Submitted Template - Spanish','Zoetis Internal New Order Submitted Template - Spanish','Distributor Order Status Change Template - Spanish')]){
                    if(template.Name=='Distributor New Order Submitted Template - Spanish'){
                    emailTemplateDLSpanish= template;
                    }
                    else if(template.Name=='Zoetis Internal New Order Submitted Template - Spanish'){
                    EmailTemplateZoetisSpanish= template; 
                    }
                    else if(template.Name=='Distributor Order Status Change Template - Spanish'){
                      EmailTemplateStatusSpanish=template; 
                    }
                }
            }
        
          private static EmailTemplate emailTemplateDL = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
            FROM EmailTemplate
            WHERE name = 'Distributor New Order Submitted Template'
          ];
          private static EmailTemplate emailTemplateCSCL = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
            FROM EmailTemplate
            WHERE name = 'Zoetis Internal New Order Submitted Template'
          ];
          private static EmailTemplate emailTemplate = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
            FROM EmailTemplate
            WHERE name = 'Distributor Order Status Change Template'
          ];
          private static Profile p = [
            SELECT Id, Name
            FROM Profile
            WHERE name = 'Distributor Community User'
          ];
    
          private static Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName();
          public static Id distributorOrderRTId = recordTypeMap.get('Distributor').getRecordTypeId();
          public static Id preInstallOrderRTId = recordTypeMap.get('Order_With_Pre_Install_Checklist_Layout').getRecordTypeId();
          public static Id withoutPreInstallOrderRTId = recordTypeMap.get('Order_Without_Pre_Install_Checklist_Layout').getRecordTypeId();

			private static List<OrgWideEmailAddress> orgAddresses = [
    SELECT Id, Address, DisplayName
    FROM OrgWideEmailAddress
    WHERE Address = 'noreply@zoetis.com'
  ];

          public OrderHandler() {
          }
        
          public void bulkBefore() {
          }
            
          public void bulkAfter() {
            if (!Trigger.isDelete) {
              //Getting Custom settings
              Map<String, AlphaMarketCountry__c> mcsMap = AlphaMarketCountry__c.getAll();
              system.debug(mcsMap);
              for (String str : mcsMap.keyset()) {
                csMap.put(
                  mcsMap.get(str).Market__c +
                  '_' +
                  mcsMap.get(str).Country__c,
                  mcsMap.get(str)
                );
              }
              system.debug(csMap);
        
              for (Order ord : (List<Order>) Trigger.new) {
                distIdset.add(ord.AccountId);
                uProfileMap.put(ord.lastmodifiedbyId, ord.Lastmodifiedby.ProfileId);
              }
        
              if (distIdset.size() > 0) {
                for (Contact Eachcon : [SELECT id,accountId,Email,ZTS_EU_Market__c,Account.ZTS_EU_Market__c,Account.ZTS_EU_Country__c FROM Contact WHERE accountId IN :distIdset AND Selected_For_Alert__c = TRUE]) {
                      if (ConEmailMap.containsKey(Eachcon.accountId) && Eachcon.email != null) {
                        System.debug('Contact In Loop Email: ' + Eachcon.email);
                        List<String> usersId = ConEmailMap.get(Eachcon.accountId);
                        if (Eachcon.Email != null)
                            usersId.add(Eachcon.Email);
                            ConEmailMap.put(Eachcon.accountId, usersId);
                        } else {
                            System.debug('Contact in Loop - new Map Key: ' + Eachcon.email);
                            if (Eachcon.Email != null)
                              ConEmailMap.put(Eachcon.accountId,new List<string>{ Eachcon.Email });
                        }
                        if (Eachcon.Email != null)
                            conIdList.add(Eachcon.id);
                        if (Eachcon.Email != null){
                            conMap.put(Eachcon.Email, Eachcon.Id);
                            objConMap.put(Eachcon.Email,Eachcon);
                        }
                        accMap.put(
                            Eachcon.accountId,
                            Eachcon.Account.ZTS_EU_Market__c +
                            '_' +
                            Eachcon.Account.ZTS_EU_Country__c
                        );
                    }
              }
              system.debug(ConEmailMap);
            }
          }
    
          public void beforeInsert(SObject so) {
          }
        
          public void beforeUpdate(SObject oldSo, SObject so) {
          }
        
          public void beforeDelete(SObject so) {
          }

          public void afterInsert(SObject so) {
          }

            public void afterUpdate(SObject oldSo, SObject so) {
                Order neword = (Order) so;
                Order oldord = (Order) oldSo;
                if (neword.RecordTypeId == distributorOrderRTId) {
                  //OrderEmailFromHandler_Batch obj = new OrderEmailFromHandler_Batch(neword.Id,oldord.status,distIdset);
                  //database.executeBatch(obj);
                  List<Messaging.SingleEmailMessage> lstmail = new List<Messaging.SingleEmailMessage>();
            
                  String[] toAddresses;
                      if (
                          neword.Status == 'Submitted' &&
                          oldord.Status != 'Submitted' &&
                          ConEmailMap.containsKey(neword.accountId)
                      ) {
						for (String str : ConEmailMap.get(neword.accountId)) {
						  	System.debug('For Each Contact Email: ' + str);
                              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                              // Send email to DL
                              email.setTreatTargetObjectAsRecipient(false);
                              email.setTargetObjectId(conMap.get(str));
                              toAddresses = new List<string>();
                              toAddresses.add(str);
                              System.debug('To Addresses 1: ' + toAddresses);
                              email.setToAddresses(toAddresses);
                              email.setWhatId(neword.Id);
						  			// sending spanish email if market is Panama or Costa Rica as part of TPDEV-1006
									Contact objCon = objConMap.get(str);
									if(objCon.ZTS_EU_Market__c =='Panama' || objCon.ZTS_EU_Market__c =='Costa Rica'){
										email.setTemplateID(emailTemplateDLSpanish.Id); 
									}
									else{  
										email.setTemplateID(emailTemplateDL.Id); 
									}
							
						 
						  		toAddresses.clear();
						  		lstmail.add(email);
                        }
				  
						 try {
							//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
							system.debug('Email sent::::::::::::::::');
						  } catch (exception e) {
							system.debug(e.getCause());
						  }
                          
                          // Getting attachments ending with -Signed.pdf from Order as part of TPDEV-762
                          List<Id> attachmentIds = new List<Id>();
                          List<Attachment> attachments = AttachmentsSelector.getAgreementAttachment(neword.Id);
                          for (Attachment attachment : attachments){
                              attachmentIds.add(attachment.Id);    
                          }
                          
                          AttachmentIds.addAll(new Map<Id, Attachment>(attachments).keySet());
                         
                          
						//Send to CS/CLAttach
                        integer i = 0;
                        for (i = 0; i < 1; i++) {
                          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if (accMap.containsKey(neword.accountId)) {
                                if (csMap.size() > 0 && csMap.containskey(accMap.get(neword.accountId))) {
                                  email = new Messaging.SingleEmailMessage();
                                  email.setWhatId(neword.Id);
                                  email.setTreatTargetObjectAsRecipient(false);
                                  email.setTargetObjectId(conIdList[0]);
                                  toAddresses = new List<string>();
                                  if (csMap.get(accMap.get(neword.accountId)).CL_Email__c != null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CL_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CS_Agent_Email__c !=null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CS_Agent_Email__c);
                                  //toAddresses.add(csMap.get(eachStr).CL_Email__c);
                                  //toAddresses.add(csMap.get(eachStr).CS_Agent_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CL_2_Email__c != null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CL_2_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CL_3_Email__c != null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CL_3_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CL_4_Email__c != null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CL_4_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CL_5_Email__c != null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CL_5_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CS_Agent_2_Email__c !=null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CS_Agent_2_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CS_Agent_3_Email__c !=null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CS_Agent_3_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CS_Agent_4_Email__c !=null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CS_Agent_4_Email__c);
                                  if (csMap.get(accMap.get(neword.accountId)).CS_Agent_5_Email__c !=null)
                                    toAddresses.add(csMap.get(accMap.get(neword.accountId)).CS_Agent_5_Email__c);
                              
                                    system.debug('To Addresses Again: ' + toAddresses);
                                    email.setToAddresses(toAddresses);
                                        //email.setWhatId(neword.accountId);
                                        // sending spanish email if language is 'es' as part of TPDEV-1006
                                        
                                        if(csMap.get(accMap.get(neword.accountId)).Language__c == 'es'){                   
                                            email.setTemplateID(EmailTemplateZoetisSpanish.Id);
                                                                        
                                        }else{
                                          email.setTemplateID(emailTemplateCSCL.Id);
                                      }
                                    // attaching Order forms to email as part of TPDEV-762  
                                    if (!attachmentIds.isEmpty()) {                                
                                        email.setEntityAttachments(attachmentIds);                                 
                                    }   
                            
                                        email.setSaveAsActivity(false);
    
                                    try {
                                        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                                        system.debug('Email sent::::::::::::::::');
                                    } catch (exception e) {
                                        system.debug(e.getMessage());
                                    }
                                    lstmail.add(email);
                                }
                            }
						}       
				}
    
          		//EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Distributor Order Status Change Template'];
				//Messaging.SingleEmailMessage emaill = new Messaging.SingleEmailMessage();
				//String[] toAddresses ;

				if (oldord.Status != neword.Status && ConEmailMap.containsKey(neword.accountId) && neword.Status != 'Submitted') {
					for (String str : ConEmailMap.get(neword.accountId)) {
					  System.debug('For Each Contact Email: ' + str);
					  Messaging.SingleEmailMessage emaill = new Messaging.SingleEmailMessage();
					  // Send email to DL
					  emaill.setTargetObjectId(conMap.get(str));
					  emaill.setTreatTargetObjectAsRecipient(false);
					  toAddresses = new List<string>();
					  toAddresses.add(str);
					  System.debug('ToAddresses: ' + toAddresses);
					  emaill.setToAddresses(toAddresses);
					  emaill.setWhatId(neword.Id);
					  //Sending spanish email if market is Panama or CostaRica as part of TPDEV-1008
								Contact objCon = objConMap.get(str);
								if(objCon.ZTS_EU_Market__c =='Panama' || objCon.ZTS_EU_Market__c =='Costa Rica'){
									emaill.setTemplateID(EmailTemplateStatusSpanish.Id);
								}
								else{
									emaill.setTemplateID(emailTemplate.Id);
								}
						
					  try {
						//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emaill });
						system.debug('Email sent::::::::::::::::');
					  } catch (exception e) {
						system.debug(e.getCause());
					  }
					  toAddresses.clear();
					  lstmail.add(emaill);
					}
				}
				system.debug(lstmail.size());

				if (lstmail.size() > 0) {
					if (!orgAddresses.isEmpty()) {
					  for (Messaging.SingleEmailMessage message : lstmail) {
						message.setOrgWideEmailAddressId(orgAddresses[0].Id);
					  }
					}
					Messaging.sendEmail(lstmail);
				}
			}
		}

		public void afterDelete(SObject so) {
		}

		public void afterUndelete(SObject so) {
		}

		public void andFinally() {
		}

	}
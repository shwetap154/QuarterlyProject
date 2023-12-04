/**
* File Name     :  
* @description  :  Utils class for the quote address validations.  Pulled out of trigger handlers because it is reused in both the Quote and QuoteLine triggers
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/27/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/6/2020		Cory Bartholomew @ ATG     Added descriptions.

**/

public class CPQ_QuoteAddressUtils {

	
	/**
     * @description Build a map of each parent(quote account) so we can build the hierarchy.
     * @param parentIds Ids of the accounts from all quotes in a trigger
     * @param hierarchyAccounts List of all accounts that are children of the parentIds
     */
	public static Map<Id, List<Account>> buildParentAccountMap(Set<Id> parentIds, List<Account> hierarchyAccounts){
		Map< Id, List<Account>> parentAccountMap = new Map<Id, List<Account>>();
		//initialize map with all parent account values and empty child account list
		for(Id parentId : parentIds){
			parentAccountMap.put(parentId, new List<Account>());
		}

		//Go through all accounts and associate them to their parents.  Ultimate parents will have their own Id as the ultimate parent
		for(Account childAccount : hierarchyAccounts){
			if(accountListMapContainsValue(parentAccountMap, childAccount.Id)){
				parentAccountMap.get(childAccount.Id).add(childAccount);
			}			
			else if(accountListMapContainsValue(parentAccountMap, childAccount.Parent.Id)){
				parentAccountMap.get(childAccount.Parent.Id).add(childAccount);
			}
			else if(accountListMapContainsValue(parentAccountMap, childAccount.Parent.Parent.Id)){
				parentAccountMap.get(childAccount.Parent.parent.Id).add(childAccount);
			}
			else if(accountListMapContainsValue(parentAccountMap, childAccount.Parent.Parent.Parent.Parent.Id)){
				parentAccountMap.get(childAccount.Parent.Parent.Parent.Parent.Id).add(childAccount);
			}			
		}
		System.debug('Parent Account Map '+ parentAccountMap);
		return parentAccountMap;
	}

	/**
     * @description Check if the key is not null and if the key exists in the map
     * @param parentAccountMap Map of all parent account Ids as keys with their children accounts as values
     * @param keyToCheck the accountId to check exists
     */
	private static Boolean accountListMapContainsValue(Map<Id, List<Account>> parentAccountMap, Id keyToCheck){
		Boolean result = false;
		if(keyToCheck != null){
			if(parentAccountMap.containskey(keyToCheck)){
				result = true;
			}
		}
		return result;
	}

	/**
     * @description Query the parent account and down to 4 other levels of the account hierarchy.
     * @param parentAccountIds All of the accountIds to find children for.
     */
	public static List<Account> queryAccountHierarchy(Set<Id> parentAccountIds){
		return [SELECT Id, Name, Parent.Id, Parent.Parent.Id, Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Parent.Id,
						(SELECT Id FROM Addresses__r)
					FROM Account 
					WHERE Id IN :parentAccountIds 
						OR Parent.Id IN :parentAccountIds 
						OR Parent.Parent.Id IN :parentAccountIds 
						OR Parent.Parent.Parent.Id IN :parentAccountIds  
						OR Parent.Parent.Parent.Parent.Id IN :parentAccountIds						 
				];         
	}
}
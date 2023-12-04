public with sharing class AnimalAgeHelper {
    static final string UNITYEARS = 'Year(s)';
    static final string UNITMONTHS = 'Month(s)';
    static final string UNITDAYS = 'Day(s)';
    public static void validateAnimalAge(ZTS_US_Animal__c[] animals){
        for(ZTS_US_Animal__c animal : animals){
            String ageUnits;
            Integer age;
            if(animal.ZTS_US_Date_of_Birth__c!=null && animal.ZTS_US_Species__c != 'Human' 
                && animal.ZTS_US_Age_from__c!=null && String.isNotBlank(animal.ZTS_US_Age_unit_from__c)){
                ageUnits = animal.ZTS_US_Age_unit_from__c;
                age = Integer.valueOf(animal.ZTS_US_Age_from__c);
            }
            else if(animal.ZTS_US_Date_of_Birth__c!=null && animal.ZTS_US_Species__c == 'Human' 
                && animal.ZTS_US_Age_text__c!=null && String.isNotBlank(animal.Age_units__c)){
                ageUnits = animal.Age_units__c;
                age = Integer.valueOf(animal.ZTS_US_Age_text__c);
            }
            if(age!=null && ageUnits!=null){
                Date ageDate;
                if(ageUnits==UNITYEARS){
                    ageDate = date.today().addYears(-1 * age);
                }
                else if(ageUnits==UNITMONTHS){
                    ageDate = date.today().addMonths(-1 * age);
                }
                else if(ageUnits==UNITDAYS){
                    ageDate = date.today().addDays(-1 * age);
                }
                if(ageDate != null && ageDate < animal.ZTS_US_Date_of_Birth__c ){
                    animal.addError('Age cannot exceed Date of Birth');
                }
            }
            
        }
    }
    public static void validateCaseAnimalAge(ZTS_US_Case_Animal__c[] caseAnimals){
        Id[] animalIds = new Id[]{};
        for(ZTS_US_Case_Animal__c caseAnimal : caseAnimals){
            if(String.isNotBlank(caseAnimal.ZTS_US_Animal__c)){
                animalIds.add(caseAnimal.ZTS_US_Animal__c);
            }
        }
        Map<Id,ZTS_US_Animal__c> animalMap = new Map<Id,ZTS_US_Animal__c>([SELECT Id,ZTS_US_Date_of_Birth__c,ZTS_US_Species__c 
                                                                            FROM ZTS_US_Animal__c WHERE Id in : animalIds]);
        for(ZTS_US_Case_Animal__c caseAnimal : caseAnimals){
            ZTS_US_Animal__c animal = animalMap.get(caseAnimal.ZTS_US_Animal__c);
            if(animal==null){
                continue;
            }
            String ageUnits;
            Integer age;
            if(animal.ZTS_US_Date_of_Birth__c!=null && animal.ZTS_US_Species__c != 'Human' 
                && caseAnimal.ZTS_US_Age_from__c!=null && String.isNotBlank(caseAnimal.ZTS_US_Age_unit_from__c)){
                ageUnits = caseAnimal.ZTS_US_Age_unit_from__c;
                age = Integer.valueOf(caseAnimal.ZTS_US_Age_from__c);
            }
            else if(animal.ZTS_US_Date_of_Birth__c!=null && animal.ZTS_US_Species__c == 'Human' 
                && caseAnimal.ZTS_US_Age_text__c!=null && String.isNotBlank(caseAnimal.Age_units__c)){
                ageUnits = caseAnimal.Age_units__c;
                age = Integer.valueOf(caseAnimal.ZTS_US_Age_text__c);
            }
            if(age!=null && ageUnits!=null){
                Date ageDate;
                if(ageUnits==UNITYEARS){
                    ageDate = date.today().addYears(-1 * age);
                }
                else if(ageUnits==UNITMONTHS){
                    ageDate = date.today().addMonths(-1 * age);
                }
                else if(ageUnits==UNITDAYS){
                    ageDate = date.today().addDays(-1 * age);
                }
                if(ageDate != null && ageDate < animal.ZTS_US_Date_of_Birth__c ){
                    caseAnimal.addError('Age cannot exceed Date of Birth');
                }
            }
            
        }
    }
}
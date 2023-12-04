/**********************************************************************
 @author Alex Carstairs
 @date 21 May 2019
 @description This class acts as an interface for trigger handlers
 **********************************************************************/

public interface TriggerHandlerInterface {

    void beforeInsert(List<SObject> triggerNew);

    void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap);

    void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap);

    void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap);

    void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap);

    void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap);

    void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap);

    Boolean isDisabled();

    Boolean isFirstTime();

    List<String> getTriggerContextsForRecursion();

    void setBypassField(Schema.SObjectField bypassField);

}
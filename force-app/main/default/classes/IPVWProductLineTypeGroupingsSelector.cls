/**
 * @description       : Interface for PVWProductLineTypeGroupingsSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-08-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectProductLinesByType method
**/
public interface IPVWProductLineTypeGroupingsSelector {
    Map<String, Set<String>> selectProductLinesByType(Set<String> categories);
}
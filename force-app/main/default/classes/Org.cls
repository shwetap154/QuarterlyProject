/**
 * @description       : Singleton Class for Org-Level Data
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 **/
public with sharing class Org {
  private static Org instance = null;
  private static Organization sfOrg = null;
  private static Map<String, Profile> mapProfilesByName;

  public Boolean isSandbox { get; private set; }
  public String orgType { get; private set; }

  private Org() {
    if (sfOrg == null) {
      sfOrg = [
        SELECT Id, OrganizationType, IsSandbox
        FROM Organization
        LIMIT 1
      ];
    }
    isSandbox = sfOrg.isSandbox;
    orgType = sfOrg.OrganizationType;
  }

  public static Boolean isSandbox() {
    return getInstance().isSandbox;
  }

  public static String OrganizationType() {
    return getInstance().orgType;
  }

  public static Map<String,Profile> getProfileMapByName(){
    if(mapProfilesByName != null){
      return mapProfilesByName;
    }else {
      mapProfilesByName = new Map<String, Profile>();
      for(Profile prof : ProfilesSelector.newInstance().selectAll()){
        mapProfilesByName.put(prof.Name,prof);
      }
      return mapProfilesByName;
    }
  }

  private static Org getInstance() {
    if (instance == null) {
      instance = new Org();
    }
    return instance;
  }
}
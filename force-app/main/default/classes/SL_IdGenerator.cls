@isTest
public class SL_IdGenerator {

    static Integer counter = 1;

    public static String generateMockIdForObjectType(Schema.SObjectType objectType) {
      String result = String.valueOf(counter++);
      return objectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
    }
}
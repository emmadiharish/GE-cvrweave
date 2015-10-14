/******************************************************************************************************************************
* Name - CVMetaUtils

* Description - This class does the following:
    - Utility method to get record type Information without query.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer     Date            Description
* ---------------------------------------------------------------------------
* Siva Gunda    10/14/2015      Created.
******************************************************************************************************************************/
public with sharing class CVMetaUtils {
    public class CVRecordTypeNotFoundException extends Exception {} 
    
    private static final Map<String,Map<String,Schema.RecordTypeInfo>> sObjectRecordTypes = new Map<String,Map<String,Schema.RecordTypeInfo>>();

    public static Id getRecordTypeId(SObjectType so, String recordTypeName) {
        if (so != null && recordTypeName != null && recordTypeName != '') {
            Schema.DescribeSObjectResult r = so.getDescribe();
            if (r != null && !sObjectRecordTypes.containsKey(r.getName())) {
                sObjectRecordTypes.put(r.getName(), r.getRecordTypeInfosByName());
            }

            Map<String, Schema.RecordTypeInfo> recTypeInfos = sObjectRecordTypes.get(r.getName());
            Schema.RecordTypeInfo recTypeInfo = recTypeInfos.get(recordTypeName);
            System.debug('recTypeInfo=' + recTypeInfo);
            if (recTypeInfo != null)
                return recTypeInfo.getRecordTypeId();
        }

        throw new CVRecordTypeNotFoundException('RecordType \'' + recordTypeName + '\' was not found for SObjectType \'' + so + '\'.');
    }
}
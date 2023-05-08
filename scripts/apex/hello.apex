// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
List<Department_Type_Department__mdt> metadata = [SELECT Department__c, Department_type__c FROM Department_Type_Department__mdt];
System.debug(metadata);
public with sharing class TestDataFactory{
    public static List<Account> createHospitalsList(Integer amount, Boolean doInsert){
        List<Account> hospitalList = new List<Account>();
        for (Integer i = 0; i < amount; i++){
            hospitalList.add(new Account(Name = 'Test Hospital' + i));
        }
        if (doInsert){
            insert hospitalList;
        }
        return hospitalList;
    }

    public static List<Account> createHospitalsDepartmentList(Integer amount, List<Account> hospitalList, Boolean doInsert){
        List<Account> hospitalDepartmentList = new List<Account>();
        for (Integer i = 0; i < amount; i++){
            for (Integer j = 0; j < hospitalList.size(); j++){
                hospitalDepartmentList.add(new Account(Name = 'Test hospital department ' + i, Parent = hospitalList[j]));
            }
        }
        if (doInsert){
            insert hospitalDepartmentList;
        }
        return hospitalDepartmentList;
    }

    public static List<InsuranceCompany__c> createInsurenceCompanyList(Integer amount, Boolean doInsert){
        List<InsuranceCompany__c> insuranceCompaniesList = new List<InsuranceCompany__c>();
        for (Integer i = 0; i < amount; i++){
            insuranceCompaniesList.add(new InsuranceCompany__c(Name = 'Insurance company ' + i));
        }
        if (doInsert){
            insert insuranceCompaniesList;
        }
        return insuranceCompaniesList;
    }

    public static List<Contact> createDoctorsList(Integer amount, List<Account> hospitalDepartmentList, Boolean doInsert){
        List<Contact> doctorsList = new List<Contact>();
        for (Integer i = 0; i < amount; i++){
            for (Integer j = 0; j < hospitalDepartmentList.size(); j++){
                doctorsList.add(new Contact(AccountId = hospitalDepartmentList[j].Id, FirstName = 'FirstName D ' + i, LastName = 'LastName D ' + i));
            }
        }
        if (doInsert){
            insert doctorsList;
        }
        return doctorsList;
    }

    public static List<Patient__c> createPatientList(Integer amount, List<Account> hospitalList, Boolean doInsert){
        List<Patient__c> patientList = new List<Patient__c>();
        for (Integer i = 0; i < amount; i++){
            for (Integer j = 0; j < hospitalList.size(); j++){
                patientList.add(new Patient__c(First_Name__c = 'Test Patient FN ' + i, Last_Name__c = 'Last name ' + i, Hospital__r = hospitalList[j], Birthday_date__c = Date.newInstance(1960, 2, 17)));
            }
        }
        if (doInsert){
            insert patientList;
        }
        return patientList;
    }

    public static List<Insurance__c> createInsuranceList(Integer amount, Decimal insuranceAmount, List<InsuranceCompany__c> isuranceCompanyList, List<Patient__c> patientList, Boolean doInsert){
        List<Insurance__c> insuranceList = new List<Insurance__c>();
        for (Integer i = 0; i < amount; i++){
            for (Integer j = 0; j < isuranceCompanyList.size(); j++){
                for (Integer k = 0; k < patientList.size(); k++){
                    insuranceList.add(new Insurance__c(Amount__c = insuranceAmount, Department_type__c = 'Adult', Covered_departments__c = 'Therapy', InsuranceCompany__c = isuranceCompanyList[j].Id, Patient__c = patientList[k].Id));
                }

            }
        }
        if (doInsert){
            insert insuranceList;
        }
        return insuranceList;
    }

    public static List<Case> createTreatmentList(Integer amount, List<Account> hospitalDepartmentList, List<Contact> doctorsList, List<Patient__c> patientList, List<Insurance__c> insuranceList, Boolean doInsert){
        List<Case> treatmentList = new List<Case>();
        for (Integer i = 0; i < amount; i++){
            for (Integer j = 0; j < insuranceList.size(); j++){
                for (Integer k = 0; k < patientList.size(); k++){
                    for (Integer h = 0; h < doctorsList.size(); h++){
                        for (Integer p = 0; p < hospitalDepartmentList.size(); p++){
                            treatmentList.add(new Case(Insurance__c = insuranceList[j].Id, Patient__c = patientList[k].Id, ContactId = doctorsList[h].Id, AccountId = hospitalDepartmentList[p].Id));
                        }
                    }
                }
            }
        }
        if (doInsert){
            insert treatmentList;
        }
        return treatmentList;
    }

    public static List<Receipt__c> createReceiptsList(Integer amount, List<Case> treatmentList, List<Patient__c> patientList, List<Insurance__c> isuranceList, Boolean doInsert){
        List<Receipt__c> receiptList = new List<Receipt__c>();
        for (Integer i = 0; i < amount; i++){
            for (Integer j = 0; j < treatmentList.size(); j++){
                for (Integer k = 0; k < patientList.size(); k++){
                    for (Integer h = 0; h < isuranceList.size(); h++){
                        receiptList.add(new Receipt__c(Treatment__c = treatmentList[j].Id, Patient__c = patientList[k].Id, Insurance__r = isuranceList[h]));
                    }
                }
            }
        }
        if (doInsert){
            insert receiptList;
        }
        return receiptList;
    }

}
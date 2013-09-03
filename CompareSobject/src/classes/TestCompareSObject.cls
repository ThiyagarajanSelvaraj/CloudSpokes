@isTest
public with sharing class TestCompareSObject {
	
	private static Id recordId;
	/* 
	*  Create Test Contact Record
	*/
	private static Id createTestData(String objectName){
		if (objectName == 'contact'){
			recordId = Database.insert(new Contact(FirstName='Jack',Birthdate=System.today().addDays(-2),LastName='Evans',Email='jack.tuck@demo.com',MobilePhone='0123456789',MailingCountry='UK',Salutation='Mr.',MailingCity='Winchester',MailingPostalCode='SO23 7AA')).getId();
		}else if (objectName == 'lead'){
			recordId = Database.insert(new Lead(FirstName='Jack',LastName='Knight',Company='CTS Corporation',NumberOfEmployees=21,Email='jack.Knight@demo.com',MobilePhone='0123456789')).getId();
		}
		return recordId;
	}
	
	static testMethod void test_CompareSObject(){
		Test.startTest();
		
		// Testing with contact data
		Id contactId = createTestData('contact');
		System.Test.setCurrentPageReference(new PageReference('/apex/x?id='+contactId));
		CompareSObject cls = new CompareSObject();
		cls.compareRecord();
		
		// Check the values;
		System.assertEquals('contact',cls.sObjectName);
		System.assertEquals('Jack Evans',cls.recordName); 
		cls.overrideData();
		
		// Get the contact record and check the value 
		// It overrides the field values with external data
		Contact con = [SELECT FirstName, LastName, MailingCountry, Email FROM Contact WHERE Id=:contactId LIMIT 1];
		System.assertEquals('Luke',con.FirstName);
		System.assertEquals('Hardy',con.LastName);
		System.assertEquals('US',con.MailingCountry);
		System.assertEquals('luke.hardy@gmail.com',con.Email);
		
		
		// Testing with lead data
		Id leadId = createTestData('lead');
		System.Test.setCurrentPageReference(new PageReference('/apex/x?id='+leadId));
		cls = new CompareSObject();
		cls.compareRecord();
		
		// Check the values;
		System.assertEquals('lead',cls.sObjectName);
		System.assertEquals('Jack Knight',cls.recordName); 
		cls.overrideData();
		
		// Get the contact record and check the value 
		// It overrides the field values with external data
		Lead lead = [SELECT FirstName, Company, LastName, NumberOfEmployees FROM Lead WHERE Id=:leadId LIMIT 1];
		System.assertEquals('Test Company',lead.Company);
		System.assertEquals('Kristina',lead.FirstName);
		System.assertEquals('Stewart',lead.LastName);
		System.assertEquals(34,lead.NumberOfEmployees);
		
		System.assertEquals(null, cls.refreshPageBlock());
		Test.stopTest(); 
	} 
	
}
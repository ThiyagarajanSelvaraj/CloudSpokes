@isTest
public with sharing class TemplateControllerTest {
	
	/*
	* Test Method for constructor
	*/
	static testMethod void test_Constructror(){
		Template__c template = new Template__c(Name='Test Template',Quote_Info_Fields__c='[{"fieldName":"Name","fieldLabel":"Quote Name"}]',Quote_Total_Fields__c='[{"fieldName":"Discount","fieldLabel":"Discount"}]',Quote_Line_Item_Fields__c='[{"fieldName":"Description","fieldLabel":"Line Item Description"}]',Show_Quote_Total__c=true,Summary_Message__c='Thanks',Welcome_Message__c='Thanks for selecting our product',Section_Order__c='Header,Welcome Message,Quote Info,Quote Line Items,Quote Total,Summary Message,Footer');
		insert template;
		// Testing without creating template record
		Test.startTest();
		TemplateController cls = new TemplateController(new ApexPages.standardController(new Template__c()));
		System.Test.setCurrentPageReference(new PageReference('/apex/x'));
		
		// Testing after creating template record
		cls = new TemplateController(new ApexPages.standardController(template));
		System.Test.setCurrentPageReference(new PageReference('/apex/x'));
		
		System.assertEquals(1,cls.selectedQuoteInfoFields.size());
		System.assertEquals(1,cls.selectedQuoteLineItemFields.size());
		System.assertEquals(1,cls.selectedQuoteTotalFields.size());
		Test.stopTest();
	}
	
	/*
	*	Testing save method
	*/
	static testMethod void test_saveTemplate(){
		Test.startTest();
		TemplateController cls = new TemplateController(new ApexPages.standardController(new Template__c(Name='My Template', Show_Quote_Total__c=true,Summary_Message__c='Thanks',Welcome_Message__c='Thanks for selecting our product',Section_Order__c='Header,Welcome Message,Quote Info,Quote Line Items,Quote Total,Summary Message,Footer')));
		System.Test.setCurrentPageReference(new PageReference('/apex/x?selQuoteInfoFields=Name&selQuoteLineItemFields=LineNumber&selQuoteTotalFields=Name&SectionOrderList=Header,Welcome Message,Quote Info,Quote Line Items,Quote Total,Summary Message,Footer'));
		cls.saveTemplate();
		Template__c Template = [SELECT Id, Name, Header__c, Quote_Info_Fields__c, Section_Order__c, Quote_Total_Fields__c, Quote_Line_Item_Fields__c, Show_Quote_Total__c, Summary_Message__c, Welcome_Message__c FROM Template__c LIMIT 1];
		System.assertEquals('My Template',Template.Name);
		System.assertEquals('[{"fieldName":"Name","fieldLabel":"Quote Name"}]',Template.Quote_Info_Fields__c);
		System.assertEquals('[{"fieldName":"LineNumber","fieldLabel":"Line Item Number"}]',Template.Quote_Line_Item_Fields__c);
		System.assertEquals('[{"fieldName":"Name","fieldLabel":"Quote Name"}]',Template.Quote_Total_Fields__c);
		System.assertEquals('Header,Welcome Message,Quote Info,Quote Line Items,Quote Total,Summary Message,Footer',Template.Section_Order__c);
		Test.stopTest();
	}
}
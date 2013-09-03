@isTest
public with sharing class DisplayTemplateTest {
	
	private static Id createTestData(){
		Id AccountId = Database.insert(new Account(Name='Test Account')).getId();
		Id oppId = Database.insert(new Opportunity(Name='Test opportunity',AccountId=AccountId,CloseDate=System.today(),StageName='Closed Won')).getId();
		Id TemplateId = Database.insert(new Template__c(Name='Test Template',Quote_Info_Fields__c='[{"fieldName":"Name","fieldLabel":"Quote Name"}]',Quote_Total_Fields__c='[{"fieldName":"Discount","fieldLabel":"Discount"}]',Quote_Line_Item_Fields__c='[{"fieldName":"Description","fieldLabel":"Line Item Description"}]',Show_Quote_Total__c=true,Summary_Message__c='Thanks',Welcome_Message__c='Thanks for selecting our product',Section_Order__c='Header,Welcome Message,Quote Info,Quote Line Items,Quote Total,Summary Message,Footer')).getId();
		Id productId = Database.insert(new Product2(Name='Test Product',IsActive=true,Template__c=TemplateId)).getId();
		Id QuoteId = Database.insert(new Quote(Name='Test Quote',OpportunityId=oppId,Product_of_Interest__c=productId)).getId();
		Database.insert(new Quote_Address__c(Billing_Address__c='Billing',Shipping_Address__c='Shipping',Quote__c=QuoteId));
		return QuoteId;
	}
	
	/*
	* 	Test method for Disply template
	*/
	static testMethod void test_DisplayTemplate(){
		DisplayTemplate cls = new DisplayTemplate();
		Test.startTest();
		cls.quoteId = createTestData();
		cls.getTemplateInfo();
		System.assertEquals('Test Quote',cls.quoteRecord.Name);
		System.assertEquals(0,cls.QuoteLineItems.size());
		System.assertEquals('Test Template',cls.template.Name);
		System.assertEquals(false,cls.showLineItemSection);
		Test.stopTest();
	}
	
	
	/*
	* 	Testing getHeaderImageUrl and getFooterImage Url
	*/
	static testMethod void test_ImageUrl(){
		DisplayTemplate cls = new DisplayTemplate();
		Test.startTest();
		Database.insert(new Images__c(Header__c='https://eu2.salesforce.com/Header',Footer__c='https://eu2.salesforce.com/Footer'));
		System.assertEquals('https://eu2.salesforce.com/Header',cls.getHeaderImageUrl());
		System.assertEquals('https://eu2.salesforce.com/Footer',cls.getFooterImageUrl());
		Test.stopTest();
	}
	
}
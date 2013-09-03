public class DisplayTemplate {
	
	public Id 									quoteId  				{get; set;}
	public Quote 								quoteRecord				{get; set;}
	public List<QuoteLineItem>					QuoteLineItems			{get; set;}	
	public Template__c							template				{get; set;}
	public Boolean 								showQuoteTotalSection	{get; set;}	
	public String 								summaryMessage 			{get; set;}	
	public Boolean 								showLineItemSection 	{get; set;}	
	public Quote_Address__c						quoteAddress			{get; set;}
	public Boolean								showAddress				{get; set;}
	public List<String>							sectionOrderList 		{get; set;}
	
	// variables used to get the template information
	public GenericTemplate 						quoteInfoSection		{get; set;}
	public GenericTemplate						quoteLineItemSection	{get; set;}
	public GenericTemplate						quoteTotalSection		{get; set;}
	
	/*
	*	Constructor
	*/
	public DisplayTemplate(){}
	
	
	/*
	*	Description : This methods get the quote, quote items, quote address and template recrod based on the given quote Id
	*	return 		Template__c 			template record for the related product which is related to the quote 
	*/
	public List<String> getTemplateInfo(){
		template = new Template__c();
		quoteAddress = new Quote_Address__c();
		showLineItemSection = false;
		showQuoteTotalSection = false;
		showAddress = false;
		
		
		try{
			quoteInfoSection 		= new GenericTemplate();
			quoteLineItemSection 	= new GenericTemplate();
			quoteTotalSection		= new GenericTemplate();
			QuoteLineItems 			= new List<QuoteLineItem>();
			sectionOrderList		= new List<String>();
			
			// Get the quote and quote line item records
			String sqlQuery = 'SELECT '+selectAllFromSobject('Quote')+' ,'+' (SELECT '+selectAllFromSobject('QuoteLineItem')+' FROM QuoteLineItems), (SELECT '+selectAllFromSobject('Quote_Address__c')+' FROM Quote_Addresses__r) FROM Quote WHERE Id = \''+quoteId+'\'';
			List<Quote> rsQuotes = Database.query(sqlQuery);
			
			quoteRecord = rsQuotes[0];
			if (!rsQuotes[0].QuoteLineItems.isEmpty()){
				QuoteLineItems.addAll(rsQuotes[0].QuoteLineItems);
			}
			if (!rsQuotes[0].Quote_Addresses__r.isEmpty()){
				quoteAddress = rsQuotes[0].Quote_Addresses__r[0];
			}
			
			
			// Get the product records
			List<Product2> rsProducts = new List<Product2>();
			if (!rsQuotes.isEmpty()){
				if (rsQuotes[0].Product_of_Interest__c != null){
					String sqlProduct = 'SELECT '+selectAllFromSobject('Product2')+' FROM Product2 WHERE Id = \''+rsQuotes[0].Product_of_Interest__c+'\'';
					rsProducts = Database.query(sqlProduct);
				}
			}
			
			// Get the template records
			List<Template__c> rsTemplates = new List<Template__c>();
			if (!rsProducts.isEmpty()){
				if (rsProducts[0].Template__c != null){
					String sqlTemplate = 'SELECT '+selectAllFromSobject('Template__c')+ ' FROM Template__c WHERE Id = \''+rsProducts[0].Template__c+'\'';
					rsTemplates = Database.query(sqlTemplate);
				}
			}
			
			// Check template list is not empty
			if (!rsTemplates.isEmpty()){
				template = rsTemplates[0];
				
				// Quote Info
				if (rsTemplates[0].Quote_Info_Fields__c != null){
					quoteInfoSection.selectedFields.addAll(ListFieldNames((List<selectedField>)JSON.deserialize(rsTemplates[0].Quote_Info_Fields__c, List<selectedField>.class)));
					quoteInfoSection.mapLabel.putAll(mapFieldNamesAndLabels((List<selectedField>)JSON.deserialize(rsTemplates[0].Quote_Info_Fields__c, List<selectedField>.class)));
				}
				
				//Quote Item
				if (rsTemplates[0].Quote_Line_Item_Fields__c != null){
					quoteLineItemSection.selectedFields.addAll(ListFieldNames((List<selectedField>)JSON.deserialize(rsTemplates[0].Quote_Line_Item_Fields__c, List<selectedField>.class)));
					quoteLineItemSection.mapLabel.putAll(mapFieldNamesAndLabels((List<selectedField>)JSON.deserialize(rsTemplates[0].Quote_Line_Item_Fields__c, List<selectedField>.class)));
					if (!quoteLineItemSection.selectedFields.isEmpty() && !QuoteLineItems.isEmpty()){
						showLineItemSection = true;
					}
				}
				
				showQuoteTotalSection = rsTemplates[0].Show_Quote_Total__c;
				showAddress = rsTemplates[0].Show_Address__c;
				sectionOrderList = rsTemplates[0].Section_Order__c != null ? rsTemplates[0].Section_Order__c.split(',') : new List<String>();
				
				//Quote Total 
				if (rsTemplates[0].Quote_Total_Fields__c != null){
					quoteTotalSection.selectedFields.addAll(ListFieldNames((List<selectedField>)JSON.deserialize(rsTemplates[0].Quote_Total_Fields__c, List<selectedField>.class)));
					quoteTotalSection.mapLabel.putAll(mapFieldNamesAndLabels((List<selectedField>)JSON.deserialize(rsTemplates[0].Quote_Total_Fields__c, List<selectedField>.class)));
				}
			} 
		}catch(Exception ex){
			
		}
		return sectionOrderList; 
	}
	
	/*
	*	Description : Get the Header image url from the custom settings
	*/
	public String getHeaderImageUrl(){
		if (Images__c.getOrgDefaults().Header__c != null){
			return Images__c.getOrgDefaults().Header__c;
		}
		return null;
	}
	
	/*
	*	Description : Get the Footer image url from the custom settings
	*/
	public String getFooterImageUrl(){
		if (Images__c.getOrgDefaults().Header__c != null){
			return Images__c.getOrgDefaults().Footer__c;
		}
		return null;
	}
	
	/*
	*	Description : Create a list of selected fields api names
	*	param 		: selectedFieldsList - List has selectedField ApiName and its label
	*	return 		List<String> 	selected fields api name
	*/
	private static List<String> ListFieldNames(List<SelectedField> selectedFieldsList){
		List<String> fieldsList = new List<String>();
		
		if (!selectedFieldsList.isEmpty()){
			for (SelectedField selField : selectedFieldsList){
				fieldsList.add(selField.fieldName);
			}
		}
		return fieldsList;
	}
	
	/*
	*	Description : Create a map that has selectedfield ApiName as key and selectedField label as its value
	* 	param 		: selectedFieldsList - List has selectedField ApiName and its label
	*	return 		Map<String, String> 	key - selectedFieldApiName value = associated label
	*/
	private static Map<String, String> mapFieldNamesAndLabels(List<SelectedField> selectedFieldsList){
		Map<String, String> mapfieldsList = new Map<String, String>();
		
		if (!selectedFieldsList.isEmpty()){
			for (SelectedField selField : selectedFieldsList){
				mapfieldsList.put(selField.fieldName, selField.fieldLabel);
			}
		}
		return mapfieldsList;
	}
	
	/*
	*	Description : Grab all the fields for the given sObject and create a string by appending all the fields one by one.
	*	param 		: sobjectAPIName - Name of the sObject
	*	return 		String 	 String with all the fields for the given sObject.
	*/
	public static String selectAllFromSobject(String sobjectAPIName){
		String fieldsList = '';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sobjectAPIName.toLowerCase()).getDescribe().fields.getMap();
		 
		// Grab the fields from the describe method and append them to the queryString one by one.
		for(String s : objectFields.keySet()) {
		   fieldsList += ' ' + s + ', ';
		}
		 
		// Strip off the last comma if it exists.
		if(fieldsList.subString(fieldsList.Length()-2,fieldsList.Length()) == ', ')
		{
			fieldsList = fieldsList.subString(0,fieldsList.Length()-2);
		}
		return fieldsList; 
	}
	
	/* 
	* Wrapper Class to format JSON String
	*/
	public class selectedField{
		public String 	fieldName			{get; set;}
		public String 	fieldLabel 			{get; set;}
	}
	
	/* 
	* Wrapper Class to hold selectedFieldsList and selectField to its label map
	*/
	public class GenericTemplate{
		public List<String>						selectedFields		{get; set;}
		public Map<String, String>				mapLabel			{get; set;}
		
		public GenericTemplate(){
			this.selectedFields = new List<String>();
			this.mapLabel = new Map<String, String>();
		}
	}
}
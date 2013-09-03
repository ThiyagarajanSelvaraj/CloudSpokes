public with sharing class TemplateController {
	
	public ApexPages.standardController 	stdController 					{get; set;}
	public String 							sectionOrder 					{get; set;}
	public List<SelectOption>				availableQuoteInfoFields		{get; set;}
	public List<SelectOption>				selectedQuoteInfoFields			{get; set;}
	public List<SelectOption>				availableQuoteLineItemFields	{get; set;}
	public List<SelectOption>				selectedQuoteLineItemFields		{get; set;}
	public List<SelectOption>				availableQuoteTotalFields		{get; set;}
	public List<SelectOption>				selectedQuoteTotalFields		{get; set;}
	public Map<String, Schema.sObjectField>	mapQuoteFields 					{get; set;}
	public Map<String, Schema.sObjectField>	mapQuoteLineItemFields 			{get; set;}
	public List<SelectOption>				sectionOrderList 				{get; set;}
	
	
	/*
	* Constructor taking standard controller as an argument 
	*/
	public TemplateController(ApexPages.standardController controller){
		stdController 			= controller;
		mapQuoteFields 			= new Map<String, Schema.sObjectField>();
		mapQuoteLineItemFields 	= new Map<String, Schema.sObjectField>();
		
		// Grab all the Quote Fields
		for (Schema.sObjectField objField : Quote.sObjectType.getDescribe().fields.getMap().values()){
			mapQuoteFields.put(objField.getDescribe().getLocalName(), objField);
		}
		
		// Grab all the Quote Line Item Fields
		for (Schema.sObjectField objField : QuoteLineItem.sObjectType.getDescribe().fields.getMap().values()){
			mapQuoteLineItemFields.put(objField.getDescribe().getLocalName(), objField);
		}
		
		if (stdController.getRecord().Id == null){
			sectionOrderList = new List<SelectOption>();
			
			List<String> orderList = new List<String>{'Header','Welcome Message','Quote Info','Quote Line Items','Quote Total','Address','Summary Message','Footer'};
			
			for (String orderString : orderList){
				sectionOrderList.add(new SelectOption(orderString, orderString));
			}
			// Quote Info Fields
			selectedQuoteInfoFields  = new List<SelectOption>();
			availableQuoteInfoFields = new List<SelectOption>{};
			availableQuoteInfoFields.addAll(selectOptionSortByLabel(Selector(mapQuoteFields, new List<selectedField>(),'All')));
			
			// Quote Line Item Fields
			selectedQuoteLineItemFields = new List<SelectOption>();
			availableQuoteLineItemFields = new List<SelectOption>();
			availableQuoteLineItemFields.addAll(selectOptionSortByLabel(Selector(mapQuoteLineItemFields, new List<selectedField>(),'All')));
			
			// Quote Total Fields
			selectedQuoteTotalFields = new List<SelectOption>();
			availableQuoteTotalFields = new List<SelectOption>();
			availableQuoteTotalFields.addAll(selectOptionSortByLabel(Selector(mapQuoteFields, new List<selectedField>(),'All')));
		}else{
			Template__c template = [SELECT Quote_Info_Fields__c, Quote_Total_Fields__c, Section_Order__c, Quote_Line_Item_Fields__c FROM Template__c WHERE Id=:stdController.getRecord().Id];
			sectionOrderList = new List<SelectOption>();
			
			List<String> orderList = template.Section_Order__c.split(',');
			
			for (String orderString : orderList){
				sectionOrderList.add(new SelectOption(orderString, orderString));
			}
			// Quote Info Fields
			selectedQuoteInfoFields  = new List<SelectOption>();
			selectedQuoteInfoFields.addAll(Selector(mapQuoteFields, (List<selectedField>)JSON.deserialize(template.Quote_Info_Fields__c, List<selectedField>.class),'Selected'));
			availableQuoteInfoFields = new List<SelectOption>{};
			availableQuoteInfoFields.addAll(selectOptionSortByLabel(Selector(mapQuoteFields, (List<selectedField>)JSON.deserialize(template.Quote_Info_Fields__c, List<selectedField>.class),'Available')));
			
			// Quote Line Item Fields
			selectedQuoteLineItemFields = new List<SelectOption>();
			selectedQuoteLineItemFields.addAll(Selector(mapQuoteLineItemFields, (List<selectedField>)JSON.deserialize(template.Quote_Line_Item_Fields__c, List<selectedField>.class),'Selected'));
			availableQuoteLineItemFields = new List<SelectOption>();
			availableQuoteLineItemFields.addAll(selectOptionSortByLabel(Selector(mapQuoteLineItemFields, (List<selectedField>)JSON.deserialize(template.Quote_Line_Item_Fields__c, List<selectedField>.class),'Available')));
			
			// Quote Total Fields
			selectedQuoteTotalFields = new List<SelectOption>();
			selectedQuoteTotalFields.addAll(Selector(mapQuoteFields, (List<selectedField>)JSON.deserialize(template.Quote_Total_Fields__c, List<selectedField>.class),'Selected'));
			availableQuoteTotalFields = new List<SelectOption>();
			availableQuoteTotalFields.addAll(selectOptionSortByLabel(Selector(mapQuoteFields, (List<selectedField>)JSON.deserialize(template.Quote_Total_Fields__c, List<selectedField>.class),'Available')));
		}
	}
	
	/*
	* Description : Create a selectOption list based on the selectListType
	* Param 	  : mapFields - map of fieldApinames to its sobjectField
	* Param 	  : selectedFields - List has selectedFieldAPI Names and its label 
	* Param 	  : selectListType denotes the required options type
	* return 	List<SelectOption>			List of sObjectFields
	*/
	private static List<SelectOption> Selector(Map<String, Schema.sObjectField> mapFields, List<selectedField> selectedFields, String selectListType){
		List<SelectOption> 	options 	= new List<SelectOption>();
		
		if (!selectedFields.isEmpty()){
			if (selectListType == 'Selected'){
				for (selectedField field : selectedFields){
					options.add(new SelectOption(field.fieldName, mapFields.get(field.fieldName).getDescribe().getLabel()));
				}
			}else if (selectListType == 'Available'){
				Set<String>	selFieldsSet  = new Set<String>();
				
				// Get the selected fields
				for (selectedField field : selectedFields){
					selFieldsSet.add(field.fieldName);
				}
				
				// Get the remaining Fields
				for (Schema.sObjectField objField : mapFields.Values()){
					if (!selFieldsSet.contains(objField.getDescribe().getLocalName())){
						options.add(new SelectOption(objField.getDescribe().getLocalName(), objField.getDescribe().getLabel()));
					}
				}
			}
		}else{
			for (Schema.sObjectField objField : mapFields.Values()){
				options.add(new SelectOption(objField.getDescribe().getLocalName(), objField.getDescribe().getLabel()));
			}
		}
		return options;
	}
	
	/* 
	*  Description : Sort the select option by its label
	*  return 	List<SelectOption>	Sorted options by its label
	*/
	private static List<selectOption> selectOptionSortByLabel(list<selectOption> selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
        
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if(SO.getLabel() <= pivotValue.getLabel()){
                lessSelectOption.add(SO);
            }else if(SO.getLabel() > pivotValue.getLabel()){
                greaterSelectOption.add(SO);   
            }
        }
        
        List<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }
    
    /* 
	* Description : Get the string and split it and create a selectedField List
	*				Each SelectedField has fieldName - selectedFieldAPIName and fieldLabel - selected Field label
	* Param 	  : selFields - string of selected fields 
	* Param 	  : ObjType	 represents the sobject name
	*/
	private List<selectedField> createListFromString(String selFields, String ObjType){
		List<selectedField> selFieldsList = new List<selectedField>();
		if (selFields != null){
			List<String> StringList = selFields.split(',');
			if (!StringList.isEmpty()){
				for (String field : StringList){
					selFieldsList.add(new selectedField(field, ObjType == 'Quote' ? mapQuoteFields.get(field).getDescribe().getLabel() : mapQuoteLineItemFields.get(field).getDescribe().getLabel()));
				}
			}
		}
		return selFieldsList;
	}
	
    /* 
	* Description : Save the template record
	*/
	public PageReference saveTemplate(){
		Template__c template = (Template__c)stdController.getRecord();
		try{
			template.Section_Order__c = ApexPages.currentPage().getParameters().get('SectionOrderList');
			template.Quote_Info_Fields__c = JSON.serialize(createListFromString(ApexPages.currentPage().getParameters().get('selQuoteInfoFields'),'Quote'));
			template.Quote_Line_Item_Fields__c = JSON.serialize(createListFromString(ApexPages.currentPage().getParameters().get('selQuoteLineItemFields'),'QuoteLineItem'));
			template.Quote_Total_Fields__c = JSON.serialize(createListFromString(ApexPages.currentPage().getParameters().get('selQuoteTotalFields'),'Quote'));
			upsert template;
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
		}
		return new PageReference('/'+template.Id).setRedirect(true);
	}
	
	
	/* 
	* Wrapper Class used to create a structure for JSON
	*/
	public class selectedField{
		public String 	fieldName			{get; set;}
		public String 	fieldLabel 			{get; set;}
		
		public selectedField(String fieldName, String fieldLabel){
			this.fieldName = fieldName;
			this.fieldLabel = fieldLabel;
		}
	}
}
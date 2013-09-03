public with sharing class CompareSObject {
	
	public List<objCompare>					objCompareList 				{get; private set;}
	public String 							sObjectName 				{get; private set;}
	public List<sObject>					rsRecords 					{get; set;}
	public String 							recordName 					{get; private set;}
	
	
	/* 
	*  Constructor taking standardController as a parameter
	*/
	public CompareSObject(){
		// Inititalize the global variables
		objCompareList = new List<objCompare>();
		sObjectName = getsObjectName();
		rsRecords = new List<sObject>();
	}
	
	
	/*
	*	Description : Grab all the fields for the given sObject and create a string by appending all the fields one by one.
	*	param 		: sobjectAPIName - Name of the sObject
	*	return 		String 	 String with all the fields for the given sObject.
	*/
	public PageReference compareRecord(){
		Map<String, Schema.sObjectField>		mapSobjectFieldLabel = new Map<String, Schema.sObjectField>();
		
		try{
			if (!String.isBlank(ApexPages.CurrentPage().getParameters().get('id')) && sObjectName != null){
				// Get the list of contact fields from the schema
				for (Schema.sObjectField objField : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values()){
					mapSobjectFieldLabel.put(objField.getDescribe().getLocalName().toLowerCase(), objField);
				}
				
				String sql = 'SELECT '+CreateSqlString(mapSobjectFieldLabel.keySet())+ ' FROM '+sObjectName+' WHERE Id = \''+String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('id'))+'\' LIMIT 1';
				rsRecords = Database.query(sql);
				
				// Check if the contacts list is not empty
				if (!rsRecords.isEmpty()){
					
					// get the dummy record and replace this map with the map retrieved from the webservice
					Map<String, Object>	mapsObjectData = CreateDummyMap.createDummyRecord(sObjectName.toLowerCase());  
				
					// Get the record Name 
					recordName = String.valueOf(rsRecords[0].get('Name'));
					
					if (!mapsObjectData.isEmpty()){
						for (String objField : mapsObjectData.keySet()){
							for (String schemasObjectField : mapSobjectFieldLabel.keySet()){
								if (schemasObjectField.equalsIgnoreCase(objField)){
									objCompareList.add(new objCompare(mapSobjectFieldLabel.get(schemasObjectField).getDescribe().getLabel(), mapSobjectFieldLabel.get(schemasObjectField).getDescribe().getLocalName(), String.valueOf(rsRecords[0].get(schemasObjectField)), String.valueOf(mapsObjectData.get(objField)), String.valueOf(mapSobjectFieldLabel.get(schemasObjectField).getDescribe().getSOAPType()).toLowerCase(), (String.valueOf(rsRecords[0].get(schemasObjectField)) == String.valueOf(mapsObjectData.get(objField))) ? false : true));
								}
							}
						}
					}
				}
			}
			// Sort the list by its label
			objCompareList = SortByLabel(objCompareList);
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
		}
		return null;
	}
	
	
	/*
	*	Description : Grab all the fields for the given sObject and create a string by appending all the fields one by one.
	*	param 		: sobjectAPIName - Name of the sObject
	*	return 		String 	 String with all the fields for the given sObject.
	*/
	public static String CreateSqlString(Set<String> sObjectFieldsList){
		String fieldsList = '';
		
		// Grab the fields and append them to the queryString one by one.
		for(String s : sObjectFieldsList) {
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
	*	Description : This method used for action support on the page
	*	return 		PageReference 	 null.
	*/
	public PageReference refreshPageBlock(){
		return null;
	}
	
	/*
	*	Description : Finds the sobjecttype from the 15 or 18 digit digit Id
	*	return 		String 	 API name of the sobject
	*/
	private static String getsObjectName(){
		if (!String.isBlank(ApexPages.CurrentPage().getParameters().get('id'))){
			for (Schema.sObjectType obj : Schema.getGlobalDescribe().Values()){
				if (obj.getDescribe().getKeyPrefix() != null){
					if (obj.getDescribe().getKeyPrefix().toLowerCase() == ApexPages.CurrentPage().getParameters().get('id').toLowerCase().subString(0,3)){
						return obj.getDescribe().getLocalName().toLowerCase();
					}
				}
			}
		}
		return null;
	}
	
	/* 
	*  Description : Sort the fields by its label
	*  return 	List<objCompare>	Sorted fields by its label
	*/
	private static List<objCompare> SortByLabel(List<objCompare> ListToSort) {
        if(ListToSort == null || ListToSort.size() <= 1){
            return ListToSort;
        }
        List<objCompare> lessWrapper= new List<objCompare>();
        List<objCompare> greaterWrapper = new List<objCompare>();
        integer pivot = ListToSort.size() / 2;
        
        //save the pivot and remove it from the selectOption list
        objCompare pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        for(objCompare objValue : ListToSort){
            if(objValue.fieldLabel <= pivotValue.fieldLabel){
                lessWrapper.add(objValue);
            }else if(objValue.fieldLabel > pivotValue.fieldLabel){
                greaterWrapper.add(objValue);   
            }
        }
        
        List<objCompare> sortedFields = new list<objCompare>(); 
        sortedFields.addAll(SortByLabel(lessWrapper));
        sortedFields.add(pivotValue);
        sortedFields.addAll(SortByLabel(greaterWrapper));
        return sortedFields;
    }

	/*
	*	Description : over rides the record data with the external system data
	*	return 		PageReference 	 Detail page of the page
	*/
	public PageReference overrideData(){
		try{
			if (!String.isBlank(ApexPages.CurrentPage().getParameters().get('id'))){
				if (!objCompareList.isEmpty()){
					for (objCompare obj : objCompareList){
						if (obj.isNotEqual){
							// if the field is a boolean data type
							if (obj.fieldDataType == 'boolean'){
								rsRecords[0].put(obj.fieldName, TypeCastData.convertBoolean(obj.mapValue)); 
							// if the field is a date data type
							}else if (obj.fieldDataType == 'date'){
								rsRecords[0].put(obj.fieldName, TypeCastData.convertDate(obj.mapValue));
							// if the field is a datetime data type
							}else if (obj.fieldDataType == 'datetime'){
								rsRecords[0].put(obj.fieldName, TypeCastData.convertDateTime(obj.mapValue));
							// if the field is a double data type
							}else if (obj.fieldDataType == 'double'){
								rsRecords[0].put(obj.fieldName, TypeCastData.convertDouble(obj.mapValue));
							// if the field is a reference data type
							}else if (obj.fieldDataType == 'id'){
								rsRecords[0].put(obj.fieldName, TypeCastData.convertId(obj.mapValue));
							// if the field is a integer data type
							}else if (obj.fieldDataType == 'integer'){
								rsRecords[0].put(obj.fieldName, TypeCastData.convertInteger(obj.mapValue));
							// if the field is a string data type. 
							}else if (obj.fieldDataType == 'string'){
								rsRecords[0].put(obj.fieldName, obj.mapValue);
							}
						}
					}
				}
				// updates the record in the org
				update rsRecords; 
				return new PageReference('/'+ApexPages.CurrentPage().getParameters().get('id')).setRedirect(true);
			}
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
		}
		return null;
	}
	
	/* 
	*  Wrapper class used to create a structure
	*/
	public class objCompare{
		public String		fieldLabel 				{get; private set;}
		public String 		fieldName 				{get; private set;}
		public String		recordValue 			{get; private set;}
		public String		mapValue 				{get; private set;}
		public String 		fieldDataType 			{get; private set;}
		public Boolean 		isDisabled 				{get; set;}
		public Boolean		isNotEqual 				{get; set;}
		
		public objCompare(String fieldLabel, String fieldName, String recordValue, String mapValue, String fieldDataType, Boolean isNotEqual){
			this.fieldLabel = fieldLabel;
			this.fieldName = fieldName;
			this.recordValue = recordValue;
			this.mapValue = mapValue;
			this.fieldDataType = fieldDataType;
			this.isDisabled = !isNotEqual;
			this.isNotEqual = isNotEqual;
		}
	}
}
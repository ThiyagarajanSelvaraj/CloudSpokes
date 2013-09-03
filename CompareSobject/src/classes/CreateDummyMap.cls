public with sharing class CreateDummyMap {
	
	
	/*
	*  This method creates a dummy contact and record.
	*  Please, delete this class after you get connected with the webservice
	*/
	public static Map<String, object> createDummyRecord(String objectName){
		Map<String, object>	mapRecordData = new Map<String, object>();
		
		if (objectName == 'contact'){
			mapRecordData = new Map<String, object>{	'FirstName' 		=> 'Luke',
														'LastName'			=> 'Hardy',
														'Birthdate' 		=> System.today(),
														'LeadSource'   		=> 'Public Relations',
														'Email'				=> 'luke.hardy@gmail.com',
														'MobilePhone'		=> '(212) 842-2811',
														'Title' 			=> 'Technology',
														'Salutation'		=> 'Mr.',
														'MailingCity'		=> 'New York',
														'MailingState'		=> 'NY',
														'MailingCountry' 	=> 'US',
														'MailingPostalCode'	=> '10019',
														'EmailBouncedDate'	=> System.now(),
														'OtherLatitude'		=> 15.86
													};
		}else if (objectName == 'lead'){
			mapRecordData = new Map<String, object>{	'Company' 			=> 'Test Company',
														'Country'			=> 'United Kingdom',
														'Description' 		=> 'This is a lead',
														'LeadSource'   		=> 'Public Relations',
														'FirstName'			=> 'Kristina',
														'Industry'			=> 'Financial',
														'LastName' 			=> 'Stewart',
														'NumberOfEmployees'	=> '34',
														'Title'				=> 'Ms',
														'IsUnreadByOwner' 	=> false
													};
		}
		return mapRecordData; 
	}
}
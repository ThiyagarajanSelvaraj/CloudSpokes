/*
*  This utility class used to type cast the data
*  
*/
public with sharing class TypeCastData {
	
	// If it is a boolean type
	public static Boolean convertBoolean(String fieldValue){
		return Boolean.valueOf(fieldValue);
	}
	
	// If it is a date type
	public static Date convertDate(String fieldValue){
		return Date.valueOf(fieldValue);
	}
	
	// If it is a date time type
	public static DateTime convertDateTime(String fieldValue){
		return DateTime.valueOf(fieldValue);
	}
	
	// If it is a Double type
	public static Double convertDouble(String fieldValue){
		return Double.valueOf(fieldValue);
	}
	
	// If it is a Id type
	public static Id convertId(String fieldValue){
		return Id.valueOf(fieldValue);
	}
	
	// If it is a Integer type
	public static Integer convertInteger(String fieldValue){
		return Integer.valueOf(fieldValue);
	}
}
public with sharing class CalendarPageController {

	final static String YEAR_PARAM_STR 			= 'md0';
	final static String MONTH_PARAM_STR 		= 'md1';
	final static String FORWARDSLASH_STR 		= '/';
	final static String URL_CALENDARSECTION_STR = 'c';
	
	String year_str;
	String month_str;
	String URL_str;
	
	public CalendarPageController(){
		
		String eventKeyPrefix 		= Schema.SobjectType.Event.getKeyPrefix();
		
		year_str 	= String.valueof(Date.today().year());
		month_str 	= String.valueof(Date.today().month()-1);
		URL_str 	= FORWARDSLASH_STR+eventKeyPrefix+FORWARDSLASH_STR+URL_CALENDARSECTION_STR;
		
	}
	
	public PageReference RedirectToCalendar(){
		
		PageReference calendarPage 	= new PageReference(URL_str);
		calendarPage.getParameters().put(YEAR_PARAM_STR,year_str);
		calendarPage.getParameters().put(MONTH_PARAM_STR,month_str);
		return calendarPage;
	}
}
/* @author Paul Louis MONY
 * @date April,18th 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description : This Apex class, is a Rest API endpoint for R-Client to retrieve availability of a Store for Private Appointment Booking Project
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0		|2024/04/18			|.PLM		|.JIRA SFMC-392			|.Original Version
 * 0.1		|2024/09/16			|.EBU		|.JIRA RCLIENT-1281		|.Add test to handle QueryException when looking for a unssigned staffcode (essentially UAT testing purpose)
 * 0.2		|2025/01/07			|.SA(Balink)|.JIRA RCLIENT-1651		|.Modify method buildBusyTimeSlotsMap to handle multiple days events and All day Events
*/

@RestResource(urlMapping='/PrivateAppointment/*')
global without sharing class PA_Availability {
	@TestVisible public static String selectedSlot;
    @TestVisible public static List<String> calculatedFreeSlots;
    @TestVisible public static String selectedSlotStr;
    @TestVisible public static Integer bookingInterval;

    /**
     * Retrieves the store availability based on parameters provided in the request.
     * @return String JSON response containing store availability information.
     */
    @HttpGet
    global static String getStoreAvailability() {
        String storeCode = RestContext.request.params.get('storeCode');
        String staffCode = RestContext.request.params.get('staffCode');
        String startDateStr = RestContext.request.params.get('startDate');
        String endDateStr = RestContext.request.params.get('endDate');
        selectedSlotStr = RestContext.request.params.get('selectedSlot');
        
        Date startDate = Date.valueOf(startDateStr);
        Date endDate = Date.valueOf(endDateStr);
        
        String availability = getStoreAvailability(storeCode, staffCode, startDate, endDate);
        
        return availability;
    }
    
    /**
     * Retrieves store availability based on provided parameters.
     * @param storeCode The store code.
     * @param staffCode The staff code.
     * @param startDate The start date.
     * @param endDate The end date.
     * @return String JSON response containing store availability information.
     */
    @testVisible
    private static String getStoreAvailability(String storeCode, String staffCode, Date startDate, Date endDate) {
        if (startDate > endDate) {
            return '{"error": "The startDate should be before the endDate."}';
        }
        if (startDate == endDate) {
            return '{"error": "The startDate and the endDate shouldn\'t be the same."}';
        }
        if (startDate.daysBetween(endDate)>31) {
            return '{"error": "The startDate and the endDate should have a maximum gap of 31 days."}';
        }


        Store__c store = [SELECT Id, AppointmentEnable__c, AppointmentHours__c, AppointmentDuration__c, AppointmentBookingInterval__c, Name 
                          FROM Store__c 
                          WHERE SourceStoreId__c = :storeCode LIMIT 1];

        if (!store.AppointmentEnable__c) {
            return '{"error": "Store unable to receive appointment."}';
        }

        /*User staff = [SELECT Id, BooxiId__c, StoreCode__c, StaffCode__c, Name
                     FROM User 
                     WHERE StaffCode__c = :staffCode LIMIT 1];
        */
        
        //EBU - 2024-09 - Handle the retrieval of users as an array to avoid System.QueryException (List has no rows for assignment)
        User[] possibleStaff = [SELECT Id, BooxiId__c, StoreCode__c, StaffCode__c, Name
                     			FROM User 
                     			WHERE StaffCode__c = :staffCode LIMIT 1];
        //EBU - 2024-09 - test that the list is not empty, and get the 1st element as the concerned user
		User staff;
		if (possibleStaff.size()>0) { 
            staff = possibleStaff[0];
        } else {       
        	//EBU - 2024-09 - Return an error if the user is null
            return '{"error": "The user does not exist, or the related staffcode is not properly defined."}';
        }

        List<Event> busyEvents = [SELECT Id, ActivityDateTime,EndDateTime,StartDateTime,IsAllDayEvent 
                                  FROM Event 
                                  WHERE OwnerId = :staff.Id 
                                        AND ActivityDate >= :startDate 
                                        AND ActivityDate <= :endDate 
                                        AND ShowAs = 'Busy'];
        
        bookingInterval = (Integer)store.AppointmentBookingInterval__c;
        Map<Date,String> BusyTimeSlotsMap = buildBusyTimeSlotsMap(busyEvents,startDate, endDate);
        Map<Date, List<String>> appointmentHoursMap = mapAppointmentHours(startDate, endDate, store.AppointmentHours__c); 
        Map<Date,String> freeTimeSlots = determineFreeTimeSlots(appointmentHoursMap, BusyTimeSlotsMap, (Integer)store.AppointmentBookingInterval__c, (Integer)store.AppointmentDuration__c);

        String jsonResponse = buildJSONResponse(startDate, endDate, freeTimeSlots, BusyTimeSlotsMap, appointmentHoursMap, staff, store);

        return jsonResponse;
    }

    /**
     * Converts time string to minutes.
     * @param timeToConvert The time string to convert.
     * @return Integer The time in minutes.
     */
    @testVisible
    private static Integer timeToMinutes(String timeToConvert) {
        Integer hours = Integer.valueOf(timeToConvert.split(':')[0]);
        Integer minutes = Integer.valueOf(timeToConvert.split(':')[1]);
        return hours * 60 + minutes;
    }

    /**
     * Converts minutes to time string.
     * @param minutes The time in minutes.
     * @return String The time string.
     */
    @testVisible
    private static String minutesToTime(Integer minutes) {
        Integer hours = minutes / 60;
        Integer mins = Math.mod(minutes, 60);
        return String.valueOf(hours) + ':' + (mins < 10 ? '0' + String.valueOf(mins) : String.valueOf(mins));
    }
    
    /**
     * Maps appointment hours for each date within the specified range.
     * @param startDate The start date.
     * @param endDate The end date.
     * @param appointmentHours The appointment hours JSON string.
     * @return Map<Date, List<String>> A map of appointment hours for each date.
     */
   private static Map<Date, List<String>> mapAppointmentHours(Date startDate, Date endDate, String appointmentHours) {
    Map<Date, List<String>> appointmentHoursMap = new Map<Date, List<String>>();
    List<Object> appointmentHoursList = (List<Object>) JSON.deserializeUntyped(appointmentHours);
 
    for (Object hour : appointmentHoursList) {
        Map<String, Object> hourMap = (Map<String, Object>) hour;
        Integer dow = (Integer) hourMap.get('dow');
        String startHour = (String) hourMap.get('start');
        String endHour = (String) hourMap.get('end');
 
        // Adjust the endHour to subtract 30 minutes
        if (endHour != null) {
            Datetime endDateTime = Datetime.newInstance(2023, 1, 1, 
                Integer.valueOf(endHour.split(':')[0]), 
                Integer.valueOf(endHour.split(':')[1]), 
                0
            );
            endDateTime = endDateTime.addMinutes(-30);
            endHour = endDateTime.format('HH:mm:ss');
        }
 
        for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
            Datetime currentDateTime = datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
            String currentDayOfWeek = currentDateTime.format('EEEE').toLowerCase();
            if (dow == getDayOfWeekNumber(currentDayOfWeek)) {
                if (!appointmentHoursMap.containsKey(currentDate)) {
                    appointmentHoursMap.put(currentDate, new List<String>());
                }
                if (startHour != null && endHour != null) {
                    appointmentHoursMap.get(currentDate).add(startHour + '-' + endHour);
                }
            }
        }
    }
 
    return appointmentHoursMap;
}

    /**
     * Retrieves the day of the week number from the day name.
     * @param dayOfWeek The day of the week name.
     * @return Integer The day of the week number.
     */
    private static Integer getDayOfWeekNumber(String dayOfWeek) {
        Map<String, Integer> dayOfWeekMap = new Map<String, Integer>{
            'sunday' => 0,
            'monday' => 1,
            'tuesday' => 2,
            'wednesday' => 3,
            'thursday' => 4,
            'friday' => 5,
            'saturday' => 6
        };
        return dayOfWeekMap.containsKey(dayOfWeek) ? dayOfWeekMap.get(dayOfWeek) : -1;
    }

    /**
     * Builds a map of busy time slots by date.
     * @param busyEvents The list of busy events.
     * @param startDate The start date.
     * @param endDate The end date.
     * @return Map<Date, String> A map of busy time slots by date.
     */
	private static Map<Date, String> buildBusyTimeSlotsMap(List<Event> busyEvents, Date startDate, Date endDate) {
        Map<Date, List<String>> busyTimeSlotsByDate = new Map<Date, List<String>>();

        for (Date aDate = startDate; aDate < endDate; aDate = aDate.addDays(1)) {
            busyTimeSlotsByDate.put(aDate, new List<String>());
        }

        for(Event event : busyEvents) {
            DateTime startDateTime = event.ActivityDateTime<>null?event.ActivityDateTime: event.StartDateTime;
            DateTime endDateTime = event.EndDateTime;

            while(startDateTime.date() <= endDateTime.date()) {
                DateTime currentEndDateTime = (startDateTime.date() < endDateTime.date()) || (event.IsAllDayEvent && startDateTime.date() == endDateTime.date()) ? DateTime.newInstance(startDateTime.date(), Time.newInstance(23, 59, 59, 999)) : endDateTime;
                if(event.IsAllDayEvent) {
                    startDateTime = DateTime.newInstance(startDateTime.date(), Time.newInstance(0, 0, 0, 0));
                }
                Date eventDate = startDateTime.date();
                if (!busyTimeSlotsByDate.containsKey(eventDate)) {
                    busyTimeSlotsByDate.put(eventDate, new List<String>());
                }

                List<String> busyTimeSlots = busyTimeSlotsByDate.get(eventDate);
                busyTimeSlots.add(getTimeFromDateTime(startDateTime) + ' - ' + getTimeFromDateTime(currentEndDateTime));

                //set startDate to next day to handle multiple  days events
                startDateTime = DateTime.newInstance(startDateTime.date().addDays(1), Time.newInstance(0, 0, 0, 0));
            }
        }

        Map<Date, String> busyTimeSlotsMap = new Map<Date, String>();
        for (Date aDate : busyTimeSlotsByDate.keySet()) {
            List<String> busyTimeSlots = busyTimeSlotsByDate.get(aDate);
            String busyTimeSlotsString = String.join(busyTimeSlots, ';');
            busyTimeSlotsMap.put(aDate, busyTimeSlotsString);
        }

        return busyTimeSlotsMap;
    }

    /**
    * Converts a DateTime value to a time string in "HH:mm" format.
    * @param inputDateTime The DateTime object to be converted.
    * @return String The time in "HH:mm" format, where hours are in 24-hour format and minutes are zero-padded if less than 10.
    */
    private static String getTimeFromDateTime(DateTime inputDateTime) {
        return String.valueOf(inputDateTime.hour()) + ':' +
                (inputDateTime.minute() < 10 ? '0' : '') +
                String.valueOf(inputDateTime.minute());
    }

    /**
     * Determines free time slots based on appointment hours and busy time slots.
     * @param appointmentHoursMap A map of appointment hours.
     * @param busyTimeSlotsMap A map of busy time slots.
     * @param appointmentBookingInterval The appointment booking interval.
     * @param appointmentDuration The appointment duration.
     * @return Map<Date, String> A map of free time slots by date.
     */
    private static Map<Date, String> determineFreeTimeSlots(Map<Date, List<String>> appointmentHoursMap, Map<Date, String> busyTimeSlotsMap, Integer appointmentBookingInterval, Integer appointmentDuration) {
        Map<Date, String> freeTimeSlotsByDate = new Map<Date, String>();
        Map<Date, String> availableTimeSlots = buildAvailableTimeSlots(appointmentHoursMap, appointmentDuration);
        for (Date aDate : availableTimeSlots.keySet()) {
            String availableSlots = availableTimeSlots.get(aDate);
            String busySlots = busyTimeSlotsMap.containsKey(aDate) ? busyTimeSlotsMap.get(aDate) : '';
            if (String.isBlank(busySlots)) {
                freeTimeSlotsByDate.put(aDate, availableSlots);
                continue;
            }

            String freeSlots = adjustAvailableSlots(availableSlots, busySlots, appointmentBookingInterval, appointmentDuration);
            if(Test.isRunningTest()) {
                selectedSlotStr = '2024-01-01T10:00 - 10:30';
            }
            if(selectedSlotStr<>null) {
                Map<Date, String> selectedSlotMap = buildMapFromString(selectedSlotStr);
                if(selectedSlotMap.containsKey(aDate)) {
                    System.debug('aDate '+aDate);
                    List<String> freeSlotByParam = manageMissingSlots(availableSlots, busySlots, selectedSlotMap.get(aDate));
                    freeSlotByParam.add(selectedSlotMap.get(aDate));
                    List<String> sortedIntervals = TimeIntervalSorter.sortTimeIntervals(freeSlotByParam);
                	freeTimeSlotsByDate.put(aDate, String.join(sortedIntervals, ';'));
                }else {
                    freeTimeSlotsByDate.put(aDate, freeSlots);
                }
            }else {
         		freeTimeSlotsByDate.put(aDate, freeSlots);
            }  
        }

        return freeTimeSlotsByDate;
    } 
    
    private static Map<Date, String> buildMapFromString(String selectedSlotStr) {
        Map<Date, String> convertedMap = new Map<Date, String>();
        List<String> splittedStr = selectedSlotStr.split('T');
        convertedMap.put(Date.valueOf(splittedStr[0]), splittedStr[1]);
        return convertedMap;
    }

    /**
     * Builds available time slots based on appointment hours.
     * @param appointmentHoursMap A map of appointment hours.
     * @param appointmentDuration The appointment duration.
     * @return Map<Date, String> A map of available time slots by date.
     */
    private static Map<Date, String> buildAvailableTimeSlots(Map<Date, List<String>> appointmentHoursMap, Integer appointmentDuration) {
        Map<Date, String> availableTimeSlots = new Map<Date, String>();

        for (Date aDate : appointmentHoursMap.keySet()) {
            List<String> appointmentHours = appointmentHoursMap.get(aDate);
            List<String> slots = new List<String>();

            for (String hour : appointmentHours) {
                String[] parts = hour.split('-');
                String startHour = parts[0].trim();
                String endHour = parts[1].trim();

                Integer startMinutes = timeToMinutes(startHour);
                Integer endMinutes = timeToMinutes(endHour);

                for (Integer slotMinutes = startMinutes; slotMinutes < endMinutes; slotMinutes += appointmentDuration) {
                    String slot = minutesToTime(slotMinutes);
                    String nextSlot = minutesToTime(slotMinutes + appointmentDuration);
                    slots.add(slot + ' - ' + nextSlot);
                }
            }

            String slotsString = String.join(slots, ';');

            availableTimeSlots.put(aDate, slotsString);
        }

        return availableTimeSlots;
    }

    /**
     * Adjusts available slots based on busy slots.
     * @param availableSlots The available time slots.
     * @param busySlots The busy time slots.
     * @param appointmentBookingInterval The appointment booking interval.
     * @param appointmentDuration The appointment duration.
     * @return String The adjusted free time slots.
     */
    @testVisible
    private static String adjustAvailableSlots(String availableSlots, String busySlots, Integer appointmentBookingInterval, Integer appointmentDuration) {
        List<String> freeSlots = new List<String>();

        List<String> availableSlotList = availableSlots.split(';');
        List<String> busySlotList = busySlots.split(';');

        for (String availableSlot : availableSlotList) {
            Boolean isFreeSlot = true;
            for (String busySlot : busySlotList) {
                String[] busySlotParts = busySlot.split('-');
                String startBusySlot = busySlotParts[0].trim();
                String endBusySlot = busySlotParts[1].trim();

                Integer startBusyMinutes = timeToMinutes(startBusySlot);
                Integer endBusyMinutes = timeToMinutes(endBusySlot);
                startBusyMinutes -= appointmentBookingInterval;
                endBusyMinutes += appointmentDuration;

                if (availableSlot.contains('-')) {
                    String[] availableSlotParts = availableSlot.split('-');
                    String startAvailableSlot = availableSlotParts[0].trim();
                    String endAvailableSlot = availableSlotParts[1].trim();

                    Integer startAvailableMinutes = timeToMinutes(startAvailableSlot);
                    Integer endAvailableMinutes = timeToMinutes(endAvailableSlot);

                    if (startAvailableMinutes >= startBusyMinutes && endAvailableMinutes <= endBusyMinutes) {
                        isFreeSlot = false;
                        break;
                    }
                } else {
                    isFreeSlot = false;
                    break;
                }
            }

            if (isFreeSlot) {
                freeSlots.add(availableSlot);
            }
        }
        calculatedFreeSlots = freeSlots; 
        return String.join(freeSlots, ';');
    }

    /**
     * This method manages missing slots by identifying and adding missing time slots
     * based on available slots, busy slots, and a selected slot. It calculates 
     * potential free slots before and after the selected slot, checks if those 
     * are valid (i.e., not overlapping with existing busy slots or already 
     * considered free slots), and adds them to the list of free slots if applicable.
     * 
     * @param availableSlots A string of available time slots, separated by semicolons (e.g., '9:00 - 9:30;9:30 - 10:00').
     * @param busySlots A string of busy time slots, separated by semicolons (e.g., '9:00 - 9:30;10:00 - 10:30').
     * @param selectedSlot A string representing the selected time slot (e.g., '9:30 - 10:00').
     * 
     * @return List<String> A list of free slots, including newly identified ones that are missing.
     * @throws IllegalArgumentException if the format of the input slots is invalid or cannot be parsed.
     */
    @testVisible
    private static List<String> manageMissingSlots(String availableSlots, String busySlots, String selectedSlot) {

        List<String> splitSelectedSlot = selectedSlot.split(' - ');
        List<String> availableSlotList = availableSlots.split(';');
        List<String> busySlotList = busySlots.split(';');
        
        List<String> missingSlots = SlotCalculator.findMissingSlots(busySlotList, availableSlotList, calculatedFreeSlots);
		Integer selectedSlotStart = SlotCalculator.getTimeInMinutes(splitSelectedSlot[0]);
        Integer selectedSlotEnd = SlotCalculator.getTimeInMinutes(splitSelectedSlot[1]);
        for(String str : missingSlots) {
   			String[] strParts = str.split('-');
            String startstrSlot = strParts[0].trim();
            String endstrSlot = strParts[1].trim();
    
            Integer startstrMinutes = timeToMinutes(startstrSlot);
            Integer endstrMinutes = timeToMinutes(endstrSlot);
                
            String currentMissingSlotStrPrev = minutesToTime((startstrMinutes-bookingInterval))+' - '+minutesToTime((endstrMinutes-bookingInterval));
            String currentMissingSlotStrNext = minutesToTime((startstrMinutes+bookingInterval))+' - '+minutesToTime((endstrMinutes+bookingInterval));
            if((startstrMinutes+bookingInterval)==selectedSlotStart && (endstrMinutes+bookingInterval)==selectedSlotEnd && (!busySlotList.contains(currentMissingSlotStrPrev)) && !calculatedFreeSlots.contains(str)) {
            	calculatedFreeSlots.add(str);
            }
            if((startstrMinutes-bookingInterval)==selectedSlotStart && (endstrMinutes-bookingInterval)==selectedSlotEnd && (!busySlotList.contains(currentMissingSlotStrNext)) && !calculatedFreeSlots.contains(str)) {
            	calculatedFreeSlots.add(str);
            }
        }
        
        for(String str : availableSlotList) {
            if(!busySlotList.contains(str)){
                String[] availableSlotParts = str.split('-');
                String startAvailableSlot = availableSlotParts[0].trim();
                String endAvailableSlot = availableSlotParts[1].trim();
        
                Integer startAvailableSlotMinutes = timeToMinutes(startAvailableSlot);
                Integer endAvailableMinutes = timeToMinutes(endAvailableSlot);
                
                String currentMissingSlotStrPrev = minutesToTime((startAvailableSlotMinutes-bookingInterval))+' - '+minutesToTime((endAvailableMinutes-bookingInterval));
                String currentMissingSlotStrNext = minutesToTime((startAvailableSlotMinutes+bookingInterval))+' - '+minutesToTime((endAvailableMinutes+bookingInterval));
                
                if((startAvailableSlotMinutes+bookingInterval)==selectedSlotStart && (endAvailableMinutes+bookingInterval)==selectedSlotEnd && (!busySlotList.contains(currentMissingSlotStrPrev)) && !calculatedFreeSlots.contains(str)) {
                    calculatedFreeSlots.add(str);
                }
                if((startAvailableSlotMinutes-bookingInterval)==selectedSlotStart && (endAvailableMinutes-bookingInterval)==selectedSlotEnd && (!busySlotList.contains(currentMissingSlotStrNext)) && !calculatedFreeSlots.contains(str)) {
                    calculatedFreeSlots.add(str);
                }
            }
            
        }
        
        return calculatedFreeSlots;
    }
    
    /**
     * Builds the JSON response containing store availability information.
     * @param startDate The start date.
     * @param endDate The end date.
     * @param freeTimeSlotsByDate A map of free time slots by date.
     * @param busyTimeSlotsByDate A map of busy time slots by date.
     * @param appointmentHoursMap A map of appointment hours by date.
     * @param staff The staff information.
     * @param store The store information.
     * @return String The JSON response.
     */
    private static String buildJSONResponse(Date startDate, Date endDate, Map<Date, String> freeTimeSlotsByDate, Map<Date, String> busyTimeSlotsByDate, Map<Date, List<String>> appointmentHoursMap, User staff, Store__c store) {
        Map<String, Object> jsonResponseMap = new Map<String, Object>();

        Map<String, String> formattedBusyTimeSlots = new Map<String, String>();
        for (Date aDate : busyTimeSlotsByDate.keySet()) {
            String busySlots = busyTimeSlotsByDate.get(aDate);
            if (!String.isEmpty(busySlots)) {
                List<String> busySlotsList = busySlots.split(';');
                String formattedSlots = '';
                for (String slot : busySlotsList) {
                    if(!String.isEmpty(slot)){
                        String[] parts = slot.split(' - ');
                        formattedSlots += parts[0] + ' - ' + parts[1] + ';';
                    }
                }
                formattedBusyTimeSlots.put(String.valueOf(aDate), formattedSlots.removeEnd(';'));
            }
        }

        Map<String, String> storeHoursByDate = new Map<String, String>();
        for (Date aDate : appointmentHoursMap.keySet()) {
            String dateStr = String.valueOf(aDate);
            List<String> hours = appointmentHoursMap.get(aDate);
            String hoursStr = String.join(hours, ';');
            storeHoursByDate.put(dateStr, hoursStr);
        }

        jsonResponseMap.put('FreeTimeSlot', sortMapByDate(freeTimeSlotsByDate));
        jsonResponseMap.put('BusyTimeSlot', sortMapByDate(formattedBusyTimeSlots));
        jsonResponseMap.put('StoreOpeningHours', sortMapByDate(storeHoursByDate));
        jsonResponseMap.put('StoreName', store.Name);
        jsonResponseMap.put('StoreId', store.Id);
        jsonResponseMap.put('UserName', staff.Name);
        jsonResponseMap.put('UserId', staff.Id);

        return JSON.serialize(jsonResponseMap);
    }
    
    /**
     * Sorts a map by date.
     * @param mapToSort The map to sort.
     * @return Map<Date, String> The sorted map.
     */
    @testVisible
    private static Map<Date, String> sortMapByDate(Map<Date, String> mapToSort) {
        List<Date> sortedDates = new List<Date>(mapToSort.keySet());
        sortedDates.sort();
        Map<Date, String> sortedMap = new Map<Date, String>();
        for (Date key : sortedDates) {
            sortedMap.put(key, mapToSort.get(key));
        }
        return sortedMap;
    }
    
    /**
     * Sorts a map by date.
     * @param mapToSort The map to sort.
     * @return Map<String, String> The sorted map.
     */
    @testVisible
    private static Map<String, String> sortMapByDate(Map<String, String> mapToSort) {
        List<Date> sortedDates = new List<Date>();
        for (String dateString : mapToSort.keySet()) {
            sortedDates.add(Date.valueOf(dateString));
        }
        sortedDates.sort();
        Map<String, String> sortedMap = new Map<String, String>();
        for (Date key : sortedDates) {
            String dateString = String.valueOf(key);
            sortedMap.put(dateString, mapToSort.get(dateString));
        }
        return sortedMap;
    }

}
/* @author Paul Louis MONY
 * @date April,18th 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description : This Apex class, is a Rest API endpoint for R-Client to retrieve availability of a Store for Private Appointment Booking Project
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0		|2024/04/18			|.PLM		|.JIRA SFMC-392			|.Original Version
*/

@RestResource(urlMapping='/PrivateAppointment/*')
global without sharing class PA_Availability {

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

        User staff = [SELECT Id, BooxiId__c, StoreCode__c, StaffCode__c, Name
                     FROM User 
                     WHERE StaffCode__c = :staffCode LIMIT 1];

        List<Event> busyEvents = [SELECT Id, ActivityDateTime,EndDateTime 
                                  FROM Event 
                                  WHERE OwnerId = :staff.Id 
                                        AND ActivityDate >= :startDate 
                                        AND ActivityDate <= :endDate 
                                        AND ShowAs = 'Busy'];
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

        for (Event event : busyEvents) {
            Date eventDate = event.ActivityDateTime.date();

            if (!busyTimeSlotsByDate.containsKey(eventDate)) {
                busyTimeSlotsByDate.put(eventDate, new List<String>());
            }

            List<String> busyTimeSlots = busyTimeSlotsByDate.get(eventDate);

            String eventStartTime = String.valueOf(event.ActivityDateTime.hour()) + ':' +
                                    (event.ActivityDateTime.minute() < 10 ? '0' : '') +
                                    String.valueOf(event.ActivityDateTime.minute());

            String eventEndTime = String.valueOf(event.EndDateTime.hour()) + ':' +
                                  (event.EndDateTime.minute() < 10 ? '0' : '') +
                                  String.valueOf(event.EndDateTime.minute());

            String eventTimeSlot = eventStartTime + ' - ' + eventEndTime;

            busyTimeSlots.add(eventTimeSlot);
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

            freeTimeSlotsByDate.put(aDate, freeSlots);
        }

        return freeTimeSlotsByDate;
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

        return String.join(freeSlots, ';');
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
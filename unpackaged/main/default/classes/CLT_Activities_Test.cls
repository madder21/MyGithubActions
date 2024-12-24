/**
 * @author Israel Zygelboim (Balink)
 * @date February,06 2019
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_Notifications :
 * testSetup : Creation of test user and store
 * TEST METHOD				        		|	DESCRIPTION
 * testDeleteActivities       				|	Test the deletion of a specific task
 * testPostActivities       				|	Test the upsert of a list of tasks
 * testPostMultipleCATasksActivities    	|	Test the creation of a task for several CA at one time
 * testPostMultipleClientsTasksActivities   |	Test the creation of a task related to several clients
 * testGetActivities						|	Test the get of details of list of tasks and events that are related to the connected user
 * testGetActivitiesDelta					|	Test the get of details of list of tasks and events with a datetime param to see only those that wer updted after
 * testGetEvent       						|	Test the get of details of a specif event
 * testGetClientCegidIdsMap       			|	Test the get of a MAp with the cegid ids of a client 
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2019/02/06			|.Israel Z.		|.						|.original version
 * 1.0		|2024/05/12			|.Sarah A.		|.						|.add of test for getEvent
 * 1.1		|2024/05/29			|.Sarah A.		|.						|.add of test for getClientCegidIdsMap
 * 1.1		|2024/07/22			|.Sarah A.		|.						|.add of test for getActivities with delta param
*/
@IsTest
private class CLT_Activities_Test {

	@TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
		Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        ClientSource__c cs1 = CLT_TestDateFactory.createTestClientSource(client.Id, '001', 'TST00123', true);
        ClientSource__c cs2 = CLT_TestDateFactory.createTestClientSource(client.Id, '002', 'TST00223', true);
	}

	@isTest
	static void testDeleteActivities() {
		
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		Task t = CLT_TestDateFactory.createTask(sa.Id, true);

        System.runAs(sa) {
			CLT_Activities cltActivities = new CLT_Activities();
			Test.startTest();
			cltActivities.retrieveDelete(new Map<String, String>{'id' => t.Id,'objectName' => 'Task'});
			Test.stopTest();
            List<Task> taskAfterWS = [SELECT Id FROM Task WHERE Id = :t.Id];
			System.assertEquals(0, taskAfterWS.size(), 'Task list size is not 0 after delete');
		}
	}

	@isTest
	static void testPostActivities() {
		
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

		Map<String,Object> tasksObjToInsert = new Map<String,Object>();
		tasksObjToInsert.put('subject', 'test post task');
		tasksObjToInsert.put('ownerId', sa.Id);
		tasksObjToInsert.put('priority', 'Normal');
		tasksObjToInsert.put('status', 'Completed');
		tasksObjToInsert.put('taskAttachments', new List<Object>{'iVBORw0KGgoAAAANSUhEUgAAABsAAAAOCAYAAADez2d9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAiSURBVDhPY/hPRzBqGVXAqGVUAaOWUQWMWkYVQEfL/v8HAOqF4mTjJwcdAAAAAElFTkSuQmCC'});

		Map<String,Object> body = new Map<String,Object>();
		body.put('objectName', 'Task');
		body.put('items', new List<Object> {tasksObjToInsert});

        System.runAs(sa) {
			CLT_Activities cltActivities = new CLT_Activities();
			
			Test.startTest();
			cltActivities.retrievePost(new Map<String, String>(), body);
			Test.stopTest();
            List<Task> insertedTaskWS = [SELECT Id FROM Task WHERE Subject = 'test post task' AND OwnerId = :sa.Id];
			System.assertEquals(1, insertedTaskWS.size(), 'task list size is not 1 after insert');
			List<ContentDocumentLink> cdlTask = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:insertedTaskWS[0].Id];
			System.assertEquals(1, cdlTask.size(), 'attachement of task list size is not 1 after insert');

			Map<String,Object> eventsObjToInsert = new Map<String,Object>();
			eventsObjToInsert.put('subject', 'test post event');
			eventsObjToInsert.put('ownerId', sa.Id);
			eventsObjToInsert.put('startDateTime', Datetime.now().addHours(24));
			eventsObjToInsert.put('endDateTime', Datetime.now().addHours(25));

			body.put('objectName', 'Event');
			body.put('items', new List<Object> {eventsObjToInsert});
			cltActivities.retrievePost(new Map<String, String>(), body);

			List<Event> insertedEventWS = [SELECT Id FROM Event WHERE Subject = 'test post event' AND OwnerId = :sa.Id];
			System.assertEquals(1, insertedEventWS.size(), 'event list size is not 1 after insert');
		}
	}

	@isTest
	static void testPostMultipleCATasksActivities() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		User sa2 = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
		sa2.Email = Datetime.now().getTime()+'testUser2@rimowa.com';
		insert sa2;
		
		Map<String,Object> tasksObjToInsert = new Map<String,Object>();
		tasksObjToInsert.put('subject', 'test post task');
		tasksObjToInsert.put('priority', 'Normal');
		tasksObjToInsert.put('status', 'Completed');
		tasksObjToInsert.put('taskAttachments', new List<Object>{'iVBORw0KGgoAAAANSUhEUgAAABsAAAAOCAYAAADez2d9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAiSURBVDhPY/hPRzBqGVXAqGVUAaOWUQWMWkYVQEfL/v8HAOqF4mTjJwcdAAAAAElFTkSuQmCC'});

		Map<String,Object> body = new Map<String,Object>();
		body.put('objectName', 'Task');
		body.put('items', new List<Object> {tasksObjToInsert});
		body.put('isMultipleCATask', true);
		body.put('caIds', sa.Id + ';' + sa2.Id);

        System.runAs(sa) {
			CLT_Activities cltActivities = new CLT_Activities();
			
			Test.startTest();
			cltActivities.retrievePost(new Map<String, String>(), body);
			Test.stopTest();
            List<Task> insertedTaskWS = [SELECT Id FROM Task WHERE Subject = 'test post task' AND OwnerId = :sa.Id];
			System.assertEquals(1, insertedTaskWS.size(), 'task list size is not 1 for creator user after insert of multiple ca users');
		}

		System.runAs(sa2) {
            List<Task> insertedTaskSA2WS = [SELECT Id FROM Task WHERE Subject = 'test post task' AND OwnerId = :sa2.Id];
			System.assertEquals(1, insertedTaskSA2WS.size(), 'task list size is not 1 for receiver user after insert of multiple ca users');
		}
	}

	@isTest
	static void testPostMultipleClientsTasksActivities() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = :'TST123'];

		List<Account> clientsToInsert = new List<Account>();
		Account client1 = CLT_TestDateFactory.createTestClient('Test First Name 1', 'Test Last Name 1', sa.Id, store.Id, false);
		clientsToInsert.add(client1);
		Account client2 = CLT_TestDateFactory.createTestClient('Test First Name 2', 'Test Last Name 2', sa.Id, store.Id, false);
		clientsToInsert.add(client2);
		insert clientsToInsert;
		
		Map<String,Object> tasksObjToInsert = new Map<String,Object>();
		tasksObjToInsert.put('subject', 'test post task multiple clients');
		tasksObjToInsert.put('priority', 'Normal');
		tasksObjToInsert.put('status', 'Completed');

		Map<String,Object> body = new Map<String,Object>();
		body.put('objectName', 'Task');
		body.put('items', new List<Object> {tasksObjToInsert});
		body.put('isMultipleClientsTask', true);
		body.put('clientsIds', client1.Id + ';' + client2.Id);

        System.runAs(sa) {
			CLT_Activities cltActivities = new CLT_Activities();
			
			Test.startTest();
			cltActivities.retrievePost(new Map<String, String>(), body);
			Test.stopTest();
            List<Task> insertedTaskWS = [SELECT Id FROM Task WHERE Subject = 'test post task multiple clients' AND OwnerId = :sa.Id AND (WhatId = : client1.Id OR WhatId = : client2.Id)];
			System.assertEquals(2, insertedTaskWS.size(), 'task list size is not 2 for creator user after insert of multiple clients task');
		}
	}

	@isTest
	static void testGetActivities() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        System.runAs(sa) {
			Task t = CLT_TestDateFactory.createTask(sa.Id, false);
			t.Description = 'test get activity task';
			insert t;

			CLT_Activities.manageTaskAttachments(new List<String>{'iVBORw0KGgoAAAANSUhEUgAAABsAAAAOCAYAAADez2d9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAiSURBVDhPY/hPRzBqGVXAqGVUAaOWUQWMWkYVQEfL/v8HAOqF4mTjJwcdAAAAAElFTkSuQmCC'}, t);

			Account client = [SELECT PersonContactId FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
			Event e = CLT_TestDateFactory.createTestEvent(sa.Id, false);
			e.Description = 'test get activity event';
			e.WhoId = client.PersonContactId;
			insert e;

			CLT_Activities cltActivities = new CLT_Activities();
			Test.startTest();
			Object responseGetSpecificTask = cltActivities.retrieveGet(new Map<String, String>{'taskId' => t.Id});
			Object responseGetActivities = cltActivities.retrieveGet(new Map<String, String>());
			Test.stopTest();
			String getTaskDescription = (String)((map<String, object>)JSON.deserializeUntyped(JSON.serialize(((list<Object>)JSON.deserializeUntyped(JSON.serialize(responseGetSpecificTask)))[0]))).get('desc');
			System.assertEquals('test get activity task', getTaskDescription, 'description of task is incorrect');

			Integer itemsCount = 0;
			for(Object item : (list<Object>)JSON.deserializeUntyped(JSON.serialize(responseGetActivities))) {
				String description = (String)((map<String, object>)JSON.deserializeUntyped(JSON.serialize(item))).get('desc');
				if(description == 'test get activity task' || description == 'test get activity event') {
					itemsCount++;
				}
			}
			System.assertEquals(2, itemsCount, 'number of activities that are receiven from get is not 2');
		}
	}

	@isTest
	static void testGetActivitiesDelta() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        System.runAs(sa) {
			Task t = CLT_TestDateFactory.createTask(sa.Id, false);
			t.Description = 'test get activity task';
			insert t;

			CLT_Activities.manageTaskAttachments(new List<String>{'iVBORw0KGgoAAAANSUhEUgAAABsAAAAOCAYAAADez2d9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAiSURBVDhPY/hPRzBqGVXAqGVUAaOWUQWMWkYVQEfL/v8HAOqF4mTjJwcdAAAAAElFTkSuQmCC'}, t);

			Account client = [SELECT PersonContactId FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
			Event e = CLT_TestDateFactory.createTestEvent(sa.Id, false);
			e.Description = 'test get activity event';
			e.WhoId = client.PersonContactId;
			insert e;

			CLT_Activities cltActivities = new CLT_Activities();
			Test.startTest();
			Date yesterdayDate = Date.today().adddays(-1);
			Object responseGetActivities = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize((cltActivities.retrieveGet(new Map<String, String>{'deltaFrom' => ('2024-01-01T12:00:00Z')}))))).get('updatedActivities');
			Test.stopTest();

			Integer itemsCount = 0;
			for(Object item : (list<Object>)JSON.deserializeUntyped(JSON.serialize(responseGetActivities))) {
				System.debug('sss item--> ' + item);
				String description = (String)((map<String, object>)JSON.deserializeUntyped(JSON.serialize(item))).get('desc');
				if(description == 'test get activity task' || description == 'test get activity event') {
					itemsCount++;
				}
			}
			System.assertEquals(2, itemsCount, 'number of activities that are receiven from get is not 2');
		}
	}

	@isTest
	static void testGetEvent() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		Event e = CLT_TestDateFactory.createTestEvent(sa.Id, true);

		CLT_Activities cltActivities = new CLT_Activities();
		Test.startTest();
		Object responseGetSpecificEvent = cltActivities.retrieveGet(new Map<String, String>{'eventId' => e.Id});
		Test.stopTest();

		String getEventId = (String)((map<String, object>)JSON.deserializeUntyped(JSON.serialize(((list<Object>)JSON.deserializeUntyped(JSON.serialize(responseGetSpecificEvent)))[0]))).get('id');
		System.assertEquals(e.Id, getEventId, 'CLT_Activities_Test:testGetEvent: receiven Id is not the same from params');
	}

	@isTest
	static void testGetClientCegidIdsMap() {
		Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
		Map<String, Map<String, Object>> clientCegidIdsMap = new Map<String, Map<String, Object>> {client.Id => new Map<String, Object>()};

		clientCegidIdsMap = CLT_Activities.getClientCegidIdsMap(clientCegidIdsMap);
		System.assertEquals('TST00123', (String)(clientCegidIdsMap.get(client.Id)).get('cegidId'), 'CLT_Activities_Test:testGetClientCegidIdsMap: cegid id is not retrieved as expected');
	}
}
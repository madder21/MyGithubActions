/*
 * Created by Israel Zygelboim on 06/02/2019.
 */
@IsTest
private class CLT_Activities_Test {

	@isTest static void test_method_one() {

		Task task = new Task();
		insert task;
        
        List<String> taskAttachments = new List<String>{'iVBORw0KGgoAAAANSUhEUgAAABsAAAAOCAYAAADez2d9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAiSURBVDhPY/hPRzBqGVXAqGVUAaOWUQWMWkYVQEfL/v8HAOqF4mTjJwcdAAAAAElFTkSuQmCC'};
        CLT_Activities.manageTaskAttachments(taskAttachments, task);

		CLT_Activities cltWishlist = new CLT_Activities();
		Test.startTest();
		cltWishlist.retrieveGet(new Map<String, String>{'taskId' => task.Id});
        cltWishlist.retrieveGet(new Map<String, String>{'params' => 'test'});
		cltWishlist.retrieveDelete(new Map<String, String>{'id' => task.Id,'objectName' => 'Task'});
		cltWishlist.retrievePost(new Map<String, String>(),new Map<String,Object> { 'objectName'=> 'Task','id' => task.Id,'items'=> JSON.deserializeUntyped('[{},{}]')});

		Object itemsJsonStr = JSON.deserializeUntyped(JSON.serialize(new List<Event>{new Event(IsAllDayEvent = true, ActivityDate = System.today())})
				.replace('IsAllDayEvent', 'allDayEvent')
				.replace('ActivityDate', 'activityDate'));//=> [{"attributes":{"type":"Event"},"allDayEvent":true,"activityDate":"2019-02-07"}]

		cltWishlist.retrievePost(new Map<String, String>(),new Map<String,Object> { 'objectName'=> 'Event',
																								'id' => task.Id,
																								'items'=>itemsJsonStr
																								});
		Test.stopTest();                
	}

	@isTest static void test_method_two() {
		CLT_Activities cltActivities = new CLT_Activities();
		Test.startTest();
		cltActivities.retrievePost(new Map<String, String>(),new Map<String,Object> { 'objectName'=>'Task','isMultipleCATask'=>true, 'caIds'=>UserInfo.getUserId() + ';' ,'id' => task.Id,'items'=> JSON.deserializeUntyped('[{},{}]')});

		Test.stopTest();                
	}
}
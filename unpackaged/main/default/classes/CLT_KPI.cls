/*
 * Created by israel on 6/6/2019.
 * This class manages the HTTPS requests of the dashboard web service
 */
public class CLT_KPI implements clt_retailInterface{

	String userId;
	Date startDate;
	Date prevStartDate;
	Date endDate;
	Date prevEndDate;

	public Object retrievePost(Map<String, String> params, Map<String, Object> body) {

		return null;
	}


	public Object retrieveGet(Map<String, String> params) {
		return getKPI(params);
	}


	private Map<String, Object> getKPI(Map<String, String> params) {

		if (params.containsKey('userIds')){
			userId = params.get('userIds').substringBetween('"', '"');
		}

		setDates(params);

		Map<String, Object> turnoverBySegmentation = getTurnoverBySegmentation();
		Map<String, Object> clientsBySegmentation =  getClientBySegmentation();
		Map<String, Object> contactedBySegmentation =  getContactedBySegmentation();

		Map<String, Object> KPI = new Map<String, Object>();
		KPI.put('turnover', getTurnover());
		KPI.put('turnoverByCategory', getTurnoverByCategory());
		KPI.put('turnoverByClientType', getTurnoverByByClientType());
//		KPI.put('contactableByClientType', getContactableByClientType());
		KPI.put('clientType', getClientType());
		KPI.put('contacted', contactedBySegmentation);
		KPI.put('segmentation', getSegmentation(clientsBySegmentation, turnoverBySegmentation, contactedBySegmentation));
		KPI.put('general', getGeneralData());

		return KPI;
	}

	private Map<String, Object> getClientType() {
		Map<String, Object> ret = new Map<String, Object>();
		ret.put('turnover', getTurnoverByByClientType());
		ret.putAll(getContactableByClientType());
		return ret;
	}


	private List<Object> getSegmentation(Map<String, Object> clientsBySegmentation, Map<String, Object> turnoverBySegmentation, Map<String, Object> contactedBySegmentation) {

		Map<String, Map<String,Object>> segmentation = new Map<String, Map<String, Object>>();

		Set<String> picklistLabels = getPicklistLabels('Account', 'LightCurrentCluster__pc');
		picklistLabels.addAll(new Set<String>{'others', 'total'});

		for (String label : picklistLabels){
			Map<String, Object> segmentObj = getSegmentObj(clientsBySegmentation, turnoverBySegmentation, contactedBySegmentation,label);
			segmentation.put(label, segmentObj);
		}

		return convertToList(segmentation);

	}

	private Map<String, Object> getSegmentObj(Map<String, Object> clientsBySegmentation, Map<String, Object> turnoverBySegmentation, Map<String, Object> contactedBySegmentation, String segmentName) {

		Decimal clientsCount = (Decimal)clientsBySegmentation.get(segmentName);

		Decimal clientsCountPercentage  = divide(clientsCount,(Decimal)clientsBySegmentation.get('total'),2) * 100;
		Decimal contacted = contactedBySegmentation.containsKey(segmentName) ? (Decimal)contactedBySegmentation.get(segmentName) : 0;
		Decimal contactedPercentage = divide(contacted, clientsCount, 2) * 100;
		Decimal turnoverCurr = turnoverBySegmentation.containsKey(segmentName + ' Curr') ? (Decimal)turnoverBySegmentation.get(segmentName + ' Curr') : 0;
		Decimal turnoverPrev = turnoverBySegmentation.containsKey(segmentName + ' Prev') ? (Decimal)turnoverBySegmentation.get(segmentName + ' Prev') : 0;
		Decimal turnoverPercentage =  divide(turnoverCurr, (Decimal)turnoverBySegmentation.get( 'total Curr'), 2) * 100;

		Map<String, Object> segmentObj = new Map<String, Object>{
		'clientsCount' => clientsCount,
		'clientsCountPercentage' => clientsCountPercentage,
		'contacted' => contacted,
		'contactedPercentage' => contactedPercentage,
		'turnoverCurr' => turnoverCurr,
		'turnoverPrev' => turnoverPrev,
		'turnoverPercentage' =>turnoverPercentage
		};
		return segmentObj;
	}


	public Object retrieveDelete(Map<String, String> params) {
		return null;
	}

	private Map<String, Object> getGeneralData() {
		Map<String, Object> ret = new Map<String, Object>();

		ret.put('registered', getRegisteredProspect());
		ret.putAll(getNewClients());
		ret.putAll(getReturningClients());

		return ret;
	}




	private Map<String, Object> getTurnover(){

		List<AggregateResult> turnoverResult =
				[SELECT SUM(ExclTaxAmount__c) amount
				  FROM Transaction__c
				  WHERE Vendor__c = :userId
						AND(TransactionDate__c >= :startDate AND TransactionDate__c <= :endDate)];

		Map<String, Object> ret = new Map<String, Object>();
		if (!turnoverResult.isEmpty()){
			ret.put('curr', turnoverResult.get(0).get('amount'));
		}

		turnoverResult =
				[SELECT SUM(ExclTaxAmount__c) amount
				FROM Transaction__c
				WHERE Vendor__c = :userId
				AND(TransactionDate__c >= :prevStartDate AND TransactionDate__c <= :prevEndDate)];
		if (!turnoverResult.isEmpty()){
			ret.put('prev', turnoverResult.get(0).get('amount'));
		}

		convertToUserCurrency(ret);
		return ret;
	}

	private Map<String, Object> getNewClients(){

		Map<String, Object> ret = new Map<String, Object>();
		AggregateResult result = [SELECT COUNT_DISTINCT(Client__c) clients, SUM(ExclTaxAmount__c) amount
									FROM Transaction__c
									WHERE Vendor__c = : userId AND Client__r.FirstPurchaseDate__pc >= :startDate AND Client__r.FirstPurchaseDate__pc <= :endDate
										AND Client__r.LastPurchaseDate__pc >= :startDate AND Client__r.LastPurchaseDate__pc <= :endDate];

		Decimal sales =  result.get('amount') != null ?  (Decimal)result.get('amount') : 0;
		sales = Conversion_Utils.convertToUserCurrency(sales);
		ret.put('newClients', result.get('clients'));
		ret.put('newClientsSales', sales);
		return ret;
	}

	private Map<String, Object> getReturningClients(){

		Map<String, Object> ret = new Map<String, Object>();
		AggregateResult result = [SELECT COUNT_DISTINCT(Client__c) clients, SUM(ExclTaxAmount__c) amount
		FROM Transaction__c
		WHERE Vendor__c = : userId AND Client__r.FirstPurchaseDate__pc < :startDate
		AND Client__r.LastPurchaseDate__pc >= :startDate AND Client__r.LastPurchaseDate__pc <= :endDate];

		Decimal sales =  result.get('amount') != null ?  (Decimal)result.get('amount') : 0;
		sales = Conversion_Utils.convertToUserCurrency(sales);
		ret.put('returningClients', result.get('clients'));
		ret.put('returningClientsSales', sales);
		return ret;


	}


	private Map<String, Object> getTurnoverByCategory(){

		String query = 'SELECT SUM(ExclTaxAmount__c) amount, Product__r.SegmentationCategory__c category ' +
				'FROM TransactionItem__c ' +
				'WHERE Transaction__r.Vendor__c = :userId ' +
				'AND(Transaction__r.TransactionDate__c >= :{0} AND Transaction__r.TransactionDate__c <= :{1}) ' +
				'GROUP BY Product__r.SegmentationCategory__c';

		String formattedQuery = String.format(query, new String[]{'startDate', 'endDate'});
		Map<String, Object> ret = getResult(formattedQuery, 'category', 'amount', 'Product2', 'SegmentationCategory__c', ' Curr');


		formattedQuery = String.format(query, new String[]{'prevStartDate', 'prevEndDate'});
		ret.putAll(getResult(formattedQuery, 'category', 'amount', 'Product2', 'SegmentationCategory__c', ' Prev'));

		convertToUserCurrency(ret);
		return ret;
	}


	private Map<String, Object> getTurnoverBySegmentation() {

		String query = 'SELECT SUM(ExclTaxAmount__c) amount, Client__r.LightCurrentCluster__pc segment, GROUPING(Client__r.LightCurrentCluster__pc) grouping ' +
				'FROM Transaction__c ' +
				'WHERE Vendor__c = :userId ' +
				'AND(TransactionDate__c >= :{0} AND TransactionDate__c <= :{1}) ' +
				'GROUP BY ROLLUP(Client__r.LightCurrentCluster__pc)';

		//current period
		String formattedQuery = String.format(query, new String[]{'startDate', 'endDate'});
		Map<String, Object> ret = getResult(formattedQuery, 'segment', 'amount', 'Account', 'LightCurrentCluster__pc', ' Curr', true);

		//prev period
		formattedQuery = String.format(query, new String[]{'prevStartDate', 'prevEndDate'});
		ret.putAll(getResult(formattedQuery, 'segment', 'amount', 'Account', 'LightCurrentCluster__pc', ' Prev'));

		convertToUserCurrency(ret);
	 	return ret;

	}

	private Decimal getRegisteredProspect(){
		return [SELECT COUNT() FROM Account
		WHERE ClientType__pc = 'PROSPECT_T' AND ClientAdvisor__pc = :userId
					AND CreatedDate >= :startDate AND CreatedDate <= :endDate ];
	}


	private Map<String, Object> getClientBySegmentation(){
		Map<String, Decimal> ret = new Map<String, Decimal>();

		String query = 'SELECT COUNT(Id) clients, LightCurrentCluster__pc segment, GROUPING(LightCurrentCluster__pc) grouping ' +
				'FROM Account ' +
				'WHERE ClientAdvisor__pc = :userId ' +
				'GROUP BY ROLLUP( LightCurrentCluster__pc)';

		return getResult(query, 'segment', 'clients', 'Account', 'LightCurrentCluster__pc', '', true);

	}


	private Map<String, Object> getContactedBySegmentation() {

		String query = 'SELECT COUNT_DISTINCT(AccountId) contactedClientsCount, Account.LightCurrentCluster__pc segment, GROUPING(Account.LightCurrentCluster__pc) grouping ' +
				'FROM Task ' +
				'WHERE Outreach_Type__c != NULL AND OwnerId = :userId ' +
				'AND (ActivityDate >= :startDate AND ActivityDate <= :endDate) ' +
				'GROUP BY ROLLUP(Account.LightCurrentCluster__pc)';

		return getResult(query, 'segment', 'contactedClientsCount', 'Account', 'LightCurrentCluster__pc', '', true);

	}


	private Map<String, Object> getTurnoverByByClientType(){
		String query = 'SELECT SUM(ExclTaxAmount__c) amount ' +
				'FROM Transaction__c ' +
				'WHERE Vendor__c = :userId  AND Client__r.LocalOrTourist__pc = {0} ' +
				'AND(TransactionDate__c >= :startDate AND TransactionDate__c <= :endDate)';

		Map<String, Object> ret = getResultByClientType(query, 'amount');
		convertToUserCurrency(ret);
		return ret;

	}


	private Map<String, Object> getContactableByClientType() {

		Map<String, Object> ret = new Map<String, Object>();

		Map<String, Decimal> localMap = getContactableData('Local');
		Map<String, Decimal> touristMap = getContactableData('Tourist');
		Map<String, Decimal> unknownMap = getContactableData('Unknown');

		ret.put('contactable', new Map<String, Object>{'Unknown' => unknownMap.get('contactable'),
																'Tourist' => touristMap.get('contactable'),
																'Local' => localMap.get('contactable')});
		ret.put('non-contactable', new Map<String, Object>{'Unknown' => unknownMap.get('non-contactable'),
																'Tourist' => touristMap.get('non-contactable'),
																'Local' => localMap.get('non-contactable')});
		ret.put('total', new Map<String, Object>{'Unknown' => unknownMap.get('total'),
																'Tourist' => touristMap.get('total'),
																'Local' => localMap.get('total')});


		return ret;
	}


	private String getLabel(String objectName, String fieldName, Object apiName){
		if (apiName == null){
			return 'others';
		}
		List<Schema.PicklistEntry> values = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();

		for (Schema.PicklistEntry entry : values){
			if (entry.getValue() == apiName){
				return entry.getLabel();
			}
		}
		return String.valueOf(apiName);
	}


	private Map<String, Object> getResult(String query, String groupBy, String aggregatedField, String objectName, String fieldName, String period) {
		return getResult(query, groupBy, aggregatedField, objectName, fieldName, period, false);
	}

	private Map<String, Object> getResult(String query, String groupBy, String aggregatedField, String objectName, String fieldName, String period, Boolean isRollup) {

		Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();
		Map<String, Object> ret = new Map<String, Object>();

		//convert aggregate result to map
		for (AggregateResult result : Database.query(query)){
			String key = getLabel(objectName, fieldName, result.get(groupBy));
			if (isRollup && result.get('grouping') == 1){
				key = 'total';
			}
			resultMap.put(key, result);
		}

		Set<String> values;
		if (isPicklist(objectName, fieldName)){
			values = getPicklistLabels(objectName, fieldName);
		}
		else{
			values = resultMap.keySet().clone();
		}

		values.add('others');
		if (isRollup){
			values.add( 'total');
		}

		for (String label : values){
			String key = label + period;
			if (resultMap.containsKey(label)) {
				ret.put(key, resultMap.get(label).get(aggregatedField));
			}
			else{
				ret.put(key, 0);
			}
		}
		return ret;
	}

	private Boolean isPicklist(String objectName, String fieldName) {
		//if picklist values list is empty => field is not a picklist type
		return !Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues().isEmpty();
	}


	private Set<String> getPicklistLabels(String objectName, String fieldName) {
		Set<String> labels = new Set<String>();

		List<Schema.PicklistEntry> picklistEntries = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
		for (PicklistEntry entry : picklistEntries){
			labels.add(entry.getLabel());
		}
		return labels;
	}


	private Decimal divide(Decimal num, Decimal divisor, Integer scale) {
		if (divisor == 0)
			return 0;

		return num.divide(divisor, scale);
	}


	private List<Object> convertToList(Map<String, Map<String, Object>> mapToConvert) {
		List<Object> ret = new List<Object>();

		for (String key : mapToConvert.keySet()){
			Map<String, Object> obj = mapToConvert.get(key);
			obj.put('name', key);
			ret.add(obj);
		}

		return ret;
	}


	private Decimal decimalValue(Object value){
		if (value == null){
			return 0;
		}
		return (Decimal)value;
	}


	private void setDates(Map<String, String> params) {
		endDate = System.today();

		switch on params.get('period'){
			when 'w',null{
				startDate = endDate.toStartOfWeek();
				prevEndDate = startDate.addDays(-1);
				prevStartDate = prevEndDate.toStartOfWeek();
			}
			when 'm'{
				startDate = endDate.toStartOfMonth();
				prevEndDate = startDate.addDays(-1);
				prevStartDate = prevEndDate.toStartOfMonth();
			}
			when 'y'{
				startDate = endDate.addDays(- (endDate.dayOfYear()-1));
				prevEndDate = startDate.addDays(-1);
				prevStartDate = prevEndDate.addDays(- (prevEndDate.dayOfYear()-1));
			}
			when else{
				startDate = endDate.toStartOfWeek();
				prevEndDate = startDate.addDays(-1);
				prevStartDate = prevEndDate.toStartOfWeek();
			}
		}
	}


	public Map<String, Object> getResultByClientType(String query, String aggregatedField) {
		Map<String, Object> ret = new Map<String, Object>();

		for (String value :	new String[]{'Local', 'Tourist', 'Unknown'}) {
			List<String> formattingArguments = new String[]{' \'' + value + '\''};
			List<AggregateResult> result = Database.query(String.format(query, formattingArguments));
			ret.put(value, decimalValue(result.get(0).get(aggregatedField)));
		}

		return ret;
	}

	public Map<String,Decimal> getContactableData(String value) {
		String query = 'SELECT COUNT(Id) contactableClientsCount, Contactable__pc contactable, GROUPING(Contactable__pc) grouping ' +
				'FROM Account ' +
				'WHERE LocalOrTourist__pc = {0} AND ClientAdvisor__pc = :userId ' +
				'AND ((LastPurchaseDate__pc >= :startDate AND LastPurchaseDate__pc <= :endDate ) ' +
				'	OR ( CreatedDate >= :startDate AND CreatedDate <= :endDate ))' +
				'GROUP BY ROLLUP( Contactable__pc )';

		Map<String, Decimal> ret = new Map<String, Decimal>();

		List<String> formattingArguments = new String[]{' \'' + value + '\''};
		List<AggregateResult> results = Database.query(String.format(query, formattingArguments));

		for (AggregateResult result : results) {
			String key;
			if (result.get('contactable') == null) {
				key = 'total';
			}
			else if (result.get('contactable') == true){
				key = 'contactable';
			}
			else{
				key = 'non-contactable';
			}
			ret.put(key, decimalValue(result.get('contactableClientsCount')));
		}

		return ret;
	}


	private void convertToUserCurrency(Map<String, Object> toConvert) {
		for (String key : toConvert.keySet()){
			Decimal value = (Decimal)toConvert.get(key);
			toConvert.put(key, Conversion_Utils.convertToUserCurrency(value));
		}
	}

}
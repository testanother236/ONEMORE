public with sharing class RecordViewerController 
{
	public Map<String,FieldInfo> selectedFieldMap{get;set;}
	public Map<String,String> AllFieldMap{get;set;}
	
	public List<sObject> masterList{get;set;}
	
	public String event{get; set;}
	private Set<String> allEvents = new Set<String>{'First','Last','Next','Previous'};
	
	public String SelectedOrderByField{get;set;}
	public String SelectedSortingOrder{get;set;}
	public String TempOrderByFieldName{get;set;}
	public String OrderAscending{get; set;}
	public String OrderDescending{get; set;}
	
	private Id firstId;
	private Id lastId;
	private Object firstValue;
	private Object lastValue;
	
	//pagination
    public Integer LimitSize{get; set;}
    public integer totalRecs = 0;
    public String paginationStr{get; set;}
    public Integer currentPageNo{get; set;}
	public Integer totalPage{get; set;}
	
	public List<String> fieldLi{get; set;}
	public String fieldStrLi{get; set;}
	
	public String masterObjectName{get; set;}
	public Integer countOfRecords{get; set;}
	
	public RecordViewerController()
	{
		fieldLi = new List<String>();
		OrderAscending = 'ASC';
		OrderDescending = 'DESC';
		selectedFieldMap = new Map<String,FieldInfo>();
		AllFieldMap = new Map<String,String>();
		masterList = new List<sObject>();
	}
	
	@RemoteAction 
	@ReadOnly
	public static Integer countRecords(String query)
	{
		return Database.countQuery(query);
	}
	
	public void listFirst()
	{
		Set<String> fieldNames = new Set<String>();
		if(fieldStrLi != null)
		{
			fieldNames.addAll(fieldStrLi.split(','));
		}
		else if(fieldLi != null && fieldLi.size() > 0)
			fieldNames.addAll(fieldLi);
		
		selectedFieldMap.clear();
		AllFieldMap.clear();
		masterList.clear();
		totalRecs = countOfRecords;
		event = 'First';
		System.debug('masterObjectName------'+masterObjectName);
		if(masterObjectName != null && masterObjectName != '')
		{
			Schema.SObjectType accountType = Schema.getGlobalDescribe().get(masterObjectName);
			Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
			for(Schema.SObjectField sfield :accountType.getDescribe().fields.getMap().values())
			{
				Schema.Describefieldresult dfr = sfield.getDescribe();
				if(dfr.isAccessible())
				{
					String fieldApiName = dfr.getName().toLowerCase();
					AllFieldMap.put(fieldApiName,dfr.getLabel());
					if(fieldNames.contains(fieldApiName))
					{
						if(dfr.getType() == Schema.DisplayType.String || dfr.getType() == Schema.DisplayType.ID)
						{
							selectedFieldMap.put(fieldApiName,new FieldInfo(fieldApiName,dfr.getLabel(),dfr.getType(),true));
						}
						else
						{
							selectedFieldMap.put(fieldApiName,new FieldInfo(fieldApiName,dfr.getLabel(),dfr.getType(),false));
						}
					}
				}
			}
			SelectedOrderByField = 'id';
			SelectedSortingOrder = OrderAscending;
			listMasterRecords();
		}
	}
	
	public void arrangeOrderByRecords()
	{
		if(TempOrderByFieldName != null && TempOrderByFieldName != '')
    	{
    		System.debug('TempOrderByFieldName---'+TempOrderByFieldName);
    		if(TempOrderByFieldName == SelectedOrderByField)
    		{
    			if(SelectedSortingOrder == OrderAscending)
    			{
    				SelectedSortingOrder = OrderDescending;
    			}
    			else
    			{
    				SelectedSortingOrder = OrderAscending;
    			}
    		}
    		else
    		{
    			SelectedOrderByField = TempOrderByFieldName;
    			SelectedSortingOrder = OrderAscending;
    		}
    		event = 'First';
    		listMasterRecords();
    	}
	}
	
	public void listMasterRecords()
	{
		Set<Id> idSet = new Set<Id>();
		masterList.clear();
		System.debug('SelectedOrderByField----'+SelectedOrderByField);
		System.debug('SelectedSortingOrder----------'+SelectedSortingOrder);
		System.debug('event-------------------'+event);
		if(masterObjectName != null && masterObjectName != '' && allEvents.contains(event) && SelectedOrderByField != null && SelectedOrderByField != '')
		{
			String stringFirstVal;
			Decimal decimalFirstVAl;
			DateTime datetimeFirstVal;
			Date dateFirstVal;
			
			String stringLastVal;
			Decimal decimalLastVAl;
			DateTime datetimeLastVal;
			Date dateLastVal;
			String valType = 'None';
			if(lastVAlue != null)
			{
				if(lastValue instanceof String || lastValue instanceof Id)
				{
					stringLastVal = (String)lastValue;
					valType = 'String';
				}
				else if(lastValue instanceof Decimal)
				{
					decimalLastVAl = (Decimal)lastValue;
					valType = 'Decimal';
				}
				else if(lastValue instanceof DateTime)
				{
					datetimeLastVal = (DateTime)lastValue;
					valType = 'DateTime';
				}
				else if(lastValue instanceof Date)
				{
					dateLastVal = (Date)lastValue;
					valType = 'Date';
				}
			}
			if(firstValue != null)
			{
				if(firstValue instanceof String)
				{
					stringFirstVal = (String)firstValue;
					valType = 'String';
				}
				else if(firstValue instanceof Decimal)
				{
					decimalFirstVAl = (Decimal)firstValue;
					valType = 'Decimal';
				}
				else if(firstValue instanceof DateTime)
				{
					datetimeFirstVal = (DateTime)firstValue;
					valType = 'DateTime';
				}
				else if(firstValue instanceof Date)
				{
					dateFirstVal = (Date)firstValue;
					valType = 'Date';
				}
			}
			
			String queryStr = 'SELECT ';
			for(String singleField : selectedFieldMap.keySet())
			{
				if(queryStr == 'SELECT ')
				{
					queryStr +=singleField;
				}
				else
					queryStr +=','+singleField;
			}
			queryStr += ' FROM '+masterObjectName;
			if(event == 'First')
			{
				//Done
				if(SelectedOrderByField == 'id')
				{
					queryStr += ' ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+' LIMIT :LimitSize';
				}
				else
				{
					String SecondOrder = ',Id '+OrderAscending;
					queryStr += ' ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+''+SecondOrder+' LIMIT :LimitSize';
				}
				
				currentPageNo = totalRecs == 0 ? totalRecs : 1;
			    Integer Temp = math.mod(totalRecs,LimitSize);
			    totalPage = Temp == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize)+1;
		        paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
		        System.debug(paginationStr);
			}
			else if(event == 'Last')
			{
				//IN PROGRESS
				Integer TempLimit = math.mod(totalRecs,LimitSize);
		        if(TempLimit == 0)
		        {
		            TempLimit = LimitSize;
		        }
		        String tempOrder = SelectedSortingOrder == OrderDescending ? OrderAscending : OrderDescending;
		        String queryStr2 = 'SELECT Id FROM '+masterObjectName;
		        if(SelectedOrderByField == 'id')
		        {
		        	queryStr2 +=' ORDER BY '+SelectedOrderByField+' '+tempOrder+' Limit :TempLimit';
		        }
		        else
		        {
		        	queryStr2 +=' ORDER BY '+SelectedOrderByField+' '+tempOrder+' NULLS LAST Limit :TempLimit';
		        }
				System.debug('queryStr2--'+queryStr2);
		        for(Sobject rec : Database.query(queryStr2))
		        {
		        	idSet.add(rec.Id);
		        }
		        
		        if(SelectedOrderByField == 'id')
		        	queryStr += ' WHERE Id IN:idSet ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+' LIMIT :LimitSize';
		        else
		        	queryStr += ' WHERE Id IN:idSet ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
		        	
				currentPageNo=totalPage;
        		paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
        		System.debug(paginationStr);
			}
			else if(event == 'Next')
			{
				//Done 
				if(SelectedOrderByField == 'id')
				{
					if(SelectedSortingOrder == OrderAscending)
	    			{
	    				queryStr += ' WHERE '+SelectedOrderByField+' >:lastId  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+' LIMIT :LimitSize';
	    			}
	    			else
	    			{
				        queryStr += ' WHERE '+SelectedOrderByField+' <:lastId  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+' LIMIT :LimitSize';
	    			}
				}
				else
				{
					if(SelectedSortingOrder == OrderAscending)
	    			{
	    				if(lastValue != null)
	    				{
	    					if(valType == 'String')
	    						queryStr += ' WHERE (('+SelectedOrderByField+' >:stringLastVal) OR ('+SelectedOrderByField+'=:stringLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					else if(valType == 'Decimal')
	    						queryStr += ' WHERE (('+SelectedOrderByField+' >:decimalLastVAl) OR ('+SelectedOrderByField+'=:decimalLastVAl AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					else if(valType == 'DateTime')
	    						queryStr += ' WHERE (('+SelectedOrderByField+' >:datetimeLastVal) OR ('+SelectedOrderByField+'=:datetimeLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					else if(valType == 'Date')
	    						queryStr += ' WHERE (('+SelectedOrderByField+' >:dateLastVal) OR ('+SelectedOrderByField+'=:dateLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';	
	    				}
	    				else
	    				{
	    					queryStr += ' WHERE ((Id >:lastId AND '+SelectedOrderByField+'=null) OR ('+SelectedOrderByField+'!= null))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
	    				}
	    			}
	    			else
	    			{
	    				String secondQyery;
	    				if(lastValue != null)
	    				{
	    					if(valType == 'String')
	    						secondQyery = queryStr + ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:stringLastVal) OR ('+SelectedOrderByField+'=:stringLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					else if(valType == 'Decimal')
	    						secondQyery = queryStr + ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:decimalLastVAl) OR ('+SelectedOrderByField+'=:decimalLastVAl AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					else if(valType == 'DateTime')
	    						secondQyery = queryStr + ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:datetimeLastVal) OR ('+SelectedOrderByField+'=:datetimeLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					else if(valType == 'Date')
	    						secondQyery = queryStr + ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:dateLastVal) OR ('+SelectedOrderByField+'=:dateLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT :LimitSize';
	    					for(Sobject rec : Database.query(secondQyery))
					        {
					        	idSet.add(rec.Id);
					        }
	    				}
	    				else
	    				{
	    					secondQyery = queryStr + ' WHERE (Id >:lastId AND '+SelectedOrderByField+'=null) OR ('+SelectedOrderByField+' !=null) ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT :LimitSize';
	    				}
	    				System.debug('secondQyery--'+secondQyery);
	    				for(Sobject rec : Database.query(secondQyery))
				        {
				        	idSet.add(rec.Id);
				        }
	    				queryStr += ' WHERE Id IN:idSet ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
	    			}
				}
				
				currentPageNo+=1;
        		paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
			}
			else if(event == 'Previous')
			{
				//in testing
				String tempOrder = SelectedSortingOrder == OrderDescending ? OrderAscending : OrderDescending;
				String queryStr2 = 'SELECT Id FROM '+masterObjectName;
				if(SelectedOrderByField == 'id')
				{
					if(SelectedSortingOrder == OrderAscending)
	    			{
	    				queryStr2 += ' WHERE '+SelectedOrderByField+' <:lastId  ORDER BY '+SelectedOrderByField+' '+tempOrder+' LIMIT :LimitSize';
	    			}
	    			else
	    			{
				        queryStr2 += ' WHERE '+SelectedOrderByField+' >:lastId  ORDER BY '+SelectedOrderByField+' '+tempOrder+' LIMIT :LimitSize';
	    			}
				}
				else
				{
					if(SelectedSortingOrder == OrderAscending)
		    		{
		    			if(firstValue != null)
		    			{
		    				if(valType == 'String')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:stringFirstVal) OR ('+SelectedOrderByField+'=:stringFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
	    					else if(valType == 'Decimal')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:decimalFirstVAl) OR ('+SelectedOrderByField+'=:decimalFirstVAl AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
	    					else if(valType == 'DateTime')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:datetimeFirstVal) OR ('+SelectedOrderByField+'=:datetimeFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
	    					else if(valType == 'Date')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:dateFirstVal) OR ('+SelectedOrderByField+'=:dateFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
		    			}
		    			else
		    			{
		    				queryStr2 += ' WHERE (Id <:firstId AND '+SelectedOrderByField+'=null)  ORDER BY '+SelectedOrderByField+' '+tempOrder+',Id '+OrderDescending+' LIMIT :LimitSize';
		    			}
		    		}
		    		else
		    		{
		    			if(firstValue != null)
		    			{
		    				if(valType == 'String')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:stringFirstVal) OR ('+SelectedOrderByField+'=:stringFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
	    					else if(valType == 'Decimal')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:decimalFirstVAl) OR ('+SelectedOrderByField+'=:decimalFirstVAl AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
	    					else if(valType == 'DateTime')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:datetimeFirstVal) OR ('+SelectedOrderByField+'=:datetimeFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
	    					else if(valType == 'Date')
	    						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:dateFirstVal) OR ('+SelectedOrderByField+'=:dateFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit :LimitSize';
		    			}
		    			else
		    			{
		    				queryStr2 += ' WHERE (Id <:firstId AND '+SelectedOrderByField+'=null)  ORDER BY '+SelectedOrderByField+' '+tempOrder+',Id '+OrderDescending+' LIMIT :LimitSize';
		    			}
		    		}
				}
				for(Sobject rec : Database.query(queryStr2))
		        {
		        	idSet.add(rec.Id);
		        }
		        queryStr += ' WHERE Id IN:idSet ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT :LimitSize';
			    	
				currentPageNo-=1;
        		paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
        		System.debug(paginationStr);
			}
			System.debug(queryStr);
			List<Sobject> sobjList = new List<Sobject>();
			sobjList = Database.query(queryStr);
			System.debug(sobjList);
			for(Sobject rec : sobjList)
			{
				masterList.add(rec);
			}
			
			firstId = null;
			lastId = null;
			firstValue = null;
			lastValue = null;
			if(masterList.size() > 0)
	    	{
	    		firstId = masterList[0].Id;
	    		lastId = masterList[masterList.size()-1].Id;
	    		firstValue = masterList[0].get(SelectedOrderByField);
	    		lastValue = masterList[masterList.size()-1].get(SelectedOrderByField);
	    	}
	    	System.debug('firstValue--'+firstValue);
	    	System.debug('lastValue--'+lastValue);
		}
		System.debug('masterlist size -:'+masterList.size());
	}
	
	// return true if already on first page
    public boolean getprev()
    {
    	String stringFirstVal;
		Decimal decimalFirstVAl;
		DateTime datetimeFirstVal;
		Date dateFirstVal;
		String valType = 'None';
		if(firstValue != null)
		{
			if(firstValue instanceof String)
			{
				stringFirstVal = (String)firstValue;
				valType = 'String';
			}
			else if(firstValue instanceof Decimal)
			{
				decimalFirstVAl = (Decimal)firstValue;
				valType = 'Decimal';
			}
			else if(firstValue instanceof DateTime)
			{
				datetimeFirstVal = (DateTime)firstValue;
				valType = 'DateTime';
			}
			else if(firstValue instanceof Date)
			{
				dateFirstVal = (Date)firstValue;
				valType = 'Date';
			}
		}
    	
    	String tempOrder = SelectedSortingOrder == OrderDescending ? OrderAscending : OrderDescending;
		String queryStr2 = 'SELECT Id FROM '+masterObjectName;
		if(SelectedOrderByField == 'id')
		{
			if(SelectedSortingOrder == OrderAscending)
			{
				queryStr2 += ' WHERE '+SelectedOrderByField+' <:lastId  ORDER BY '+SelectedOrderByField+' '+tempOrder+' LIMIT 1';
			}
			else
			{
		        queryStr2 += ' WHERE '+SelectedOrderByField+' >:lastId  ORDER BY '+SelectedOrderByField+' '+tempOrder+' LIMIT 1';
			}
		}
		else
		{
			if(SelectedSortingOrder == OrderAscending)
    		{
    			if(firstValue != null)
    			{
    				if(valType == 'String')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:stringFirstVal) OR ('+SelectedOrderByField+'=:stringFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
					else if(valType == 'Decimal')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:decimalFirstVAl) OR ('+SelectedOrderByField+'=:decimalFirstVAl AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
					else if(valType == 'DateTime')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:datetimeFirstVal) OR ('+SelectedOrderByField+'=:datetimeFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
					else if(valType == 'Date')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' <:dateFirstVal) OR ('+SelectedOrderByField+'=:dateFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
    			}
    			else
    			{
    				queryStr2 += ' WHERE (Id <:firstId AND '+SelectedOrderByField+'=null)  ORDER BY '+SelectedOrderByField+' '+tempOrder+',Id '+OrderDescending+' LIMIT 1';
    			}
    		}
    		else
    		{
    			if(firstValue != null)
    			{
    				if(valType == 'String')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:stringFirstVal) OR ('+SelectedOrderByField+'=:stringFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
					else if(valType == 'Decimal')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:decimalFirstVAl) OR ('+SelectedOrderByField+'=:decimalFirstVAl AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
					else if(valType == 'DateTime')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:datetimeFirstVal) OR ('+SelectedOrderByField+'=:datetimeFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
					else if(valType == 'Date')
						queryStr2 += ' WHERE ('+SelectedOrderByField+' >:dateFirstVal) OR ('+SelectedOrderByField+'=:dateFirstVal AND Id <:firstId) ORDER BY '+SelectedOrderByField+' '+tempOrder+',ID '+OrderDescending+' Limit 1';
    			}
    			else
    			{
    				queryStr2 += ' WHERE (Id <:firstId AND '+SelectedOrderByField+'=null)  ORDER BY '+SelectedOrderByField+' '+tempOrder+',Id '+OrderDescending+' LIMIT 1';
    			}
    		}
		}
    	List<sObject> objList = new List<sObject>();
    	objList = Database.query(queryStr2);
    	if(objList.size() > 0)
    	{
    		return false;
    	}
    	return true;
    }
    
    //return true if already on last page
    public boolean getnxt()
    {
    	String stringLastVal;
		Decimal decimalLastVAl;
		DateTime datetimeLastVal;
		Date dateLastVal;
		String valType = 'None';
		if(lastVAlue != null)
		{
			if(lastValue instanceof String || lastValue instanceof Id)
			{
				stringLastVal = (String)lastValue;
				valType = 'String';
			}
			else if(lastValue instanceof Decimal)
			{
				decimalLastVAl = (Decimal)lastValue;
				valType = 'Decimal';
			}
			else if(lastValue instanceof DateTime)
			{
				datetimeLastVal = (DateTime)lastValue;
				valType = 'DateTime';
			}
			else if(lastValue instanceof Date)
			{
				dateLastVal = (Date)lastValue;
				valType = 'Date';
			}
		}
			
    	String queryStr= 'SELECT Id FROM '+masterObjectName;
    	if(SelectedOrderByField == 'id')
		{
			if(SelectedSortingOrder == OrderAscending)
			{
				queryStr += ' WHERE '+SelectedOrderByField+' >:lastId  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+' LIMIT 1';
			}
			else
			{
				queryStr += ' WHERE '+SelectedOrderByField+' <:lastId  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+' LIMIT 1';
			}
		}
		else
		{
			if(SelectedSortingOrder == OrderAscending)
			{
				if(lastValue != null)
				{
					if(valType == 'String')
						queryStr += ' WHERE (('+SelectedOrderByField+' >:stringLastVal) OR ('+SelectedOrderByField+'=:stringLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT 1';
					else if(valType == 'Decimal')
						queryStr += ' WHERE (('+SelectedOrderByField+' >:decimalLastVAl) OR ('+SelectedOrderByField+'=:decimalLastVAl AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT 1';
					else if(valType == 'DateTime')
						queryStr += ' WHERE (('+SelectedOrderByField+' >:datetimeLastVal) OR ('+SelectedOrderByField+'=:datetimeLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT 1';
					else if(valType == 'Date')
						queryStr += ' WHERE (('+SelectedOrderByField+' >:dateLastVal) OR ('+SelectedOrderByField+'=:dateLastVal AND Id > :lastId))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT 1';
				}
				else
				{
					queryStr += ' WHERE ((Id >:lastId AND '+SelectedOrderByField+'=null) OR ('+SelectedOrderByField+'!= null))  ORDER BY '+SelectedOrderByField+' '+SelectedSortingOrder+',Id '+OrderAscending+' LIMIT 1';
				}
			}
			else
			{
				if(lastValue != null)
				{
					if(valType == 'String')
						queryStr += ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:stringLastVal) OR ('+SelectedOrderByField+'=:stringLastVal AND Id < :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT 1';
					else if(valType == 'Decimal')
						queryStr += ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:decimalLastVAl) OR ('+SelectedOrderByField+'=:decimalLastVAl AND Id < :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT 1';
					else if(valType == 'DateTime')
						queryStr += ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:datetimeLastVal) OR ('+SelectedOrderByField+'=:datetimeLastVal AND Id < :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT 1';
					else if(valType == 'Date')
						queryStr += ' WHERE '+SelectedOrderByField+'!= null AND (('+SelectedOrderByField+' <:dateLastVal) OR ('+SelectedOrderByField+'=:dateLastVal AND Id < :lastId))  ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT 1';
				}
				else
				{
					//queryStr += ' WHERE (Id <:lastId AND '+SelectedOrderByField+'=null) ORDER BY '+SelectedOrderByField+' '+OrderAscending+',Id '+OrderDescending+' LIMIT 1';
					queryStr += ' WHERE (Id >:lastId AND '+SelectedOrderByField+'=null) OR ('+SelectedOrderByField+' !=null) ORDER BY '+SelectedOrderByField+' '+OrderDescending+',Id '+OrderAscending+' LIMIT 1';
				}
			}
		}
		List<sObject> objList = new List<sObject>();
    	objList = Database.query(queryStr);
		if(objList.size() > 0)
		{
			return false;
		}
    	return true;
    }
    
    public class FieldInfo
    {
    	public String API_Name{get;set;}
    	public boolean IsSortable{get;set;}
    	public String Label{get;set;}
    	public Schema.DisplayType Type;
    	
    	public fieldInfo(String API_Name,String Label, Schema.DisplayType Type, boolean IsSortable)
    	{
    		this.API_Name = API_Name;
    		this.IsSortable = IsSortable;
    		this.Label = Label;
    		this.Type = Type;
    	}
    }
}
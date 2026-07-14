public with sharing class MasterRecordViewerController 
{
	public List<SelectOption> masterObjList{get;set;}
	public List<SelectOption> childObjList{get;set;}
	public String masterObjectName{get;set;}
	public String childObjectname{get;set;}
	
	public Map<String,String> masterFieldMap{get;set;}
	
	public String selectedMaster{get;set;}
	
	public List<sObject> masterList{get;set;}
	public String selectedOrderByField{get;set;}
	public String selectedSortingOrder{get;set;}
	
	//drag & drop
	public String selectedDropField{get;set;}
	public Map<String,String> selectedFieldMap{get;set;}
	private Map<String,String> AllFieldMap;
	
	//pagination
    public Integer LimitSize=20;
    public integer totalRecs = 0;
    public String paginationStr{get; set;}
    public Integer currentPageNo{get; set;}
	public Integer totalPage{get; set;}
	
	public String event{get; set;}
	
	private Id firstId;
	private Id lastId;
	
	private Set<String> allEvents = new Set<String>{'First','Last','Next','Previous'};
	
	public MasterRecordViewerController()
	{
		selectedFieldMap = new Map<String,String>();
		AllFieldMap = new Map<String,String>();
		masterObjList = new List<SelectOption>();
		childObjList = new List<SelectOption>();
		masterFieldMap = new Map<String,String>();
		masterList = new List<sObject>();
		masterObjList.add(new SelectOption('','--None--'));
		childObjList.add(new SelectOption('','--None--'));
		for(Schema.SObjectType objType : Schema.getGlobalDescribe().values())
		{
			Schema.Describesobjectresult res = objType.getDescribe();
			if(res.isCustom())
			{
				masterObjList.add(new SelectOption(res.getName(),res.getLabel()));
				childObjList.add(new SelectOption(res.getName(),res.getLabel()));
			}
		}
	}
	
	public void selectObject()
	{
		selectedFieldMap.clear();
		AllFieldMap.clear();
		if(masterObjectName != null && masterObjectName != '')
		{
			Schema.SObjectType accountType = Schema.getGlobalDescribe().get(masterObjectName);
			Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
			for(Schema.SObjectField sfield :accountType.getDescribe().fields.getMap().values())
			{
				Schema.Describefieldresult dfr = sfield.getDescribe();
				if(dfr.isAccessible())
				{
					if(dfr.getName() != 'id')
					{
						masterFieldMap.put(dfr.getName(),dfr.getLabel());
						AllFieldMap.put(dfr.getName(),dfr.getLabel());
					}
				}
			}
			fillMasterRecords();
		}
	}
	
	public void selectChild()
	{
		if(childObjectname != null && childObjectname != '' && masterObjectName != null && masterObjectName != '')
		{
			Schema.SObjectType accountType = Schema.getGlobalDescribe().get(childObjectname);
			for(Schema.SObjectField sfield :accountType.getDescribe().fields.getMap().values())
			{
				Schema.Describefieldresult dfr = sfield.getDescribe();
				/*if(dfr.isAccessible() && dfr.isUpdateable())
				{
					masterFieldList.add(new SelectOption(dfr.getName(),dfr.getLabel()));
				}*/
				/*if(dfr.isAccessible() && dfr.isUpdateable())
				{
					masterFieldList.add(new SelectOption(dfr.getName(),dfr.getLabel()));
				}*/
			}
		}
	}
	
	public void addAnotherField()
	{
		if(selectedDropField != null && AllFieldMap.containsKey(selectedDropField))
		{
			selectedFieldMap.put(selectedDropField,AllFieldMap.get(selectedDropField));
			masterFieldMap.remove(selectedDropField);
			//listMasterRecords();
		}
	}
	
	public void removeAnotherField()
	{
		if(selectedDropField != null && AllFieldMap.containsKey(selectedDropField))
		{
			selectedFieldMap.remove(selectedDropField);
			masterFieldMap.put(selectedDropField,AllFieldMap.get(selectedDropField));
			//listMasterRecords();
		}
	}
	
	public void listMasterRecords()
	{
		masterList.clear();
		if(masterObjectName != null && masterObjectName != '' && allEvents.contains(event) && selectedOrderByField != null && selectedOrderByField != '')
		{
			String queryStr = 'SELECT Id';
			for(String singleField : AllFieldMap.keySet())
			{
				queryStr +=','+singleField;
			}
			queryStr += ' FROM '+masterObjectName;
			if(event == 'First')
			{
				queryStr += ' ORDER BY '+selectedOrderByField+' '+selectedSortingOrder+' LIMIT :LimitSize';
				currentPageNo = totalRecs == 0 ? totalRecs : 1;
			    Integer Temp = math.mod(totalRecs,LimitSize);
			    totalPage = Temp == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize)+1;
		        paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
			}
			else if(event == 'Last')
			{
				Set<Id> idSet = new Set<Id>();
				String queryStr2 = 'SELECT Id FROM '+masterObjectName+' WHERE ORDER BY '+selectedOrderByField+' '+selectedSortingOrder+' Limit :TempLimit';
		        for(Sobject rec : Database.query(queryStr2))
		        {
		        	idSet.add(rec.Id);
		        }
		        queryStr += ' WHERE Id IN:idSet ORDER BY '+selectedOrderByField+' '+selectedSortingOrder+' LIMIT :LimitSize';
				currentPageNo=totalPage;
        		paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
			}
			else if(event == 'Next')
			{
				queryStr += ' WHERE selectedOrderByField >:lastId  ORDER BY '+selectedOrderByField+' '+selectedSortingOrder+' LIMIT :LimitSize';
				currentPageNo+=1;
        		paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
			}
			else if(event == 'Previous')
			{
				Set<Id> idSet = new Set<Id>();
    			String queryStr2 = 'SELECT Id FROM '+masterObjectName+' WHERE '+selectedOrderByField+' <:firstId ORDER BY '+selectedOrderByField+' '+selectedSortingOrder == 'DESC' ? 'ASC' : 'DESC'+' Limit :LimitSize';
    		
		    	for(Sobject rec : Database.query(queryStr2))
		        {
		        	idSet.add(rec.Id);
		        }
		        
		    	queryStr += ' WHERE Id IN:idSet ORDER BY '+selectedOrderByField+' '+selectedSortingOrder+' LIMIT :LimitSize';
				currentPageNo-=1;
        		paginationStr = 'Total '+totalRecs+' components, Page '+currentPageNo+' of '+totalPage;
			}
			System.debug(queryStr);
			for(Sobject rec : Database.query(queryStr))
			{
				masterList.add(rec);
			}
			
			firstId = null;
			lastId = null;
			if(masterList.size() > 0)
	    	{
	    		firstId = masterList[0].Id;
	    		lastId = masterList[masterList.size()-1].Id;
	    	} 
		}
	}
	
	public void listChildRecords()
	{
		if(childObjectname != null && childObjectname != '')
		{
			if(masterObjectName != null && masterObjectName != '')
			{
				
			}
		}
	}
	
	
	/////
	public void fillMasterRecords()
    {   
    	if(masterObjectName != null && masterObjectName != '')
		{
	    	totalRecs = 0;
	    	List<AggregateResult> agList = new List<AggregateResult>();
	    	agList  = Database.query('SELECT COUNT(Id) myCount FROM '+masterObjectName);
	    	if(agList.size() > 0)
	    	{
	    		totalRecs = (Integer)agList[0].get('myCount');
	    	}
	    	selectedOrderByField = 'Id';
	    	selectedSortingOrder = 'ASC';
	    	event = 'First';
	        listMasterRecords();
		}
    }
    
    // return true if already on first page
    public boolean getprev()
    {
    	if(totalRecs == 0 || firstId == null)
    	{
    		return true;
    	}
    	List<sObject> objList = new List<sObject>();
    	objList = Database.query('SELECT Id From  '+masterObjectName+' WHERE '+selectedOrderByField+' <:firstId LIMIT 1');
    	
    	if(objList.size() > 0)
    	{
    		return false;
    	}
    	return true;
    }
    
    //return true if already on last page
    public boolean getnxt()
    {
    	if(totalRecs == 0 || firstId == null)
    	{
    		return true;
    	}
    	List<sObject> objList = new List<sObject>();
    	objList = Database.query('SELECT Id From  '+masterObjectName+' WHERE '+selectedOrderByField+' >:lastId LIMIT 1');
    	
    	if(objList.size() > 0)
    	{
    		return false;
    	}
    	return true;
    }
}
/**
* An apex page controller that exposes Order Information Ex: Order details, Order line items and Order Notes
* This controller is utilized by the lightning component OrderInfo.cmp that exposes the information on the UI
* Pagination, Search Criterias (Order Number, Order date, Customer Number and Customer Name)
* Author: Syed Basha
* Date:October 19, 2019
*/
public class OrderInfoController {
    
    
    private static Map<Id, TreeStructure> result;
    private static Map<Id, Id> childIdMap;
    private static List<Id> allTerIds = new List<Id>();
    
    @AuraEnabled
    public static List<Territory2> getCurrentUserTerritories() {
        
        List<Territory2> userTerritories = new List<Territory2>();
       userTerritories= GAFHelper.getCodesForCurrentUser();
         
        return  userTerritories;
    }
    
    @AuraEnabled
    public static String getCurrentUserTerritoryCodes() {
        
        List<Territory2> userTerritories = GAFHelper.getCodesForCurrentUser();
        
        for(Territory2 userTerritory : userTerritories){
             Map<Id, Territory2> terMap = new Map<Id, Territory2>([SELECT Id, Name,Selling_Company_ID__c,Sales_Territory_ID__c,SSM_Code__c,SSR_Code__c FROM Territory2 WHERE Id = :userTerritory.Id]);
             result = new Map<Id, TreeStructure>();
             childIdMap = new Map<Id, Id>();               
             String territoryInfo = '';
            //This is a recursive Method to get the territories
             startFetchingTerritoryDetails(terMap);
            
        }
        String codeString = '';
        codeString = string.join(allTerIds,',');     
    
        System.debug(LoggingLevel.Info,'The Territory ids are --------->' + allTerIds);
        return  codeString;
    }
    
    
    @AuraEnabled
    public Static String getUserTerritories() {        
        result = new Map<Id, TreeStructure>();
        childIdMap = new Map<Id, Id>();               
        String territoryInfo = '';
        List<Territory2> userTerritoryInfo = new List<Territory2>();
        userTerritoryInfo= GAFHelper.getCodesForCurrentUser();        
        if (userTerritoryInfo.size() > 0)
        {
            Map<Id, Territory2> terMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE Id = :userTerritoryInfo[0].Id]);
            System.debug(LoggingLevel.Info,'The Territory map is --------->' + terMap);            
            startFetchingTerritoryDetails(terMap);
        }        
        System.debug(JSON.serializePretty(result.values())); 
        
        
        
        return JSON.serializePretty(result.values());        
    }    
    
     /**
    * Recursion method to get all levels of Territoris  and their related records
    */
    private static List<TreeStructure> startFetchingTerritoryDetails(Map<Id, Territory2> terMap){
        Map<Id, TreeStructure> parentStructure = gatherAllTerritoryInformation(terMap);        
        //attach the first level to actual result and rest will auotmatically link
        //due to pass by reference way
        if(result == null || result.isEmpty()){
            result.putAll(parentStructure);
        }
        Map<Id, Territory2> childMap = new Map<Id, Territory2>([SELECT Id, Name, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id =: terMap.keySet()]);        
        System.debug(LoggingLevel.Info,'The Child map is --------->' + childMap);        
        if(childMap != null && !childMap.isEmpty() && childMap.size() > 0){
            Map<Id, Id> accChildIdMap = new Map<Id, Id>();
            for(Id childAccountId : childMap.keySet()){
                Territory2 child = childMap.get(childAccountId);
                childIdMap.put(child.Id, child.ParentTerritory2Id);
                allTerIds.add(child.Id);
            }
            
            //run this method recursively to get all child levels.
            List<TreeStructure> childStructure = startFetchingTerritoryDetails(childMap);
            for(TreeStructure child : childStructure){
                TreeStructure parent = parentStructure.get(childIdMap.get(child.name));
                parent.items.add(child);
            }
        }      
        
        return parentStructure.values();
    }    
    
    
        /**
    * Method to gather all information for all Territories
    */
    private static Map<Id, TreeStructure> gatherAllTerritoryInformation( Map<Id, Territory2> terMap){
        Map<Id, TreeStructure> result = new Map<Id, TreeStructure>();       
        
        for(Id territoryId : terMap.keySet()){
            Territory2 ter = terMap.get(territoryId);
            TreeStructure terStructure = new TreeStructure(ter.name, territoryId, false, null);   
          
            result.put(territoryId, terStructure);
            allTerIds.add(territoryId);
        }
        return result;
    }
    
    
    
    
    
    @AuraEnabled
    public Static OrderDetailWrapper getOrderDetails(string orderNumber)
    {
        String strResponse = '';
        OrderDetailWrapper objDT =  new OrderDetailWrapper();
        try
        {
            AuthorizationHeader__mdt CSInfo;
            String SettingName = 'orders';
            
            CSInfo = [SELECT Id, DeveloperName,  client_id__c, client_secret__c, baseAPIURL__c FROM AuthorizationHeader__mdt
                      Where DeveloperName = :SettingName LIMIT 1];            
            
            objDT.orderDetails = GAFAPIHelper.Callout(CSInfo.baseAPIURL__c + orderNumber ,CSInfo.client_Id__c,CSInfo.client_secret__c,'GET');
            objDT.orderLines = GAFAPIHelper.Callout(CSInfo.baseAPIURL__c + orderNumber +'/lines',CSInfo.client_Id__c,CSInfo.client_secret__c,'GET');
            objDT.orderNotes = GAFAPIHelper.Callout(CSInfo.baseAPIURL__c + orderNumber + '/notes',CSInfo.client_Id__c,CSInfo.client_secret__c,'GET');
            
        }catch(Exception e){
            //get exception message
            throw new AuraHandledException(e.getMessage());
        }
        System.debug(LoggingLevel.Info,'The return object is --------->' + objDT);
        return objDT;
        
    }
    
    @AuraEnabled
    public Static ObjectWrapper getOrderInfo(Map<String, Object> mParam,Integer pageSize, Integer offset){
        
        ObjectWrapper OW = new ObjectWrapper();
        String valiationMsg = '';
        
        try{
            
            String searchField = (String)mParam.get('searchField');
            String searchText =  (String)mParam.get('searchText');
            String startDate = (String)mParam.get('startDate');
            String endDate =  (String)mParam.get('endDate');
            String OrderStatus =  (String)mParam.get('OrderStatus');
            String territory =  (String)mParam.get('territoryName');
            
            switch on searchField {
                
                when 'orderdate' {                    
                    if (String.isBlank(startDate) || String.isBlank(endDate))
                    {
                        valiationMsg = 'Valid Date range must be entered for the selected Oder Date search field';
                    }                   
                   
                }
                
                when 'ordernumber','customernumber','customername','tercode','arcode'
                {
                    if (String.isBlank(searchText))
                    {
                        valiationMsg = 'Valid Search Value must be entered for the selected search field' ;
                    }
                }
                
            }
            
            //Account account1 = [SELECT PeopleSoft_Id__c FROM Account WHERE Id=: (String)mParam.get('recordId')];
            
            if (mParam.get('recordId') != 'NA')
            {                
                Account account = [SELECT PeopleSoft_Id__c FROM Account WHERE Id=: (String)mParam.get('recordId')];
                if (account.PeopleSoft_Id__c !=null)
                {
                    searchText = account.PeopleSoft_Id__c;
                }         
                System.debug(LoggingLevel.Info,'Customer number is  --------->' + searchText);                
                searchField = 'customernumber';
            }
            
            System.debug(LoggingLevel.Info, 'The Parameters are  --------->' + searchField + ',' + searchText + ',' + startDate + ',' + endDate + ',' + startDate + ',' + endDate + ',' + OrderStatus + ',' + territory + ',' +  pageSize + ',' + offset );
            
            //System.debug(LoggingLevel.Info, 'The final parameters are --------->' +mParam);
            ApiDetailsWrapper apiDetails = buildEndPoint(searchField, searchText, startDate, endDate, OrderStatus, territory);
            
            if (String.isNotBlank(apiDetails.message))
            {
                OW.message = apiDetails.message;
                OW.isError = true;
            }
            else if (String.isNotBlank(valiationMsg))
            {
                OW.message = valiationMsg;
                OW.isError = true;
            }
            else
            {                
                
                Integer totalRecords = 0;
                String resptotRecords = GAFAPIHelper.Callout(apiDetails.endPoint + '&countonly=y', apiDetails.clientID, apiDetails.clientSecret, 'POST');
                
                if (resptotRecords.contains('Error'))
                {
                    OW.message = resptotRecords;
                    OW.isError = true;
                }                
                else
                {
                    
                    JSONParser parser = JSON.createParser(resptotRecords);            
                    while(parser.nextToken() != null) {
                        if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'totalRows')) {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            totalRecords += (Integer) parser.getDoubleValue();
                        }
                    }            
                    OW.intRecordCount =  totalRecords; 
                    OW.records = getOrders(apiDetails, offset, pageSize);
                }
            }     
        } catch(Exception e) {
            //get exception message
            throw new AuraHandledException('Something went wrong-' + e.getMessage());
        } 
        
        return OW;
        
        
    }
    
    public Static List<Object> getOrders(ApiDetailsWrapper apiDetails, Integer offset, Integer pageSize) {
        
        List<Object> lstorders = new List<Object>();        
        String strOrders = GAFAPIHelper.Callout(apiDetails.endPoint + '&offset=' + offSet + '&fetch=' + pageSize, apiDetails.clientID, apiDetails.clientSecret, 'POST');
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped('{"data":' + strOrders + '}');        
        lstorders = (List<Object>) results.get('data');
        
        String shipToCustId = '';
        String soldToCustId = '';
        String orderId = '';       
        
        for (Object objresult :lstorders) {
            // now get attributes for this object.
            Map<String, Object> objectAttributes = (Map<String, Object>) objresult;
            
            shipToCustId = (String) objectAttributes.get('shipTo');
            soldToCustId = (String) objectAttributes.get('soldTo');
            
            orderId = (String) objectAttributes.get('orderNumber');
            
            Account[] shipToaccounts = [SELECT Id, PeopleSoft_Id__c FROM Account WHERE PeopleSoft_Id__c = :shipToCustId];
            Account[] soldToaccounts = [SELECT Id, PeopleSoft_Id__c FROM Account WHERE PeopleSoft_Id__c = :soldToCustId];
            
            if(shipToaccounts.size() > 0) {
                objectAttributes.put('AccountIdShipTo', '/'+shipToaccounts [0].Id);
            }
            
            
            if(soldToaccounts.size() > 0) {
                objectAttributes.put('AccountIdSoldTo', '/'+soldToaccounts [0].Id);
            }
            
            
            objectAttributes.put('linkName', '/lightning/n/Orders?c__ordernumber='+orderId);
            
        }
        
        //System.debug(LoggingLevel.Info,'The Order objects are --------->' +lstorders);
        return lstorders;
    }
    
    
 
    
    public Static ApiDetailsWrapper buildEndPoint(String matchCriteria, String searchText, String startDate, String endDate, String OrderStatus, String territory) {
        ApiDetailsWrapper apiDetails = new ApiDetailsWrapper();
        AuthorizationHeader__mdt CSInfo;
        String SettingName = 'orders';	
        
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name; 
        
        List<Territory2> userTerritoryInfo = new List<Territory2>();
        String errMessage = '';
        
        if(String.isNotBlank(territory))  {
            String squery = 'select Name,Selling_Company_ID__c,Sales_Area_ID__c,Sales_Region_ID__c,Sales_Territory_Id__c FROM Territory2 where Id = \'' + territory + '\'';             
            userTerritoryInfo = database.query(squery);
        } else {
            userTerritoryInfo= GAFHelper.getCodesForCurrentUser();                       
        }       
        
        String Codes = '';
        String TerCode = '';
        String AreaCode = '';
        String RegCode = '';
        String hierarchyCodes = '';
        
        //--code change to get multiple territories Syed Basha 2/1/2020
        List<String> lstTerCode = new List<String>();
		List<String> lstAreaCode = new List<String>();
        List<String> lstRegCode = new List<String>();
        List<String> lsthierarchyCodes = new List<String>();
        List<String> lstallCodes = new List<String>();
        //-----------------------
        
         Constants__mdt msgInfo;
         Constants__mdt scompanyCodes;
        
        if (pname == 'System Administrator')
        {
            
        }       
        else if (userTerritoryInfo.size() == 0)
        {
           msgInfo = [SELECT Id, DeveloperName,Value__c FROM Constants__mdt
                  Where DeveloperName = :'message0' LIMIT 1];
            errMessage = msgInfo.Value__c;
            
        }
        else if (userTerritoryInfo.size()> 0)
        {            
            for(Territory2 userTerritory : userTerritoryInfo){
                
                lstallCodes  = new List<String>();
                if (String.isNotBlank(userTerritory.Selling_Company_ID__c))
                {
                    lstallCodes.add(userTerritory.Selling_Company_ID__c);                    
                }
                
                if (String.isNotBlank(userTerritory.Sales_Region_ID__c))
                {
                    lstAreaCode.add(userTerritory.Sales_Region_ID__c);
                    lstallCodes.add(userTerritory.Sales_Region_ID__c);
                }
                else
                {
                    lstallCodes.add('');
                }
                
                if (String.isNotBlank(userTerritory.Sales_Area_ID__c))
                {
                    lstRegCode.add(userTerritory.Sales_Area_ID__c);
                    lstallCodes.add(userTerritory.Sales_Area_ID__c);
                }               
               
                if (String.isNotBlank(userTerritory.Sales_Territory_Id__c))
                {
                    
                    lstTerCode.add(userTerritory.Sales_Territory_Id__c);
                    lstallCodes.add(userTerritory.Sales_Territory_Id__c);
                }
     
                lsthierarchyCodes.add(string.join(lstallCodes,',')) ;
            }
            
            Set<String> setTerCode = new Set<String>();
            Set<String> setAreaCode = new Set<String>();
            Set<String> setRegCode = new Set<String>();
            
            //---------Set is to dedupe codes from the list--------------
            setTerCode.addAll(lstTerCode);
            setAreaCode.addAll(lstAreaCode);
            setRegCode.addAll(lstRegCode);
            
            for(String str : setTerCode)            
            {            
                TerCode += str + ',' ;            
            }     
    
            if(String.isNotBlank(TerCode)) {
                 TerCode = '&territorycode='+TerCode.removeEnd(',');
            }           
            
            for(String str1 : setAreaCode)            
            {            
                AreaCode += str1 + ',' ;            
            }   
   
            if(String.isNotBlank(AreaCode)) {
                  AreaCode = '&areacode='+AreaCode.removeEnd(',');
            }
            
            for(String str2 : setRegCode)            
            {            
                RegCode += str2 + ',' ;            
            }
            
            if(String.isNotBlank(RegCode)) {                
                RegCode = '&regioncode='+RegCode.removeEnd(','); 
            } 
            
            if(String.isNotBlank(hierarchyCodes)) { 
                hierarchyCodes = '&hierarchycodes='+ string.join(lsthierarchyCodes,'~');
            }
           
            
        }
       
            
        
        
        CSInfo = [SELECT Id, DeveloperName, client_id__c, client_secret__c, baseAPIURL__c FROM AuthorizationHeader__mdt
                  Where DeveloperName = :SettingName LIMIT 1];        
        
        String endPointUrl = CSInfo.baseAPIURL__c + 'summary?orderstatus=' + OrderStatus;
        
        String filter = '';
        
       
            
            switch on matchCriteria {
                
                when 'ordernumber' {
                    filter = '&ordernumber=' + searchText;
                }
                when 'customernumber' {
                     filter = '&customernumber=' + searchText;
                }               
                when 'customername' {
                    filter = '&customername=' + searchText;
                }
                when 'tercode' {
                    
                   if(hasTerritoryAccess(searchText,pname))
                   {
                       TerCode= '&territorycode=' + searchText; 
                   }
                   else
                   {
                       msgInfo = [SELECT Id, DeveloperName,Value__c FROM Constants__mdt
                                  Where DeveloperName = :'message_noa' LIMIT 1];
                       errMessage = msgInfo.Value__c;
                   }
                                                              
                }
                when 'orderdate'
                {
                    filter ='&orderfromdate=' + startDate + '&ordertodate=' + endDate;
                }
                when 'arcode'{ 
                   if( hasAreaAccess(searchText,pname))
                   {
                        AreaCode= '&areacode='  + searchText; 
                   }
                   else
                   {
                        msgInfo = [SELECT Id, DeveloperName,Value__c FROM Constants__mdt
                                  Where DeveloperName = :'message_noa' LIMIT 1];
                        errMessage = msgInfo.Value__c;
                   }
                }
                
            }
        
        
       //Area and Region are reverse in the hierarchy.  APIs are built this way.  Don't get confused
        
        endPointUrl+= hierarchyCodes+AreaCode+RegCode+TerCode+filter;
        
        System.debug(LoggingLevel.Info, 'The end point url is --------->' + endPointUrl.replaceAll('\\s+', '+'));
        apiDetails.endPoint = endPointUrl.replaceAll('\\s+', '+');
        apiDetails.clientID = CSInfo.client_Id__c;
        apiDetails.clientSecret = CSInfo.client_secret__c;
        apiDetails.message = errMessage;
        
        
        //System.debug(LoggingLevel.Info, 'Api Details are --------->' + apiDetails);
        return apiDetails;
    }
    
    
    public Static Boolean hasTerritoryAccess(String terCode, String profileName){
        Boolean hasAccess = false;
         System.debug(LoggingLevel.Info,'Codes are --------->' + terCode ); 
         List<Territory2> userTerritoryInfo = new List<Territory2>();
        userTerritoryInfo= GAFHelper.getCodesForCurrentUser(); 
        System.debug(LoggingLevel.Info,'User territory info is  --------->' + userTerritoryInfo);
        //List<Territory2> terMap = new List<Territory2>([SELECT Id, Name FROM Territory2 WHERE Sales_Territory_Id__c = :terCode and Sales_Area_ID__c = :areaCode and Sales_Region_ID__c = :regionCode  ]);
        List<Territory2> terMap = new List<Territory2>([SELECT Id, Name FROM Territory2 WHERE Sales_Territory_Id__c = :terCode]);
         System.debug(LoggingLevel.Info,'query result  is  --------->' + terMap);
        //getUserTerritories();
        getCurrentUserTerritoryCodes();
        Set<Id> myset = new Set<Id>();        
        myset.addAll(allTerIds);
        System.debug(LoggingLevel.Info,'Ids in set are --------->' + myset);
        if (terMap.size()>0)
        {
            for (sObject tr :terMap) {
                if (myset.contains(tr.Id)) { hasAccess = true; }
            }           
            
        } 
        
        if (profileName == 'System Administrator')
        {
            hasAccess = true;
        }  
        
         System.debug(LoggingLevel.Info,'hasAccess is --------->' +  hasAccess);  
        
        
        
        return  hasAccess;      
        
    }
    
    public Static Boolean hasAreaAccess(String arCode, String profileName){
        Boolean hasAccess = false;
         System.debug(LoggingLevel.Info,'Codes are --------->' + arCode ); 
        
        List<Territory2> userTerritoryInfo = new List<Territory2>();
        userTerritoryInfo= GAFHelper.getCodesForCurrentUser();
 
        List<Territory2> terMap = new List<Territory2>([SELECT Id, Name FROM Territory2 WHERE Sales_Region_ID__c = :arCode ]);
        getUserTerritories();
        Set<Id> myset = new Set<Id>();        
        myset.addAll(allTerIds);
        System.debug(LoggingLevel.Info,'Ids in set are --------->' + myset);
        System.debug(LoggingLevel.Info,'Ter map is --------->' + terMap);
        if (terMap.size()>0)
        {
            for (sObject tr :terMap) {
                if (myset.contains(tr.Id)) { hasAccess = true; }
            }          
        } 
        
        if (profileName == 'System Administrator')
        {
            hasAccess = true;
        } 
        
         System.debug(LoggingLevel.Info,'hasAccess is --------->' +  hasAccess);   
        return  hasAccess;            
        
    }
    
   
    //Wrapper Class APIDetails
    public class ApiDetailsWrapper {
        @AuraEnabled
        public String endPoint { get; set; }
        @AuraEnabled
        public String clientID { get; set; }
        @AuraEnabled
        public String clientSecret { get; set; }		
        @AuraEnabled
        public String message { get; set; }        
        
    }
    
    //Wrapper Class Order Date
    public class OrderDetailWrapper {
        
        @AuraEnabled
        public String orderDetails {get;set;}
        @AuraEnabled
        public String orderLines {get;set;}
        @AuraEnabled
        public String orderNotes {get;set;}
        
    }
    
    public class TreeStructure{
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public List<TreeStructure> items;
        public TreeStructure(String label, String name, Boolean expanded, List<TreeStructure> items){
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            if(items != null && items.size() > 0){
                this.items = items;
            }else{
                this.items = new List<TreeStructure>();
            }
        }
    }
    
    
}
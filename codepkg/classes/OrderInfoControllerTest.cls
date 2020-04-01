@isTest
public class OrderInfoControllerTest {
    
     @testSetup static void setup() {
         
         User usr = [Select id from User where Id = :UserInfo.getUserId()];

        List<GAF_Sales_Hierarchy__c> territoryList = new List<GAF_Sales_Hierarchy__c>();
        territoryList.add(createGAFTerritory('ONE', null,'NE',null,null));
        territoryList.add(createGAFTerritory('TWO', null,null,null,null));
        territoryList.add(createGAFTerritory('THREE', 'ONE','NE','31',null));
        territoryList.add(createGAFTerritory('FOUR', 'THREE','NE','31','033'));        
         
        List<User> userList = new List<User>();
        userList.add(TestHelper.createUser('lnuser1', 'testUserxx1@test.com', 'domain', 'netid1'));
        userList.add(TestHelper.createUser('lnuser2', 'testUserxx2@test.com', 'domain', 'netid2'));
        userList.add(TestHelper.createUser('lnuser3', 'testUserxx3@test.com', 'domain', 'netid3'));
        userList.add(TestHelper.createUser('lnuser4', 'testUserxx4@test.com', 'domain', 'netid4'));
        userList.add(TestHelper.createUser('lnuser5', 'testUserxx5@test.com', 'domain', 'netid5'));
                                           
        Territory2Model model = new Territory2Model();
         
         System.RunAs(usr)
        {
             insert territoryList;
             insert userList;
             model = SalesHierarchyHelper.doLoad('TESTHEAD');            
             User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
             User user2 = [SELECT Id, email FROM User WHERE email = 'testUserxx2@test.com'];
             User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
             User user4 = [SELECT Id, email FROM User WHERE email = 'testUserxx4@test.com'];
            
             Territory2 territory1 = [SELECT Id, Name FROM Territory2 WHERE Name = 'ONE'];
             Territory2 territory2 = [SELECT Id, Name FROM Territory2 WHERE Name = 'THREE'];
             Territory2 territory3 = [SELECT Id, Name FROM Territory2 WHERE Name = 'FOUR'];
             Territory2 territory4 = [SELECT Id, Name FROM Territory2 WHERE Name = 'TWO'];
             
             List<UserTerritory2Association> ut2AList = new List<UserTerritory2Association>();            
             ut2AList.add(TestHelper.createUserTerritoryAssociation(user1.Id,territory1.Id));
             ut2AList.add(TestHelper.createUserTerritoryAssociation(user2.Id,territory2.Id));
             ut2AList.add(TestHelper.createUserTerritoryAssociation(user3.Id,territory3.Id));
             ut2AList.add(TestHelper.createUserTerritoryAssociation(user4.Id,territory4.Id));
            
             insert ut2AList;
         
        }
             
    }
    
    public static GAF_Sales_Hierarchy__c createGAFTerritory(String IDString, String parentIDString,String areaIDString, String regionIDString, String territoryIDString) {        
        return new GAF_Sales_Hierarchy__c(Sales_Hierarchy_ID__c = IDString, Parent_ID__c = parentIDString, Sales_Hierarchy_Name__c = IDString,Sales_Area_ID__c = areaIDString,Sales_Region_ID__c= regionIDString,Sales_Territory_ID__c = territoryIDString );
    }
    
    
      
    
    
      @isTest static void testGetOrderInfo() {
        
        
        String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"ordernumber","searchText":"0005067805","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
        Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
        String expectedValue = '0005067805';
         System.Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
        ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
         Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];
                  
      // String orderNumber = '1234';
      // OrderInfoController.getOrderDetails('1234');     
         System.Test.stopTest();
         
         String actualValue = (String) objectAttributes.get('orderNumber');
         System.assertEquals(expectedValue, actualValue);
    }
    
    @isTest static void testTerritories() {
         System.Test.startTest();        
        
          List<Territory2> toplevelter = [SELECT Id, Name FROM Territory2 WHERE Name = 'ONE']; 
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          //System.debug(LoggingLevel.Info,'user info is  --------->' + user1);        
   
          System.RunAs(user1)
            {
              String ter =  OrderInfoController.getUserTerritories();              
              System.assert(ter.contains('ONE'));
            }
       
         System.Test.stopTest();
    }
    
    @isTest static void testcurrentUserTerritoryCodes() {
         System.Test.startTest();        
        
          List<Territory2> toplevelter = [SELECT Id, Name FROM Territory2 WHERE Name = 'ONE']; 
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          //System.debug(LoggingLevel.Info,'user info is  --------->' + user1);        
   
          System.RunAs(user1)
            {
              String ter =  OrderInfoController.getCurrentUserTerritoryCodes();              
              //System.assert(ter.contains('ONE'));
            }
       
         System.Test.stopTest();
    }
    
    @isTest static void testcurrentUserTerritories() {
         System.Test.startTest();        
        
          List<Territory2> toplevelter = [SELECT Id, Name FROM Territory2 WHERE Name = 'ONE']; 
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          //System.debug(LoggingLevel.Info,'user info is  --------->' + user1);        
   
          System.RunAs(user1)
            {
             List<Territory2> lstter =  OrderInfoController.getCurrentUserTerritories();              
              //System.assert(ter.contains('ONE'));
            }
       
         System.Test.stopTest();
    }
    
    @isTest static void testTM_CustomerNumber() {
         
          User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
          System.RunAs(user3)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"customernumber","searchText":"1118084","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '1118084';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                   
                 System.Test.stopTest();
                 
                 String actualValue = (String) objectAttributes.get('soldTo');
                 System.assertEquals(expectedValue, actualValue);
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
    @isTest static void testRM_CustomerNumber() {
         
          User user2 = [SELECT Id, email FROM User WHERE email = 'testUserxx2@test.com'];
          System.RunAs(user2)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"customernumber","searchText":"1118084","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '1118084';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                   
                 System.Test.stopTest();
                 
                 String actualValue = (String) objectAttributes.get('soldTo');
                 System.assertEquals(expectedValue, actualValue);
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
    @isTest static void testAM_CustomerNumber() {
         
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          System.RunAs(user1)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"customernumber","searchText":"1118084","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '1118084';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                   
                 System.Test.stopTest();
                 
                 String actualValue = (String) objectAttributes.get('soldTo');
                 System.assertEquals(expectedValue, actualValue);
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
    @isTest static void testTM_CustomerName() {
         
          User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
          System.RunAs(user3)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"customername","searchText":"Metro Roofing Supplies","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = 'Metro Roofing Supplies';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                   
                 System.Test.stopTest();
                 
                 String actualValue = (String) objectAttributes.get('soldToCustomerName');
                 System.assertEquals(expectedValue, actualValue);
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
    @isTest static void testAM_SearchTerritory() {
         
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          System.RunAs(user1)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"tercode","searchText":"033","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '033';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                 String actualValue = (String) objectAttributes.get('sTerritoryCode');
                 System.assertEquals(expectedValue, actualValue);  
                 System.Test.stopTest();
                 
                
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
     @isTest static void testAdmin_SearchTerritory() {
         
         User usr = [Select id from User where Id = :UserInfo.getUserId()];
          System.RunAs(usr)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"tercode","searchText":"033","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '033';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                 String actualValue = (String) objectAttributes.get('sTerritoryCode');
                 System.assertEquals(expectedValue, actualValue);  
                 System.Test.stopTest();
                 
                
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
      @isTest static void testAM_SearchArea() {
         
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          System.RunAs(user1)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"arcode","searchText":"31","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '31';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                 String actualValue = (String) objectAttributes.get('areaCode');
                 System.assertEquals(expectedValue, actualValue);  
                 System.Test.stopTest();
                 
                
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
      @isTest static void testAdmin_SearchArea() {
         
         User usr = [Select id from User where Id = :UserInfo.getUserId()];
         System.RunAs(usr)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"arcode","searchText":"31","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '31';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                 String actualValue = (String) objectAttributes.get('areaCode');
                 System.assertEquals(expectedValue, actualValue);  
                 System.Test.stopTest();
                 
                
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');
         
          
      }
    
      @isTest static void testAM_NoTerritoryAccess() {
         
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          System.RunAs(user1)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"tercode","searchText":"721","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = 'You may not have access to this Territory/Area.  Please contact your administrator';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0); 
                System.debug(LoggingLevel.Info,'The Territory map is --------->' + OW); 
                 String actualValue = OW.message;
                 System.assertEquals(expectedValue, actualValue);
                 System.Test.stopTest();
                 
                
            }
          
         
          
      }
    
    @isTest static void testAM_NoAreaAccess() {
         
          User user1 = [SELECT Id, email FROM User WHERE email = 'testUserxx1@test.com'];
          System.RunAs(user1)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"arcode","searchText":"15","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = 'You may not have access to this Territory/Area.  Please contact your administrator';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0); 
                System.debug(LoggingLevel.Info,'The Territory map is --------->' + OW); 
                 String actualValue = OW.message;
                 System.assertEquals(expectedValue, actualValue);
                 System.Test.stopTest();
                 
                
            }
         
         
          
      }
    
    
    
      @isTest static void testTM_OrderDates() {
         
          User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
          System.RunAs(user3)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"orderdate","searchText":"","startDate":"2019-10-16","endDate":"2019-10-16","OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = '2019-10-16';
                 System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);         
                 Map<String, Object> objectAttributes = (Map<String, Object>) OW.records[0];                         
                   
                 System.Test.stopTest();
                 
                 String actualValue = (String) objectAttributes.get('orderDate');
                 System.assertEquals(expectedValue, actualValue);
            }
          
         
          
      }
    
      @isTest static void testTM_NoOrderDates() {
         
          User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
          System.RunAs(user3)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"orderdate","searchText":"0005067805","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = 'Valid Date range must be entered for the selected Oder Date search field';
                System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);        
                System.Test.stopTest();
                 
                 String actualValue = OW.message;
                 System.assertEquals(expectedValue, actualValue);
            }
                  
          
      }
    
     @isTest static void testTM_NoSearchValue() {
         
          User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
          System.RunAs(user3)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"ordernumber","searchText":"","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = 'Valid Search Value must be entered for the selected search field';
                System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);        
                System.Test.stopTest();
                 
                 String actualValue = OW.message;
                 System.assertEquals(expectedValue, actualValue);
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');         
          
      }
    
      @isTest static void testTM_GetOrderDetails() {
         
          User user3 = [SELECT Id, email FROM User WHERE email = 'testUserxx3@test.com'];
          System.RunAs(user3)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"ordernumber","searchText":"","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String searchValue = '0005067805';
                System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFAPIHelperMock());
                OrderInfoController.getOrderDetails(searchValue);        
                System.Test.stopTest();
                 
                
                 
            }
          //OrderInfoController.buildEndPoint('matchCriteria', 'searchText', 'startDate', 'endDate', 'OrderStatus', 'territory');         
          
      }
    
      @isTest static void test_UserNoTerritoriesAssigned() {
         
          User user5 = [SELECT Id, email FROM User WHERE email = 'testUserxx5@test.com'];
           System.RunAs(user5)
            {
                String parameters ='{"extobject":"order","recordId":"NA","sfObject":"NA","territoryName":"","searchField":"orderdate","searchText":"0005067805","startDate":null,"endDate":null,"OrderStatus":"O","isRefresh":"Y"}';
                Map<String, Object> mParam =   (Map<String, Object>) JSON.deserializeUntyped(parameters);
                String expectedValue = 'User has no Territories Assigned';
                System.Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new GAFOrderAPIHelperMock());
                ObjectWrapper OW = OrderInfoController.getOrderInfo(mParam,25,0);        
                System.Test.stopTest();
                 
                 String actualValue = OW.message;
                 System.assertEquals(expectedValue, actualValue);
            }
         
         
      }
    
   

}
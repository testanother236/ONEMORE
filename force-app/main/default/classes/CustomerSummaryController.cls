public with sharing class CustomerSummaryController {
  
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getAccounts(
    String searchKey,
    Decimal totalAmount,
    Integer pageNumber,
    Integer recordsPerPage
  ) {
    // Check if the user has permission to read Account records
    if (!Schema.sObjectType.Account.isAccessible()) {
      throw new SecurityException(
        'User does not have permission to read Account records.'
      );
    }

    // Prepare the search key for a case-insensitive search
    String searchKeyLower = String.isNotBlank(searchKey)
      ? '%' + searchKey + '%'
      : '%';

    // Query to fetch accounts with related closed-won opportunities
    List<Account> accountList = [
      SELECT
        Id,
        Name,
        (
          SELECT Id, Name, CreatedDate, CloseDate, Amount, StageName
          FROM Opportunities
          WHERE StageName = 'Closed Won'
        )
      FROM Account
      WHERE
        Name LIKE :searchKeyLower
        AND Id IN (
          SELECT AccountId
          FROM Opportunity
          WHERE StageName = 'Closed Won'
        )
      LIMIT :recordsPerPage
      OFFSET :((pageNumber - 1) * recordsPerPage)
    ];

    List<Map<String, Object>> accountsData = new List<Map<String, Object>>();

    // Get the total count of accounts matching the search criteria
    Integer totalRecords = [
      SELECT COUNT()
      FROM Account
      WHERE
        Name LIKE :searchKeyLower
        AND Id IN (
          SELECT AccountId
          FROM Opportunity
          WHERE StageName = 'Closed Won' AND Amount >= :totalAmount
        )
    ];

    // Iterate through the accounts to calculate total amounts
    for (Account acc : accountList) {
      Decimal totalClosedWonAmount = 0;
      List<Opportunity> closedWonOpportunities = acc.Opportunities;

      // Sum the amounts of closed-won opportunities
      for (Opportunity opp : closedWonOpportunities) {
        totalClosedWonAmount += opp.Amount;
      }

      // Check if the total amount meets the criteria
      if (totalClosedWonAmount >= totalAmount || totalAmount == 0) {
        accountsData.add(
          new Map<String, Object>{
            'Id' => acc.Id,
            'Name' => acc.Name,
            'OpportunityTotal' => totalClosedWonAmount,
            'Opportunities' => closedWonOpportunities // Include only closed-won opportunities
          }
        );
      }
    }

    // Return the structured data with accounts and total records
    return new Map<String, Object>{
      'accounts' => accountsData,
      'totalRecords' => totalRecords
    };
  }

  @AuraEnabled(cacheable=true)
  public static List<Opportunity> getOpportunities(Id accountId) {
    // Check if the user has permission to read Opportunity or Account records
    if (
      !Schema.sObjectType.Opportunity.isAccessible() ||
      !Schema.sObjectType.Account.isAccessible()
    ) {
      throw new SecurityException(
        'User does not have permission to read Opportunity or Account records.'
      );
    }

    // Query to fetch closed-won opportunities for a specific account
    return [
      SELECT Id, Name, CreatedDate, CloseDate, Amount
      FROM Opportunity
      WHERE AccountId = :accountId AND StageName = 'Closed Won'
    ];
  }

  @AuraEnabled
  public static List<OpportunityLineItem> getProducts(Id opportunityId) {
    // Check if the user has permission to read OpportunityLineItem records
    if (!Schema.sObjectType.OpportunityLineItem.isAccessible()) {
      throw new SecurityException(
        'User does not have permission to read OpportunityLineItem records.'
      );
    }
    
    // Query to fetch products associated with a specific opportunity
    List<OpportunityLineItem> products = [
      SELECT Id, Product2Id, Name, Quantity, UnitPrice
      FROM OpportunityLineItem
      WHERE OpportunityId = :opportunityId
    ];
    return products;
  }
}
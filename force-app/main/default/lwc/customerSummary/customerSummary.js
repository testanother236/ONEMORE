import { LightningElement, api, wire, track } from "lwc";
import getAccounts from "@salesforce/apex/CustomerSummaryController.getAccounts";
import getOpportunities from "@salesforce/apex/CustomerSummaryController.getOpportunities";
import getProducts from "@salesforce/apex/CustomerSummaryController.getProducts";
import toastUtils from "c/util_module";

export default class CustomerSummary extends LightningElement {
  @api recordId; // The ID of the record being processed
  isAccountDataLoaded = false; // Track if account data is loaded
  @track accounts = []; // Array to store account data
  isLoading = true; // Loading state
  totalClosedWonAmount = 0; // Total amount for closed won opportunities
  @track selectedAccountId; // ID of the currently selected account
  @track filteredAccounts = []; // Array for filtered account data
  searchKey = ""; // Search key for account name
  totalAmountSearchKey = 0; // Search key for total amount
  pageNumber = 1; // Current page number for pagination
  @track opportunities = { accounts: [] }; // Store opportunities related to accounts
  recordsPerPage = 10; // Number of records to display per page
  totalRecords = 0; // Total number of records
  showModal = false; // Track if modal is shown
  @track productData = []; // Array to store product data
  @track productColumns = [
    { label: "Product Name", fieldName: "Name", type: "text" },
    { label: "Quantity", fieldName: "Quantity", type: "number" },
    { label: "Price", fieldName: "UnitPrice", type: "currency" }
  ];

  @track totalAmount = 0; // Total amount initialized to 0

  @track selectedOpportunity; // Currently selected opportunity
  columns = [
    {
      label: "Opportunity Name",
      fieldName: "OpportunityUrl",
      type: "url",
      typeAttributes: {
        label: { fieldName: "Name" }, // Display name as link
        target: "_blank" // Open link in new tab
      }
    },
    {
      label: "Created Date",
      fieldName: "CreatedDate",
      type: "date"
    },
    {
      label: "Close Date",
      fieldName: "CloseDate",
      type: "date"
    },
    {
      label: "Amount",
      fieldName: "Amount",
      type: "currency"
    },
    {
      label: "Products",
      type: "button",
      typeAttributes: {
        label: "View Products",
        name: "view_products", // Action name for viewing products
        variant: "base",
        data: { id: { fieldName: "Id" } } // Pass opportunity ID
      }
    }
  ];

  // Calculate the total number of pages based on records per page
  get totalPages() {
    return Math.ceil(this.totalRecords / this.recordsPerPage);
  }

  // Calculate visible page numbers for pagination
  get visiblePageNumbers() {
    const total = this.totalPages;
    const current = this.pageNumber;
    const range = 2; // Number of buttons on either side of the active page

    let start = Math.max(1, current - range);
    let end = Math.min(total, current + range);

    // Adjust if there are not enough pages on the left or right
    if (current - range < 1) {
      end = Math.min(start + 4, total);
    }
    if (current + range > total) {
      start = Math.max(1, end - 4);
    }

    return Array.from({ length: end - start + 1 }, (_, i) => start + i);
  }

  get isPreviousDisabled() {
    return this.pageNumber === 1; // Disable previous button if on first page
  }

  get isNextDisabled() {
    return this.pageNumber * this.recordsPerPage >= this.totalRecords; // Disable next button if on last page
  }

  get isRecordIdMissing() {
    return !this.recordId; // Check if recordId is missing
  }

  // Format account labels for display
  get accountLabels() {
    return this.accounts.map((account) => ({
      Id: account.Id,
      label: `${account.Name} ($${account.OpportunityTotal})`, // Example format
      Opportunities: account.Opportunities
    }));
  }

  // Return button styles based on current page
  get buttonVariants() {
    return this.visiblePageNumbers.map((page) => {
      return this.pageNumber === page ? "brand" : "neutral";
    });
  }

  // Wire the getAccounts method from Apex
  @wire(getAccounts, {
    searchKey: "$searchKey",
    totalAmount: "$totalAmountSearchKey", // Use totalAmount for filtering
    pageNumber: "$pageNumber",
    recordsPerPage: "$recordsPerPage"
  })
  wiredAccounts({ error, data }) {
    if (data) {
      this.isAccountDataLoaded = false; // Data is loading
      if (this.recordId) {
        this.loadOpportunitiesForAccount(this.recordId).then(() => {
          this.isAccountDataLoaded = true; // Data is loaded
        });
      } else {
        this.accounts = data.accounts.map((account) => ({
          ...account,
          Opportunities: account.Opportunities.map((opportunity) => ({
            ...opportunity,
            OpportunityUrl: `/lightning/r/Opportunity/${opportunity.Id}/view` // Generate URL for opportunity
          }))
        }));
        this.totalRecords = data.totalRecords; // Set total records
        this.filterAccounts(); // Filter accounts after loading
      }
      this.isLoading = false; // Set loading state to false
    } else if (error) {
        toastUtils.showToast(
        this,
        "Error",
        error.body.message,
        "error"
      );
      this.isLoading = false; // Set loading state to false on error
    }
  }

  // Filter accounts based on search criteria
  filterAccounts() {
    if (!Array.isArray(this.accounts) || this.accounts.length === 0) {
      this.filteredAccounts = []; // Set to empty if no accounts
      return;
    }

    const searchKeyLower = this.searchKey.toLowerCase();
    const totalAmount = parseFloat(this.totalAmountSearchKey) || 0; // Use totalAmount for filtering
    this.filteredAccounts = this.accounts.filter((account) => {
      const accountMatches =
        account.Name.toLowerCase().includes(searchKeyLower);
      const amountMatches = account.OpportunityTotal >= totalAmount; // Filter by total amount

      return accountMatches || amountMatches; // Return true if matches
    });
  }

  // Handle changes in search input
  handleSearchChange(event) {
    const inputValue = event.target.value.trim(); // Trim whitespace

    // Remove spaces between digits
    const cleanedValue = inputValue.replace(/\s+/g, ""); // Remove all spaces

    // Check if the entered value is a number
    const parsedValue = parseFloat(cleanedValue);
    if (!isNaN(parsedValue)) {
      this.totalAmountSearchKey = parsedValue; // Set for amount search
      this.searchKey = ""; // Reset searchKey if number entered
    } else {
      this.totalAmountSearchKey = 0; // Reset amount if not a number
      this.searchKey = inputValue; // Set value for name search
    }

    this.pageNumber = 1; // Reset page on new search
    this.filterAccounts(); // Update filtering
  }

  // Handle page changes
  handlePageChange(event) {
    this.pageNumber = Number(event.target.dataset.page); // Set the page number
  }

  // Handle row actions (button clicks) in the data table
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const opportunityId = event.detail.row.Id; // Get opportunity ID
    if (actionName === "view_products") {
      this.loadProductsForOpportunity(opportunityId); // Load products for opportunity
      this.showModal = true; // Show modal
    }
  }

  // Load opportunities for a specific account
  loadOpportunitiesForAccount(accountId) {
    return getOpportunities({ accountId })
      .then((data) => {
        this.opportunities.accounts = data; // Store opportunities
        this.accounts = data.map((opportunity) => ({
          Id: opportunity.AccountId, // Assuming you have AccountId field
          Name: opportunity.Name, // Get account name
          OpportunityTotal: opportunity.Amount, // Set total amount
          Opportunities: [
            {
              Id: opportunity.Id,
              Name: opportunity.Name,
              Amount: opportunity.Amount,
              CloseDate: opportunity.CloseDate,
              StageName: opportunity.StageName,
              OpportunityUrl: `/lightning/r/Opportunity/${opportunity.Id}/view`
            }
          ]
        }));
        this.filterAccounts(); // Filter accounts after loading
      })
      .catch((error) => {
        toastUtils.showToast(this, "Error", error.body.message, "error" )
      });
  }

  // Load products related to a specific opportunity
  loadProductsForOpportunity(opportunityId) {
    getProducts({ opportunityId })
      .then((data) => {
        this.productData = data; // Assign product data
      })
      .catch((error) => {
        toastUtils.showToast(this, "Error", error.body.message, "error" )
      });
  }

  // Close the modal
  closeModal() {
    this.showModal = false; // Set modal visibility to false
  }

  // Navigate to the next page
  handleNextPage() {
    if (this.pageNumber * this.recordsPerPage < this.totalRecords) {
      this.pageNumber++; // Increment page number
    }
  }

  // Navigate to the previous page
  handlePreviousPage() {
    if (this.pageNumber > 1) {
      this.pageNumber--; // Decrement page number
    }
  }
}
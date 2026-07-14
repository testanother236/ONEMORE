({
    paginateRecords: function(component) {
        var records = component.get("v.records");
        var currentPage = component.get("v.currentPage");
        var recordsPerPage = component.get("v.recordsPerPage");

        // Calculate start and end index for the current page
        var startIndex = (currentPage - 1) * recordsPerPage;
        var endIndex = currentPage * recordsPerPage;

        // Slice the records to get the paginated data
        var paginatedRecords = records.slice(startIndex, endIndex);
        component.set("v.paginatedRecords", paginatedRecords);
    }
})
global with sharing virtual class ExtentionPackageIntegration {

    global Object data;

    global void setData(Object data) {
        this.data = data;
    }

    global virtual Object execute() { return null; }
}
public with sharing class RequiredRadioButtonController
{
    public String selectedValue {get; set;}
    
    public List<SelectOption> radioOptions {get; set;}

    public RequiredRadioButtonController(ApexPages.StandardController controller) {
        radioOptions = new List<SelectOption>();
        radioOptions.add(new SelectOption('1','One'));
        radioOptions.add(new SelectOption('2','Two'));
        radioOptions.add(new SelectOption('3','Three'));
        radioOptions.add(new SelectOption('4','Four'));
    }

    
}
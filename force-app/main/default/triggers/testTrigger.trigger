trigger testTrigger on Lead ( After update) {
if (Trigger.isAfter) {

        if (Trigger.isUpdate) { 

            Map<ID,ID> oppToContact = new Map<ID,ID>(); 
            for (Lead ld : Trigger.new) {
                if(ld.isConverted && trigger.oldMap.get(ld.id).isConverted) continue; //only process newly converted leads. 

                // Change a comment line again again again again again. Find all converted Leads with Opportunitiy and add ConvertedOpportunityId to setConvertedOppIds add test
                if (ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null){                    
                    oppToContact.put(ld.ConvertedOpportunityId,ld.ConvertedContactID);  

                }

            }  

       if (!oppToContact.isEmpty()) {

                List<Opportunity> lstOpp = new List<Opportunity>();
                for(Opportunity opps:[select Id,AccountId,CampaignId from Opportunity where Id in :oppToContact.keySet()]){

                    if(oppToContact.containsKey(opps.id)){
                       // opps. = oppToContact.get(opps.id);
                        lstOpp.add(opps);
                    }

                }
// add a line 1
// add a line 2

        if (!lstOpp.isEmpty()) {
          Update lstOpp;
         }

    }
}}

}
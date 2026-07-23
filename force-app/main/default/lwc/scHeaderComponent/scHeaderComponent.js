import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ScHeaderComponent extends NavigationMixin(LightningElement) {

    @api name;
    arrLinks = [
        {
            label: 'User Info',
            href: '/home',
            apiName: 'Home'
        },
        {
            label: 'My Opportunities',
            href: '/opportunities',
            apiName: 'Opportunities__c'
        },
        {
            label: 'New Opportunity',
            href: '/create',
            apiName: 'Create__c'
        }

    ]


    handleClick(event) {
       event.preventDefault();
       let pageApiName = event.target.dataset.api;
       if(pageApiName){
            this.navigateToPages(pageApiName);
       }
    }


    navigateToPages(pageApiName) {
        this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageApiName
                }
        })
    }
}
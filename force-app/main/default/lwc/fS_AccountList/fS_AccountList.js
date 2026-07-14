import { LightningElement } from 'lwc';
/** BearController.getAllBears() Apex method */
export default class BearList extends LightningElement {
	bears;
	error;
	appResources = {
		bearSilhouette: '/img/standing-bear-silhouette.png',
	};
	connectedCallback() {
		this.loadBears();
	}
	loadBears() {
        this.bears = [];
        /*var wrObj = {};
        wrObj.Id = 'eewewe';
        wrObj.Name = 'Test';
        this.bears.push(wrObj);*/
	}
}
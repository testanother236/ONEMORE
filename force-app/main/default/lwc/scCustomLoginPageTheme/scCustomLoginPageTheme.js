import { LightningElement, api } from 'lwc';

export default class ScCustomLoginPageTheme extends LightningElement {
    @api backgroundColor = '#e39233';
    @api nameOrg;
    headerText = 'Welcome to '

    renderedCallback() {
        this.template.querySelector(".container").style.backgroundColor = this.backgroundColor;
    }
}
import { LightningElement } from 'lwc';

export default class ScFooterComponent extends LightningElement {

    companyName = 'Success Motors Limited'
    footerText = `Copyright ${new Date().getFullYear()} © ${this.companyName}`

    get footerInfo(){
        return this.footerText
    }
}
import { LightningElement, track, api } from 'lwc';



export default class Detail extends LightningElement {

    // Ensure changes are reactive when product is updated
    @track product;
    
    totalAmount = 0;
    totalNumber = 0;

    // Private var to track @api productId
    _productId = undefined;
    
    // account ID
    _accId = undefined;

    // Use set and get to process the value every time it's
    // requested while switching between products
    set productId(value) {
        this._productId = value;
        this.product = bikes.find(bike => bike.fields.Id.value === value);
    }
    
    // getter for productId
    @api get productId(){
        return this._productId;
    }
    
    calculateAmount(event) {
        this.totalAmount = event.target.value;
    }
    
    fillNumber(event) {
        this.totalNumber = event.target.value;
    }
}
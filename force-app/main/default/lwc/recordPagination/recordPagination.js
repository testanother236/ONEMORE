import { LightningElement,api, wire } from 'lwc';
import getRecordList from '@salesforce/apex/RecordPaginationController.getRecordList'

export default class RecordPagination extends LightningElement {
    objectName;
    fieldNames;
    whereclause;
    recordLimit;
    parameterObject;
    @api 
    get objectName(){
        return this.objectName;
    };
    set objectName(value){
        this.objectName = value;
    };

    @api 
    get fieldNames(){
        return this.fieldNames;
    };
    set fieldNames(value){
        this.fieldNames = value;
    };

    @api 
    get whereclause(){
        return this.whereclause;
    };
    set whereclause(value){
        this.whereclause = value;
    };

    @api 
    get recordLimit(){
        return this.recordLimit;
    };
    set recordLimit(value){
        this.recordLimit = value;
    };

    connectedCallback() {
        this.objectName = this.getAttribute('objectName');
        console.log(this.objectName);
        this.fieldNames = this.getAttribute('fieldNames');
        this.whereclause = this.getAttribute('whereclause');
        this.recordLimit = this.getAttribute('recordLimit');
        this.parameterObject = {
            objectName:this.objectName,
            fiedNames:this.fieldNames,
            whereclause:this.whereclause,
            recordLimit:this.recordLimit
        };
        console.log(this.parameterObject);
        getRecordList({recordQueryWrapper: '$parameterObject' }).then(data =>{
            this.recordList = data;
            this.error = undefined;
        })
        .catch(error =>{
            this.errorMsg = error;
            this.recordList = undefined;
        })
    }

    get Records(){
        
        return this.recordList;
    }

    get isRecordExist(){
        if(this.recordList != undefined && this.recordList.length > 0){
            return true;
        }
        return false;
    }
}
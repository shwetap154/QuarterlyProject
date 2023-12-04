import { LightningElement } from 'lwc';
export default class DatatableFirstSectionDemo extends LightningElement {
dateval;

    get dateValue(){
         if(this.dateval == undefined)
    {
      this.dateval = new Date().toISOString().substring(0, 10);
    }
    return this.dateval;
  }

  changedate(event){
    this.dateval = event.target.value;
  }
    }
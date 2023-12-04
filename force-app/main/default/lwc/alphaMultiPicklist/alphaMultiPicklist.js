import { LightningElement, api, track, wire } from 'lwc';

export default class AlphaMultiPicklist extends LightningElement {
    
    /* 
    component receives the following params:
    label - String with label name;
    disabled - Boolean value, enable or disable Input;
    options - Array of objects [{label:'option label', value: 'option value'},{...},...];

    to clear the value call clear() function from parent:
    let multiSelectPicklist = this.template.querySelector('c-multi-select-pick-list');
    if (multiSelectPicklist) {
        multiSelectPicklist.clear();
    }

    to get the value receive "valuechange" event in parent;
    returned value is the array of strings - values of selected options;
    example of usage:
    <c-multi-select-pick-list options={marketAccessOptions}
                                onvaluechange={handleValueChange}
                                label="Market Access">
    </c-multi-select-pick-list>

    handleValueChange(event){
        console.log(JSON.stringify(event.detail));
    }
    */

    @api label = "Default label";
    @api hideLabel = false;
    @api blockAll = false;

    _disabled = false;
    @api
    get disabled(){
        return this._disabled;
    }
    set disabled(value){
        this._disabled = value;
        this.handleDisabled();
    }

    @track inputOptions;

    @api
    get options() {
        return this.inputOptions.filter(option => option.value !== 'All');
    }
    set options(value) {
        let options = [{
            value: 'All',
            label: 'All'
        }];
        this.inputOptions = options.concat(value);
    }

    clearStatus = false;
    @api
    clear(){
        this.clearStatus = true;
        this.handleAllOption();
        this.clearStatus = false;
    }

    @api value = [];
    // value = [];
    @track inputValue;

    hasRendered;
    renderedCallback() {
        if (!this.hasRendered) {
            //  we call the logic once, when page rendered first time
            this.handleDisabled();
            this.handleInitOptions();
        }
        this.hasRendered = true;
    }

    handleDisabled(){
        let input = this.template.querySelector("input");
        if (input){
            input.disabled = this.disabled;
        }
    }

    comboboxIsRendered;
    handleClick() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.toggle("slds-is-open");
        if (!this.comboboxIsRendered){
            // let allOption = this.template.querySelector('[data-id="All"]');
            // allOption.firstChild.classList.add("slds-is-selected");
            this.comboboxIsRendered = true;
        }
    }

    handleSelection(event) {
        let disabled = event.currentTarget.dataset.disabled;
        if (!disabled) {
            let value = event.currentTarget.dataset.value;
            if (value === 'All') {
                this.handleAllOption();
            }
            else {
                let foundOption = this.inputOptions.find(option => option.value == value);
                if (foundOption && !foundOption.isDisabled) {
                    this.handleOption(event, value);
                }
            }
            let input = this.template.querySelector("input");
            input.focus();
            this.sendValues();
        }
    }

    sendValues(){
        let values = [];
        for (const valueObject of this.value) {
            values.push(valueObject.value);
        }
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: values
        }));
    }

    handleAllOption(){
        if (!this.blockAll || this.clearStatus) {
            this.value = [];
            this.inputValue = 'All';
            let listBoxOptions = this.template.querySelectorAll('.slds-is-selected');
            for (let option of listBoxOptions) {
                option.classList.remove("slds-is-selected");
            }
            let allOption = this.template.querySelector('[data-id="All"]');
            allOption.firstChild.classList.add("slds-is-selected");
            this.closeDropbox();
        }
    }

    handleOption(event, value){
        let listBoxOption = event.currentTarget.firstChild;
        console.log(event);
        console.log(value);
        if (listBoxOption.classList.contains("slds-is-selected")) {
            this.value = this.value.filter(option => option.value !== value);
        }
        else {
            let allOption = this.template.querySelector('[data-id="All"]');
            allOption.firstChild.classList.remove("slds-is-selected");
            let option = this.options.find(option => option.value === value);
            // console.log('option: ' + JSON.stringify(this.value) + ' <= ' + JSON.stringify(option));

            // Sometimes when value is assigned, it is set as a proxy, which does not accept a push. We must first clone the array, push to the cloned array, then reassign it to value
            // this.value.push(option);
            this.value = Object.assign([], this.value);
            this.value.push(option);
        }

        if (this.value.length > 1) {
            // this.inputValue = this.value.length + ' options selected';
            this.inputValue = this.joinLabels(this.value);
        }
        else if (this.value.length === 1) {
            this.inputValue = this.value[0].label;
        }
        else {
            this.inputValue = 'All';
        }
        listBoxOption.classList.toggle("slds-is-selected");
        this.closeDropbox();
    }

    handleInitOptions() {
        this.value = Object.assign([], this.value); // Safety measure like in handleOption()

        if (this.value.length == 0) {
            this.clear();
        }
        else {
            let allOption = this.template.querySelector('[data-id="All"]');
            allOption.firstChild.classList.remove('slds-is-selected');

            for (let i = 0; i < this.value.length; i++) {
                let entry = this.value[i];
                let option = this.template.querySelector('[data-id="' + entry.value + '"');
                option.firstChild.classList.add('slds-is-selected');
            }
            
            if (this.value.length > 1) {
                // this.inputValue = this.value.length + ' options selected';
                this.inputValue = this.joinLabels(this.value);
            }
            else if (this.value.length === 1) {
                this.inputValue = this.value[0].label;
            }
        }
    }

    dropDownInFocus = false;
    handleBlur() {
        if (!this.dropDownInFocus) {
            this.closeDropbox();
        }
    }

    handleMouseleave() {
        this.dropDownInFocus = false;
    }

    handleMouseEnter() {
        this.dropDownInFocus = true;
    }

    closeDropbox() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.remove("slds-is-open");
    }

    joinLabels(array) {
        let string = '';
        for (let i = 0; i < array.length; i++) {
            string += array[i].label;
            if (i != array.length - 1) {
                string += ', ';
            }
        }
        return string;
    }
}
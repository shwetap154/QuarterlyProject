import { LightningElement, api, track, wire } from 'lwc';

export default class AlphaCustomLibraryFileUpload extends LightningElement {
    fileSelected = false;

    @api filters = '';
    @api speciesList = [];
    @api marketList = [];
    @api productLineList = [];
    @api libraryList = [];
    @api fileTypeList = [];
    
    // File details
    @api selectedFile;
    @api selectedFileName;
    @api selectedFilePath;

    @api title = '';
    @api library = '';
    @api fileType = '';
    @api productLine = '';
    @api species = [];
    @api distributor = [];
    @api market = [];

    hasConnected;
    connectedCallback() {
        if (!this.hasConnected) {
            // Tell parent that the component loaded, so we can receive picklist values now
            let reqEvent = new CustomEvent('reqlist');
            this.dispatchEvent(reqEvent);

            this.hasConnected = true;
        }
    }

    handleFileSelected(event) {
        this.fileSelected = true;
        let rawFile = event.target.files[0];
        console.log('rawFile',rawFile);

        var reader = new FileReader();
        reader.onload = () => {
            this.selectedFile = reader.result.split(',')[1];
        }
        reader.readAsDataURL(rawFile);

        this.selectedFileName = rawFile.name;
         console.log('selectedFileName1',this.selectedFileName);
        this.selectedFilePath = event.detail.value;
         console.log('selectedFilePath',this.selectedFilePath);
    }

    handleFieldChange(event) {
        let ctrlName = event.currentTarget.dataset.name;
        
        switch(ctrlName){
            case 'title':
                this.title = event.target.value;
                break;
            case 'library':
                this.library = event.detail.value;
                break;
            case 'fileType':
                this.fileType = event.detail.value;
                break;
            case 'productLine':
                this.productLine = event.target.value;
                break;
            case 'species':
                this.species = event.detail.value;
                break;
            case 'distributor':
                this.distributor = event.detail;
                break;
            case 'market':
                this.market = event.detail.value;
                break;
        }
    }

    @api validation() {
        let validStatus = true;
        validStatus = validStatus && this.template.querySelector('[data-name=\'library\']').checkValidity;
        validStatus = validStatus && this.template.querySelector('[data-name=\'title\']').checkValidity;
        validStatus = validStatus && this.template.querySelector('[data-name=\'species\']').checkValidity;
        return validStatus;
    }
}
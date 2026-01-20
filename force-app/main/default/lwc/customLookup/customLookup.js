import { LightningElement, api, track } from 'lwc';

export default class CustomLookup extends LightningElement {

    @api label;
    @api placeholder;

    @track records = [];
    @track selectedRecord;
    @track showDropdown = false;

    @api
    setResults(results) {
        this.records = results;
        this.showDropdown = results.length > 0;
    }

    handleSearch(event) {
        this.dispatchEvent(new CustomEvent('search', {
            detail: event.target.value
        }));
    }

    handleSelect(event) {
        this.selectedRecord = {
            Id: event.currentTarget.dataset.id,
            Name: event.currentTarget.dataset.name
        };
        this.showDropdown = false;

        this.dispatchEvent(new CustomEvent('select', {
            detail: this.selectedRecord.Id
        }));
    }

    handleRemove() {
        this.selectedRecord = null;
        this.dispatchEvent(new CustomEvent('clear'));
    }

    get comboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${
            this.showDropdown ? 'slds-is-open' : ''
        }`;
    }
}

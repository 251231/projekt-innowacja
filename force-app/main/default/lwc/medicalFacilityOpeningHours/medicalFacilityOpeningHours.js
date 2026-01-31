import { LightningElement, api, wire } from 'lwc';
import getOpeningHours from '@salesforce/apex/openingHoursController.getOpeningHours';
export default class MedicalFacilityOpeningHours extends LightningElement {

    @api recordId;
    openingHoursData;

    @wire(getOpeningHours, { facilityId: '$recordId' })
    wiredHours({data, error}) {
        if(data) {
            this.openingHoursData = data;
        } else if(error) {
            console.error(error);
        }
    }

    parseHours(hours){
        if(!hours) {
            return null;
        }
        const normalized = hours.toLowerCase().replace(/\s+/g, '');
        const parts = normalized.split('-');
        if(parts.length !== 2) {
            return null;
        }
        return {open: parts[0], close: parts[1]};
    }

    get parsedOpeningHours() {
        if(!this.openingHoursData) { 
            return [];
        }
        return this.openingHoursData.map(item=>{
            const parsedHours = this.parseHours(item.Opening_Hour__c);
            return {
                id: item.Id,
                day: item.Day__c,
                openTime: parsedHours.open || null,
                closeTime: parsedHours.close || null,
                isClosed: !parsedHours
            };
        });
    }
}
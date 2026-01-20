import { LightningElement, api } from 'lwc';
import searchDoctors from '@salesforce/apex/DoctorFacilityLookupController.searchDoctors';
import searchFacilities from '@salesforce/apex/DoctorFacilityLookupController.searchFacilities';

export default class MedicalAppointmentNewRA extends LightningElement {

    @api recordTypeId; // <<< KLUCZOWE
    doctorId;
    facilityId;

    connectedCallback() {
        console.log('RecordTypeId:', this.recordTypeId);
    }

    async searchDoctors(event) {
        const results = await searchDoctors({
            searchKey: event.detail,
            facilityId: this.facilityId
        });
        this.template.querySelector('c-custom-lookup[label="Doctor"]')
            ?.setResults(results);
    }

    async searchFacilities(event) {
        const results = await searchFacilities({
            searchKey: event.detail,
            doctorId: this.doctorId
        });
        this.template.querySelector('c-custom-lookup[label="Medical Facility"]')
            ?.setResults(results);
    }

    doctorSelected(event) {
        this.doctorId = event.detail;
        this.facilityId = null;
    }

    facilitySelected(event) {
        this.facilityId = event.detail;
    }



    doctorCleared() {
        this.doctorId = null;
    }

    facilityCleared() {
        this.facilityId = null;
    }
}

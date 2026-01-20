import { LightningElement, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import searchDoctors from '@salesforce/apex/DoctorFacilityLookupController.searchDoctors';
import searchFacilities from '@salesforce/apex/DoctorFacilityLookupController.searchFacilities';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import MEDICAL_APPOINTMENT_OBJECT from '@salesforce/schema/Medical_Appointment__c';

export default class MedicalAppointmentCreate extends NavigationMixin(LightningElement) {

    // ===== Record Type =====
    recordType;
    recordTypeId;

    recordTypeOptions = [
        { label: 'On Site', value: 'On Site' },
        { label: 'Online', value: 'Online' }
    ];

    @wire(getObjectInfo, { objectApiName: MEDICAL_APPOINTMENT_OBJECT })
    objectInfo;

    handleRecordType(event) {
        this.recordType = event.detail.value;

        const rtInfos = this.objectInfo.data.recordTypeInfos;
        this.recordTypeId = Object.keys(rtInfos).find(
            rtId => rtInfos[rtId].name === this.recordType
        );
    }

    // ===== Fields =====
    appointmentType;
    appointmentStatus;
    department;
    appointmentDate;
    description;

    patientId;
    doctorId;
    facilityId;

    // ===== Picklist handlers =====
    handleAppointmentType(e) { this.appointmentType = e.detail.value; }
    handleAppointmentStatus(e) { this.appointmentStatus = e.detail.value; }
    handleDepartment(e) { this.department = e.detail.value; }
    handleDate(e) { this.appointmentDate = e.target.value; }
    handleDescription(e) { this.description = e.target.value; }

    // ===== Picklist options (STATIC – jak poprzednio) =====
    appointmentTypeOptions = [
        { label: 'Consultation', value: 'Consultation' },
        { label: 'Check-up', value: 'Check-up' }
    ];

    appointmentStatusOptions = [
        { label: 'Requested', value: 'Requested' },
        { label: 'Confirmed', value: 'Confirmed' }
    ];

    departmentOptions = [
        { label: 'Cardiology', value: 'Cardiology' },
        { label: 'Dermatology', value: 'Dermatology' }
    ];

    // ===== Lookups =====
    patientSelected(e) {
        this.patientId = e.detail;
    }

    async searchDoctors(event) {
        const results = await searchDoctors({
            searchKey: event.detail,
            facilityId: this.facilityId
        });
        event.target.setResults(results);
    }

    async searchFacilities(event) {
        const results = await searchFacilities({
            searchKey: event.detail,
            doctorId: this.doctorId
        });
        event.target.setResults(results);
    }

    doctorSelected(e) {
        this.doctorId = e.detail;
        this.facilityId = null;
    }

    facilitySelected(e) {
        this.facilityId = e.detail;
    }

    doctorCleared() { this.doctorId = null; }
    facilityCleared() { this.facilityId = null; }

    // ===== SAVE =====
    async save() {

        if (
            !this.recordTypeId ||
            !this.appointmentType ||
            !this.appointmentStatus ||
            !this.department ||
            !this.appointmentDate ||
            !this.patientId ||
            !this.doctorId ||
            !this.facilityId
        ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Fill all required fields.',
                    variant: 'error'
                })
            );
            return;
        }

        const fields = {
            RecordTypeId: this.recordTypeId,
            Appointment_Type__c: this.appointmentType,
            Appointment_Status__c: this.appointmentStatus,
            Department__c: this.department,
            Appointment_DateTime__c: this.appointmentDate,
            Description__c: this.description,
            Patient__c: this.patientId,
            Doctor__c: this.doctorId,
            Medical_facility__c: this.facilityId
        };

        const record = await createRecord({
            apiName: 'Medical_Appointment__c',
            fields
        });

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Medical Appointment created',
                variant: 'success'
            })
        );

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: record.id,
                objectApiName: 'Medical_Appointment__c',
                actionName: 'view'
            }
        });
    }
}

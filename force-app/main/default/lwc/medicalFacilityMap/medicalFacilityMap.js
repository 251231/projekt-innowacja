import { LightningElement, wire, track } from 'lwc';
import getFacilities from '@salesforce/apex/MedicalFacilityMapController.getFacilities';

const DEFAULT_ZOOM = 6;

export default class MedicalFacilityMap extends LightningElement {

    get hasMarkers() {
        return this.mapMarkers && this.mapMarkers.length > 0;
    }

    @track allFacilities = [];
    @track filteredFacilities = [];
    @track mapMarkers = [];

    searchKey = '';
    zoomLevel = DEFAULT_ZOOM;

    polandCenter = {
        location: {
            Latitude: 52.2297,
            Longitude: 21.0122
        }
    };

    columns = [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'text'
        }
    ];

    buildMarker(f) {
        return {
            value: f.Id,
            location: {
                Street: f.Medical_Facility_Address__Street__s,
                City: f.Medical_Facility_Address__City__s,
                PostalCode: f.Medical_Facility_Address__PostalCode__s,
                Country: f.Medical_Facility_Address__CountryCode__s
            },
            title: f.Name,
            description:
                (f.Medical_Facility_Address__Street__s || '') + '<br>' +
                (f.Medical_Facility_Address__PostalCode__s || '') + ' ' +
                (f.Medical_Facility_Address__City__s || '')
        };
    }

    @wire(getFacilities)
    wiredFacilities({ data, error }) {
        if (data) {
            this.allFacilities = data;
            this.filteredFacilities = data;
            this.mapMarkers = data.map(f => this.buildMarker(f));
        } else if (error) {
            console.error(error);
        }
    }
    handleSearch(event) {
        const value = (event.target.value || '').trim().toLowerCase();
        this.searchKey = value;

        if (!value) {
            this.filteredFacilities = this.allFacilities;
            this.mapMarkers = this.allFacilities.map(f => this.buildMarker(f));
            return;
        }

        const results = this.allFacilities.filter(f =>
            f.Name && f.Name.toLowerCase().includes(value)
        );

        this.filteredFacilities = results;

        if (results.length === 0) {
            this.mapMarkers = [];
            return;
        }

        this.mapMarkers = results.map(f => this.buildMarker(f));
    }
}
import { LightningElement, wire, track } from 'lwc';
import getFacilities from '@salesforce/apex/MedicalFacilityMapController.getFacilities';

const DEFAULT_ZOOM = 6;


export default class MedicalFacilityMap extends LightningElement {

    @track filteredFacilities = [];
    @track mapMarkers = [];

    searchKey = '';
    zoomLevel = DEFAULT_ZOOM;
    showMap = true;


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
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'Name' },
            name: 'select',
            variant: 'base'
        }
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

    @wire(getFacilities, { searchKey: '$searchKey' })
    wiredFacilities({ data, error }) {
        if (data) {
            this.filteredFacilities = data;
            this.mapMarkers = data.map(f => this.buildMarker(f));
            
        } else if (error) {
            console.error(error);
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
    }
    handleRowAction(event) {
        if (event.detail.action.name !== 'select') {
            return;
        }

        const facility = event.detail.row;

        this.polandCenter = {
            location: {
                Street: facility.Medical_Facility_Address__Street__s,
                City: facility.Medical_Facility_Address__City__s,
                PostalCode: facility.Medical_Facility_Address__PostalCode__s,
                Country: facility.Medical_Facility_Address__CountryCode__s
            }
        };

        this.zoomLevel = 14;

        this.showMap = false;
        requestAnimationFrame(() => {
            this.showMap = true;
        });
    }

}

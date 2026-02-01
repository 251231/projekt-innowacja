({
    loadFacilities : function(component) {
        this.callApex(component, "getFacilities", {}, function(data) {
            component.set("v.facilities", data.map(f => ({
                label: f.Name,
                value: f.Id
            })));
        });
    },

    loadDoctors : function(component) {
        this.callApex(component, "getDoctors", {}, function(data) {
            component.set("v.doctors", data.map(d => ({
                label: d.Name,
                value: d.Id
            })));
        });
    },

    loadPatients : function(component) {
        this.callApex(component, "getPatients", {}, function(data) {
            component.set("v.patients", data.map(p => ({
                label: p.Name,
                value: p.Id
            })));
        });
    },

    loadDoctorsByFacility : function(component, facilityId) {
        this.callApex(component, "getDoctorsByFacility", { facilityId }, function(data) {
            component.set("v.doctors", data.map(d => ({
                label: d.Name,
                value: d.Id
            })));
        });
    },

    loadFacilitiesByDoctor : function(component, doctorId) {
        this.callApex(component, "getFacilitiesByDoctor", { doctorId }, function(data) {
            component.set("v.facilities", data.map(f => ({
                label: f.Name,
                value: f.Id
            })));
        });
    },

    callApex : function(component, method, params, callback) {
        var action = component.get("c." + method);
        action.setParams(params);
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                callback(response.getReturnValue() || []);
            } else {
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})

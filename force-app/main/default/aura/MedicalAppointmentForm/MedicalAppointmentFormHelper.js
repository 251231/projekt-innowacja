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
    },
    loadDoctorsByFacilityAndSpecialization : function(component) {
        this.callApex(
            component,
            "getDoctorsByFacilityAndSpecialization",
            {
                facilityId: component.get("v.facilityId"),
                specialization: component.get("v.specialization")
            },
            function(data) {
                var options = data.map(d => ({
                    label: d.Name,
                    value: d.Id
                }));

                component.set("v.doctors", options);
                component.set("v.isDoctorDisabled", false);

                component.set(
                    "v.doctorId",
                    options.length ? options[0].value : null
                );
            }
        );
    },

    loadSpecializations : function(component) {
        this.callApex(
            component,
            "getDoctorSpecializations",
            {},
            function(data) {
                component.set(
                    "v.specializationOptions",
                    data.map(v => ({
                        label: v,
                        value: v
                    }))
                );
            }
        );
    },
    evaluateDoctorState : function(component) {
        var facilityId = component.get("v.facilityId");
        var specialization = component.get("v.specialization");

        if (!facilityId || !specialization) {
            component.set("v.isDoctorDisabled", true);
            component.set("v.doctors", []);
            component.set("v.doctorId", null);
            return;
        }

        this.loadDoctorsByFacilityAndSpecialization(component);
    },


})

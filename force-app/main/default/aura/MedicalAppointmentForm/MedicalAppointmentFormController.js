({
    doInit : function(component, event, helper) {
        helper.loadFacilities(component);
        helper.loadPatients(component);
        helper.loadSpecializations(component); 
    },



    handleFacilityChange : function(component, event, helper) {
        component.set("v.facilityId", event.getParam("value"));
        helper.evaluateDoctorState(component);
    },

    handleDoctorChange : function(component, event, helper) {
        var doctorId = component.get("v.doctorId");
        if (!doctorId) return;

        helper.loadFacilitiesByDoctor(component, doctorId);
    },

    handleSuccess : function(component) {
        $A.get("e.force:showToast")
            .setParams({
                title: "Success",
                message: "Medical appointment created successfully",
                type: "success"
            })
            .fire();
    },

    handleError : function(component, event) {
        console.error("SAVE ERROR", event.getParam("error"));
    },
    handleSpecializationChange : function(component, event, helper) {
        component.set("v.specialization", event.getParam("value"));
        helper.evaluateDoctorState(component);
    },


})

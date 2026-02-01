({
    doInit : function(component, event, helper) {
        helper.loadFacilities(component);
        helper.loadDoctors(component);
        helper.loadPatients(component);
    },

    handleFacilityChange : function(component, event, helper) {
        var facilityId = component.get("v.facilityId");
        if (!facilityId) return;

        helper.loadDoctorsByFacility(component, facilityId);
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
    }
})

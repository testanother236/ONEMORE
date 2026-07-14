({
    doInit: function(component, event, helper) {
        // Fetch the records from Apex Controller
        var action = component.get("c.getRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.records", response.getReturnValue());
                helper.paginateRecords(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    previousPage: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        if (currentPage > 1) {
            component.set("v.currentPage", currentPage - 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage1: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage2: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage3: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage4: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage5: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage6: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage7: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage8: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage9: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage10: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage11: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage12: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage13: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage14: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage15: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage16: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage17: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage18: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage19: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage20: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage21: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage22: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage23: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage24: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage25: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage26: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage27: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage28: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage29: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage30: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage31: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage32: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage33: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage34: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage35: function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = Math.ceil(component.get("v.records").length / component.get("v.recordsPerPage"));
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            helper.paginateRecords(component);
        }
    }
})
({

	// Your renderer method overrides go here
    afterRender : function(component, event, helper) {
        var svg = component.find("svg1");
        var value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value;  
        
        
        var ul = component.find("ul");
    }

})
Event.observe(window, 'load', function(){
    Application.instrumentElements();
  });

var Behaviour = Class.create();
Behaviour.prototype = {
  element    : null,
  behaviour  : null,

  initialize : function(element, action) {
    this.element = element;
    this.action     = action;
  }
};

var PagePreview = Class.create();
PagePreview.prototype = {
  button_id  : "page_preview",
  form_id    : "page_form",
  preview_id : "preview",
  url        : "/pages/preview",

  initialize: function() {
    this.addPreviewButton();
    this.observe();
  },

  addPreviewButton: function() {
    var submit = $(this.form_id).getElementsByClassName('submit').first();
    var preview = Builder.node("input", 
                               {type: "button", value: "Preview",
                                id: this.button_id});

    submit.parentNode.insertBefore(preview, submit);
    submit.parentNode.insertBefore(document.createTextNode(" "), submit);
  },

  observe: function() {
    Event.observe(this.button_id, "click", this.show.bind(this));
  },

  show: function() {
    new Ajax.Updater(this.preview_id, this.url, 
                     { parameters: this.collectParameters() });
  },

  collectParameters: function() {
    var parameters = Form.serialize(this.form_id, true);

    delete(parameters._verb);
    if (! $H(parameters).keys().include("page[name]")) {
      parameters["page[name]"] = $('page_name').firstChild.nodeValue;
    }

    return parameters;
  }
};

var Application = {
  behaviours : [
      new Behaviour("page_form", function() { new PagePreview(); })
    ],

  instrumentElements: function() {
    this.behaviours.each(function(behaviour) {
        if($(behaviour.element)) { behaviour.action(); }
      });
  }
};

module OAList
  begin;OAList::Authorizations.instance_methods;rescue;module Authorizations;end;end
  
  class Container < OAWidget::Base   
    include OAList::Authorizations
    
    # Set adapter defaults
    ['allowed?'].each do |method|
      unless OAList::Authorizations.instance_methods.include?(method)
        OAList::Authorizations::module_eval {define_method(method.to_sym){true}}
      end
    end # each method

    SAVEABLE_ATTRIBUTES = [
      :hide, 
      :list_item_partial, :toolbar_item_partial, :auto_complete_partial, :contextual_actions_partial,
      :views, :sorts, :pages, :toolbar,
      :search, :auto_complete, :check_existance,
      :collection,
      :title
    ]
    
    PRESERVING_PARAMS = [:search_text, :view, :sort, :per_page]
    PRESERVING_PARAMS.each do |p|
      attr_accessor p
    end
    
    has_widgets do |top|
      heartbeatWidget = OAWidget::Heartbeat.new("#{top.name}-heartbeat",  :preserve => PRESERVING_PARAMS)
      anchorsWidget   = OAWidget::Anchors.new("#{top.name}-anchors",      :preserve => PRESERVING_PARAMS)
      
      searchWidget    = OAList::Search.new("#{top.name}-search",    :preserve => PRESERVING_PARAMS)
      filtersWidget   = OAList::Filters.new("#{top.name}-filters",  :preserve => PRESERVING_PARAMS)
      listWidget      = OAList::List.new("#{top.name}-list",        :preserve => PRESERVING_PARAMS)
      toolbarWidget   = OAList::Toolbar.new("#{top.name}-toolbar",  :preserve => PRESERVING_PARAMS)
      
      top << heartbeatWidget
      top << searchWidget     unless (top.hidden?(:search) || top.search.blank?)
      top << anchorsWidget    if top.save?
      top << filtersWidget    unless top.hidden?(:filters)
      top << listWidget       unless top.hidden?(:list)
      top << toolbarWidget    unless (top.hidden?(:toolbar) || top.toolbar.blank?)

      top.respond_to_event :params_changed,   :with => :update_heartbeat, :on => heartbeatWidget.name
      top.respond_to_event :filters_changed,  :with => :update_heartbeat, :on => heartbeatWidget.name
      top.respond_to_event :filters_changed,  :with => :update_content,   :on => listWidget.name
      top.respond_to_event :content_changed,  :with => :update_content,   :on => listWidget.name
      top.respond_to_event :search,           :with => :update_content,   :on => listWidget.name
      
      unless top.hidden?(:toolbar)
        top.respond_to_event :filters_changed,  :with => :reset_check_all,  :on => toolbarWidget.name
        top.respond_to_event :search,           :with => :reset_check_all,  :on => toolbarWidget.name
        top.respond_to_event :paginate,         :with => :reset_check_all,  :on => toolbarWidget.name
        top.respond_to_event :content_changed,  :with => :reset_check_all,  :on => toolbarWidget.name
      end
    end
    
    def initialize(widget_id, options={})      
      # saved options
      @saved_options = {}
      
      (SAVEABLE_ATTRIBUTES + PRESERVING_PARAMS).each do |attribute|
        @saved_options[attribute] = options[attribute] if options.include?(attribute)
        next if PRESERVING_PARAMS.include?(attribute)
        instance_variable_set("@#{attribute}", options.delete(attribute))
        self.class_eval {define_method("#{attribute}".to_sym){ instance_variable_get("@#{attribute}") }}
      end
      
      @save = options.delete(:save)
                  
      # Default values for preserved params
      @view ||= 0 unless @views.blank?
      @sort ||= 0 unless @sorts.blank?
      @per_page ||= self.class.per_page
      
      super(widget_id, :container, options)
    end
    
    def container
      get_preserved_params
      render
    end
    
    def update_container
      get_preserved_params
      replace :view => 'container'
    end
    
    #pragma mark -
    #pragma mark accessors
    
    def hidden?(part)
      @hide ||= []
      @hide.include?(part.to_sym)
    end
    
    def filters
      f = []
      f << @views[@view.to_i].last unless @views.blank? && @view.blank?
      f << @sorts[@sort.to_i].last unless @sorts.blank? && @sort.blank?
      (f - [nil]).flatten
    end
    
    def eval_collection
      eval collection
    end
        
    def all_items(more=nil)
      scopes = []
      scopes << filters
      if more.nil?
        if @auto_complete.nil?
          scopes << @search unless search_text.blank?
        end
      else
        scopes << more
      end
      scopes.flatten!
      scopes -= [nil]

      scopes_to_eval = [collection]
      scopes.each do |scope|
        scopes_to_eval << "send(:#{scope}, self)"
      end
      RAILS_DEFAULT_LOGGER.debug("all_items: #{scopes_to_eval.join('.')}")
      debugger
      eval scopes_to_eval.join('.')
    end
        
    def save?
      !@save.nil?
    end
    
    def save
      @save.call(saved_state)
    end
    
    
    private
    def get_preserved_params
      PRESERVING_PARAMS.each do |p|
        self.instance_variable_set("@#{p.to_s}", param(p.to_sym)) if param(p.to_sym)
      end
    end
    
    def self.per_page; 5; end
    
    def saved_state
      widget_state = @saved_options
      widget_state.merge!(params)
      widget_state.delete(:save)
      ["event","action","authenticity_token","type","controller","source","_"].each do |k|
        widget_state.delete(k.to_sym)
        widget_state.delete(k)
      end
      widget_state[:widget_class] = self.class.to_s
      widget_state[:widget_name] = name
      
      clean_states = {}
      widget_state.each do |key, value|
        clean_states[key.to_sym] = value
      end
      clean_states
    end
    
  end
end
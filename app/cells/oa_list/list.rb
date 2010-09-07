module OAList
  class List < OAWidget::Base    
    responds_to_event :paginate, :with => :update_content
    
    def initialize(widget_id, options={})
      preserves_attrs(options.delete(:preserve))
      super(widget_id, :list, options)
    end

    def list
      load_list
      render
    end
        
    def update_content
      load_list
      replace :view => 'list'
    end
            
    private 
    def load_list
      @items = parent.all_items.paginate(:per_page => @per_page, :page => (param(:page) || 1).to_i)
    end
        
  end
end
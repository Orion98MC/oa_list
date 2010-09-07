module OAList
  class Search < OAWidget::Base

    responds_to_event :auto_complete, :with => :auto_complete
    responds_to_event :check_existance, :with => :check_existance    
            
    def initialize(widget_id, options={})
      preserves_attrs(options.delete(:preserve))
      super(widget_id, :search, options)
    end
    
    def search
      render
    end
            
    def auto_complete
      @items = parent.all_items(parent.auto_complete)
      render
    end
    
    def check_existance 
      if @search_text.blank?
        @item = nil
      else
        if (parent.all_items(parent.check_existance).count == 1)
          @item = parent.all_items(parent.check_existance).first
        else
          @item = parent.eval_collection.new()
        end
      end
      render :view => 'contextual_actions'
    end
    
  end
end
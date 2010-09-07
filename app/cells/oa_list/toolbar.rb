module OAList
  class Toolbar < OAWidget::Base
    
    responds_to_event :toolbar_action, :with => :toolbar_action
    
    def initialize(widget_id, options={})
      super(widget_id, :toolbar)
    end
    
    def toolbar
      render
    end
    
    def reset_check_all
      render :text => "jQuery('div##{name}.toolbar input[type=\"checkbox\"]').attr('checked', false);"
    end
    
    def toolbar_action
      action_method = parent.toolbar[param(:tb_action).to_i][1]
      items = parent.eval_collection.find(param(:ids).split(','))
      # logger.debug("Action: #{action_method}, Items: #{items.collect{|i| i.name}.join(', ')}")
      items.each do |item|
        item.send(action_method.to_sym)
      end
      fire :content_changed
      render :nothing => true
    end
    
  end
end
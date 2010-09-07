module OAListHelper
  
  def oa_list_javascripts
    [].collect{|js| 'oa_list/' + js}
  end
  
  def oa_list_stylesheets
    ['oa_list'].collect{|style| 'oa_list/' + style}
  end
end
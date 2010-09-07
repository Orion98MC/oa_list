namespace :oa_list do
  desc "Sync the oa_list resources (javascripts, stylesheets, images ...) to the public dir"
  task :sync_resources do
    system "rsync -ruv vendor/plugins/oa_list/public/javascripts/ public/javascripts/oa_list"
    system "rsync -ruv vendor/plugins/oa_list/public/stylesheets/ public/stylesheets/oa_list"
    system "rsync -ruv vendor/plugins/oa_list/public/images/ public/images/oa_list"
  end
end
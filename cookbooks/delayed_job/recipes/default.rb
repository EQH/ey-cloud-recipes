#
# Cookbook Name:: delayed_job
# Recipe:: default
#

if node[:instance_role] == "util" && node[:name] !~ /^(mongodb|redis|memcache|admin)/
  node[:applications].each do |app_name,data|
    #next if app_name == 'admin'
    
    # determine the number of workers to run based on instance size
    if app_name == 'admin'
      worker_count = 1
    else
      worker_count = 3
    end
    
    worker_count.times do |count|
      template "/etc/monit.d/delayed_job#{count+1}.#{app_name}.monitrc" do
        source "dj.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :worker_name => "#{app_name}_delayed_job#{count+1}",
          :framework_env => node[:environment][:framework_env]
        })
      end
    end
    
    execute "monit-reload-restart" do
       command "sleep 30 && monit reload && monit restart all dj_#{app_name}"
       action :run
    end
      
  end
end

#
# Cookbook Name:: node_js
# Recipe:: default
#
if ['solo'].include?(node[:instance_role])
  nodejs_version = '0.4.7'
  nodejs_file = "node-v#{nodejs_version}.tar.gz"
  nodejs_dir = "node-v#{nodejs_version}"
  nodejs_url = "http://nodejs.org/dist/#{nodejs_file}"
  nodejs_data_dir = "/data/nodejs"

  ey_cloud_report "nodejs" do
    message "configuring nodejs (#{nodejs_dir})"
  end

  directory nodejs_data_dir do
    owner 'root'
    group 'root'
    mode 0755
    recursive true
  end

  remote_file "#{nodejs_data_dir}/#{nodejs_file}" do
    source nodejs_url
    owner 'root'
    group 'root'
    mode 0644
    backup 0
    not_if { FileTest.exists? "#{nodejs_data_dir}/#{nodejs_file}" }
  end

  execute "unarchive" do
    command "cd #{nodejs_data_dir} && tar zxf #{nodejs_file} && sync"
    not_if { FileTest.directory? "#{nodejs_data_dir}/#{nodejs_dir}" }
  end

  execute "configure" do
    command "cd #{nodejs_data_dir}/#{nodejs_dir} && ./configure"
    not_if { FileTest.exists? "#{nodejs_data_dir}/#{nodejs_dir}/node" }
  end

  execute "build" do
    command "cd #{nodejs_data_dir}/#{nodejs_dir} && make"
    not_if { FileTest.exists? "#{nodejs_data_dir}/#{nodejs_dir}/node" }
  end

  execute "symlink" do
    command "ln -s #{nodejs_data_dir}/#{nodejs_dir}/node #{nodejs_data_dir}/node"
    not_if { FileTest.exists? "#{nodejs_data_dir}/node" }
  end
end

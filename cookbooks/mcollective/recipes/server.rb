#
# Cookbook Name:: mcollective
# Recipe:: server
#
# Copyright 2011, Zachary Stevens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "mcollective::common"

package "mcollective" do
  action :install
  version node['mcollective']['package']['version']
end

service "mcollective" do
  supports :restart => true, :status => true
  action [:enable, :start]
end

# The libdir paths in the MC configuration need to omit the
# trailing "/mcollective"
site_libdir = node['mcollective']['site_plugins'].sub(/\/mcollective$/, '')
template "/etc/mcollective/server.cfg" do
  source "server.cfg.erb"
  mode 0600
  notifies :restart, 'service[mcollective]'
  variables :site_plugins => site_libdir
end

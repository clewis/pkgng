#
# Cookbook Name:: pkgng
# Recipe:: default
#
# Copyright (C) 2013 Douglas Thrift
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if ::File.executable? '/usr/sbin/pkg'
  execute '/usr/sbin/pkg info pkg' do
    environment 'ASSUME_ALWAYS_YES' => '1'
    not_if 'pkg info pkg', :env => {'TMPDIR' => '/dev/null', 'ASSUME_ALWAYS_YES' => '1', 'PACKAGESITE' => 'file:///nonexistent'}
  end
else
  package 'pkg' do
    source 'ports'
    not_if 'pkg info pkg', :env => {'TMPDIR' => '/dev/null', 'ASSUME_ALWAYS_YES' => '1', 'PACKAGESITE' => 'file:///nonexistent'}
  end
end

execute 'pkg2ng' do
  only_if '[ -n "`pkg_info 2>/dev/null`" ]'
end

conf_plain_file '/etc/make.conf' do
  pattern /^WITH_PKGNG=yes$/
  new_line 'WITH_PKGNG=yes'

  action :insert_if_no_match
end

ruby_block 'set pkgng provider' do
  block do
    Chef::Platform.set :platform => :freebsd, :resource => :package, :provider => Chef::Provider::Package::Pkgng
  end
end

#
# Cookbook Name:: pkgng
# Library:: pkgng
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

require 'chef/provider/package/freebsd'
require 'chef/platform'

class Chef
  class Provider
    class Package
      class Pkgng < Freebsd
        def current_installed_version
          pkg_info = shell_out!("pkg info -q #{package_name}", :env => nil, :returns => [0, 70])
          pkg_info.stdout[/^#{package_name}-(.*)/, 1]
        end

        def ports_candidate_version
          pkg_search = shell_out!("pkg search #{package_name}", :env => nil, :returns => [0, 70])
          pkg_search.stdout[/^#{package_name}-(.*)/, 1]
        end

        def load_current_resource
          @current_resource.package_name(@new_resource.package_name)

          @current_resource.version(current_installed_version)
          Chef::Log.debug("#{@new_resource} current version is #{@current_resource.version}") if @current_resource.version

          @candidate_version = ports_candidate_version

          Chef::Log.debug("#{@new_resource} ports candidate version is #{@candidate_version}") if @candidate_version

          @current_resource
        end

        def latest_link_name
          @new_resource.package_name
        end

        def package_name
          @new_resource.package_name
        end

        def install_package(name, version)
          unless @current_resource.version
            case @new_resource.source
            when 'ports'
              super(name, version)
            when /^http/, /^ftp/
              if @new_resource.source =~ /\/$/
                shell_out!("pkg install -y #{package_name}", :env => {'PACKAGESITE' => @new_resource.source, 'LC_ALL' => nil}).status
              else
                shell_out!("pkg add #{@new_resource.source}/#{package_name}", :env => {'LC_ALL' => nil}).status
              end
              Chef::Log.debug("#{@new_resource} installed from: #{@new_resource.source}")
            when /^\//
              shell_out!("pkg add #{file_candidate_version_path}", :env => {'LC_ALL' => nil}).status
              Chef::Log.debug("#{@new_resource} installed from: #{@new_resource.source}")
            else
              shell_out!("pkg install -y #{latest_link_name}", :env => nil).status
            end
          end
        end

        def remove_package(name, version)
          shell_out!("pkg delete -y #{package_name}", :env => nil).status
        end
      end
    end
  end
end

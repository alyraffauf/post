# Copyright (C) Alexandra Chace 2011 <ialyraffauf@gmail.com>
# This file is part of Post.
# Post is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Post is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with Post.  If not, see <http://www.gnu.org/licenses/>.

directory = File.dirname(__FILE__)
path = File.expand_path(directory)

require(File.join(path, "packagedata.rb"))
require(File.join(path, "tools.rb"))
require('fileutils')
require('yaml')

class Install
    def initialize()
        FileUtils.rm_r("/tmp/post") if File.exists?("/tmp/post")
        FileUtils.mkdir("/tmp/post")
        FileUtils.cd("/tmp/post")
        @package_data_base = PackageDataBase.new()
    end

    def install_package(filename)
        extract(filename)
        FileUtils.rm(filename)
        new_files = Dir["**/*"].reject {|file| File.directory?(file) }
        new_directories = Dir["**/*"].reject {|file| File.file?(file) }
        @package_data_base.install_package(".packageData", ".remove", new_files)
        for directory in new_directories
            FileUtils.mkdir_p("#{@package_data_base.get_root()}/#{directory}")
        end
        for file in new_files
            FileUtils.install(file, "#{@package_data_base.get_root()}/#{file}")
            if file.include?("/bin/")
                system("chmod +x #{@package_data_base.get_root()}/#{file}")
            end
        end
        install_script = File.read(".install")
        eval(install_script)
    end
end

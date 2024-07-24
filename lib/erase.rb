# Copyright (C) Alexandra Chace 2011-2012 <ialyraffauf@gmail.com>
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
require('fileutils')

class MissingFile < Exception
end

class Erase
    include FileUtils
    def initialize(queue)
        @queue = queue
        @package_database = PackageDataBase.new()
    end

    def get_queue()
        return @queue
    end

    def build_queue(package)
        @queue.set(package) if @package_database.installed?(package)
    end

    def remove_package(package)
        remove_script = @package_database.get_remove_script(package)

        package_files = @package_database.get_files(package)
        @package_database.remove_package(package)

        package_files.each() do |file|
            file = file.strip()
            root = @package_database.get_root()
            file = "#{root}/#{file}"
            if (FileTest.exists?("#{file}"))
                rm(file)
            end
        end
        eval(remove_script)
    end
end

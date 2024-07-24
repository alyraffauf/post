# Copyright (C) Alexandra Chace 2011-2015 <achace@student.gsu.edu>
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

require('fileutils')

class RemovePackage < Plugin
    def remove_package(package)
        remove_script = @database.get_remove_script(package)

        @database.get_files(package).each do |file|
            file = "#{@root}/#{file.strip}"
            rm(file) if FileTest.exists?(file)
        end
        eval(remove_script)
        @database.remove_package(package)
    end
end

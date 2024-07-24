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

require('net/http')
require('fileutils')

class CommandLineFetch < Plugin
    def fetch_package(package)
        mkdir_p("/tmp/post/#{package}")

        sync_data = @database.get_sync_data(package)
        repo_url = @database.get_url(@database.get_repo(package))

        filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        url = ("#{repo_url}/#{filename}")
        get_file(url, "/tmp/post/#{package}/#{filename}")  
    end
end




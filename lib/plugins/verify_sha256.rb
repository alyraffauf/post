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
require('digest')

class VerificationFailure < Exception
end

class Sha256Check < Plugin
    def verify_package(package)
        cd("/tmp/post/#{package}")
        sync_data = @database.get_sync_data(package)
        repo_url = @database.get_url(@database.get_repo(package))

        filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        url = "#{repo_url}/#{filename}.sha256"
        get_file(url, "/tmp/post/#{package}/#{filename}.sha256")
        file_hash = Digest::SHA256.hexdigest(open(filename, "r").read)
        real_hash = File.open("#{filename}.sha256").read.strip
            raise VerificationFailure, 
                "Error:       #{filename} is corrupt." unless (file_hash == real_hash)
        rm("#{filename}.sha256")
    end
end
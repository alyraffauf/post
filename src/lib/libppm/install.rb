# Copyright (C) Alexandra Chace 2011 <achacega@gmail.com>
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

require(File.join(File.expand_path(File.dirname(__FILE__)), "query.rb"))
require('fileutils')

class Install
    def initialize()
        FileUtils.rm_r("/tmp/post") if File.exists?("/tmp/post")
        FileUtils.mkdir("/tmp/post")
        FileUtils.cd("/tmp/post")
        @queue = []
        @packageQuery = Query.new()
    end

    def installPackage(filename)
        system("tar xf #{filename}")
        FileUtils.rm(filename)
        newFiles = Dir["**/*"].reject {|file| File.directory?(file) }
        newDirectories = Dir["**/*"].reject {|file| File.file?(file) }
        @packageQuery.installPackage(".packageData", ".remove", newFiles)
        for directory in newDirectories
            FileUtils.mkdir_p("#{@packageQuery.getRoot()}/#{directory}")
        end
        for file in newFiles
            FileUtils.install(file, "#{@packageQuery.getRoot()}/#{file}")
            if file.include?("/bin/")
                system("chmod +x #{@packageQuery.getRoot()}/#{file}")
            end
        end
        installScript = File.read(".install")
        eval(installScript)
    end
end

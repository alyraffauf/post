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

class InstallPackage < Plugin
    def do_install(filename)
        extract_xz(filename)
        rm(filename)
        new_files = Dir["**/*"].reject {|file| File.directory?(file) }
        new_directories = Dir["**/*"].reject {|file| File.file?(file) }
        @database.install_package(".packageData", ".remove", new_files)
        new_directories.each { |directory| mkdir_p("#{@root}/#{directory}") }
        for file in new_files
            install(file, "#{@root}/#{file}")
            system("chmod +x #{@root}/#{file}") if file.include?("/bin/")
        end
        install_script = File.read(".install")
        Thread.new { eval(install_script) }.join
    end

    def install_package(package)
        cd("/tmp/post/#{package}")
        sync_data = @database.get_sync_data(package)
        filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        do_install(filename)
    end
end

# Copyright (C) Alexandra Chace 2011-2013 <tchacex@gmail.com>
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

class MismatchedHash < Exception
end

class IncompleteError < Exception
end

require('digest')
require('net/http')

require(File.join(File.dirname(__FILE__), "packagedata.rb"))
require(File.join(File.dirname(__FILE__), "tools.rb"))

class Fetch
    include FileUtils
    def initialize(root = '/')
        @root = root
        rm_r("/tmp/post") if File.exists?("/tmp/post")
        mkdir("/tmp/post")
        cd("/tmp/post")
        @database = PackageDataBase.new(@root)
    end

    def get_file(url, file)
        url = URI.parse(url)
        filename = File.basename(file)
        saved_file = File.open(file, 'w')

        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
            length = response['Content-Length'].to_i
            saved_file_length = 0.0
            response.read_body do |fragment|
                saved_file << fragment
                saved_file_length += fragment.length
                progress = (saved_file_length / length) * 100
            end
        end
        saved_file.close()
    end

    def fetch_package(package, output = true)
        mkdir_p("/tmp/post/#{package}")

        sync_data = @database.get_sync_data(package)
        repo_url = @database.get_url(@database.get_repo(package))

        file = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        url = ("#{repo_url}/#{file}")
        begin
            if url.include?('file://')
                url.sub!("file://", '')
                cp(url, "/tmp/post/#{package}/#{file}")
                cp(url + ".sha256", "/tmp/post/#{package}/#{file}.sha256")
            else
                get_file(url, "/tmp/post/#{package}/#{file}")
                get_file(url + ".sha256", "/tmp/post/#{package}/#{file}.sha256")
            end
        rescue
            raise IncompleteError, "Error:      '#{url}' does not exist."
        end
            
    end

    def do_install(filename)
        
        extract(filename)
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
        eval(install_script)
    end

    def install_package(package)
        cd("/tmp/post/#{package}")
        sync_data = @database.get_sync_data(package)
        filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        file_hash = Digest::SHA256.hexdigest(open(filename, "r").read())
        real_hash = File.open("#{filename}.sha256").read().strip()
        unless (file_hash == real_hash)
            raise MismatchedHash, "Error:       #{filename} is corrupt."
        end
        rm("#{filename}.sha256")
        do_install(filename)
    end
end

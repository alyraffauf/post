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

class MismatchedHash < Exception
end

require('digest')

require(File.join(path, "install.rb"))
require(File.join(path, "packagedata.rb"))
require(File.join(path, "tools.rb"))

class Fetch
    def initialize(queue)
        @install_object = Install.new()
        @queue = queue
        @package_data_base = PackageDataBase.new()
    end

    def get_queue()
        @queue
    end

    def get_file(url, file)
        url = URI.parse(url)
        filename = File.basename(file)
        saved_file = File.open(file, 'w')

        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
            length = response['Content-Length'].to_i()
            saved_file_length = 0.0
            response.read_body do |fragment|
                saved_file << fragment
                saved_file_length += fragment.length()
                progress_data = (saved_file_length / length) * 100
                print("\rFetching:    #{filename} [#{progress_data.round()}%]")
            end
        end
        puts("\rFetching:    #{filename} [100.0%]")
        saved_file.close()
    end

    def fetch_package(package)
        FileUtils.mkdir("/tmp/post/#{package}")

        sync_data = @package_data_base.get_sync_data(package)
        channel = @package_data_base.get_channel()

        filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
        url = channel['url'] + filename
        begin
            if file_exists(url)
                get_file(url, "/tmp/post/#{package}/#{filename}")
                get_file(url + ".sha256", "/tmp/post/#{package}/#{filename}.sha256")
                return true
            else
                return false
            end
        rescue SocketError => error
            return false
        end
            
    end

    def install_queue()
        for package in @queue
            FileUtils.cd("/tmp/post/#{package}")
            sync_data = @package_data_base.get_sync_data(package)
            filename = "#{package}-#{sync_data['version']}-#{sync_data['architecture']}.pst"
            file_hash = Digest::SHA256.hexdigest(open(filename,"r").read())
            real_hash = File.open("#{filename}.sha256").read().strip()
            unless (file_hash == real_hash)
                raise MismatchedHash, "Error:       #{filename} is corrupt."
            end
            puts("Installing:  #{package}")
            @install_object.install_package(filename)
        end
    end
end

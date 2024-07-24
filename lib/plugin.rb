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

directory = File.dirname(__FILE__)
path = File.expand_path(directory)
plugin_directory = File.join(path, "plugins")

require('set')
require("fileutils")

class IncompleteError < Exception
end

class Plugin
    attr_accessor :root
	include FileUtils
	def initialize(root = '/', database)
        @root = root
        @database = database
    end
    def get_file(url, file)
        begin
        if url.include?('file://')
            url.sub!("file://", '')
            cp(url, file)
        else
            url = URI.parse(url)
            file_name = File.basename(file)
            saved_file = File.open(file, 'w')
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true if url.scheme == "https"

            http.request_get(url.path) do |response|
                length = response['Content-Length'].to_i
                saved_file_length = 0.0
                response.read_body do |fragment|
                    saved_file << fragment
                    saved_file_length += fragment.length
                    progress = (saved_file_length / length) * 100
                    print("\rFetching:    #{file_name} [#{progress.round}%]")
                end
            end
            saved_file.close()
            print("\r")
            puts("Fetched:     #{file_name} [100%]\n")
        end
        rescue
            raise IncompleteError, "Error:      '#{url}' does not exist."
        end
    end
    def extract_xz(filename)
        ## This is dirty and makes me feel dirty. system() should be avoided.
        system("mv #{filename} #{filename}.xz")
        system("unxz #{filename}.xz")
        system("tar xf #{filename}")
    end
    def cleanup
        rm_r("/tmp/post") if File.exists?("/tmp/post")
        mkdir("/tmp/post")
        cd("/tmp/post")
    end

    def self.plugins
        @plugins ||= []
    end

    def self.inherited(klass)
        @plugins ||= []
        @plugins << klass
    end
end

require(File.join(plugin_directory, "dependency_resolver.rb"))
require(File.join(plugin_directory, "http_fetch_binary.rb"))
require(File.join(plugin_directory, "install_binary.rb"))
require(File.join(plugin_directory, "remove_binary.rb"))
require(File.join(plugin_directory, "verify_sha256.rb"))
require(File.join(plugin_directory, "fetch_source.rb"))
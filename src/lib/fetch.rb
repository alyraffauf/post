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

require(File.join(File.expand_path(File.dirname(__FILE__)), "libppm", "install.rb"))
require(File.join(File.expand_path(File.dirname(__FILE__)), "libppm", "query.rb"))

require('net/http')

class Fetch
    def initialize()
        @installObject = Install.new()
        @queue = []
        @packageQuery = Query.new()
    end

    def getQueue()
        @queue
    end

    def checkConflicts(package)
        conflictStatus = false
        for conflict in @packageQuery.getSyncData(package)['conflicts']
            if @queue.include?(conflict)
                puts("Error:      '#{conflict} conflicts with '#{package}'")
                conflictStatus = true
            end
        end
        return conflictStatus
    end

    def getFile(url, file)
        url = URI.parse(url)
	filename = File.basename(file)
        savedFile = File.open(file, 'w')

        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
            length = response['Content-Length'].to_i()
            savedFileLength = 0.0
            response.read_body do |fragment|
                savedFile << fragment
                savedFileLength += fragment.length()
                progressData = (savedFileLength / length) * 100
                print("\rFetching:    #{filename} [#{progressData.round()}%]")
            end
        end
        puts("\rFetching:    #{filename} [100.0%]")
        savedFile.close()
    end

    def buildQueue(package)
        if (@packageQuery.upgradeAvailable?(package))
            for dependency in @packageQuery.getSyncData(package)['dependencies']
                buildQueue(dependency)
            end
            @queue.push(package) unless @queue.include?(package)
        end
    end

    def fetchPackage(package)
        FileUtils.mkdir("/tmp/post/#{package}")

        syncData = @packageQuery.getSyncData(package)
        channel = @packageQuery.getChannel()

        filename = "#{package}-#{syncData['version']}-#{syncData['architecture']}.pst"
        url = channel['url'] + filename

        getFile(url, "/tmp/post/#{package}/#{filename}")
    end

    def installQueue()
        for package in @queue
            FileUtils.cd("/tmp/post/#{package}")
            syncData = @packageQuery.getSyncData(package)
            filename = "#{package}-#{syncData['version']}-#{syncData['architecture']}.pst"
            puts("Installing:  #{package}")
            @installObject.installPackage(filename)
        end
    end
end

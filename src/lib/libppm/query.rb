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

require('yaml')
require('open-uri')
require('fileutils')

class Query
    def initialize()
        @root = '/'
        @databaseLocation = "#{@root}/var/lib/post/"
        @installDatabase = File.join(@databaseLocation, "installed")
        @syncDatabase = File.join(@databaseLocation, "available")
    end

    def getRoot()
        return @root
    end

    def getData(package)
        if isInstalled?(package)
            packageData = File.join(@installDatabase, package, 'packageData')
            data = YAML::load_file(packageData)
            data['conflicts'] = [] if data['conflicts'] == nil
            data['dependencies'] = [] if data['dependencies'] == nil
            data['version'] = data['version'].to_s()
        else
            data = {}
            data['version'] = "0"
        end
        return data
    end

    def getSyncData(package)
        if isAvailable?(package)
	        packageData = File.join(@syncDatabase, package)
            data = YAML::load_file(packageData)
            data['conflicts'] = [] if data['conflicts'] == nil
            data['dependencies'] = [] if data['dependencies'] == nil
            data['version'] = data['version'].to_s()
        else
            data = {}
            data['version'] = "0"
	    end
        return data
    end

    def getFiles(package)
        file = File.join(@installDatabase, package, 'files')
        return IO.readlines(file)
    end

    def getRemoveScript(package)
        removeScript = File.join(@installDatabase, package, 'remove')
        return File.read(removeScript)
    end

    def installPackage(packageData, removeFile, installedFiles)
        data = YAML::load_file(packageData)

        dirName = File.join(@installDatabase, data['name'])
        fileName = File.join(dirName, 'files')
        packageDataName = File.join(dirName, 'packageData')
        removeFileName = File.join(dirName, 'remove')

        FileUtils.mkdir_p(dirName)
        FileUtils.install(packageData, packageDataName)
        FileUtils.install(removeFile, removeFileName)

        file = open(fileName, 'w')
        file.puts(installedFiles)
    end

    def removePackage(package)
        dirName = File.join(@installDatabase, package)
        FileUtils.rm_r(dirName)
    end

    def getAvailablePackages()
        return Dir["#{@syncDatabase}/*"].map() { |package| File.basename(package) }
    end

    def getInstalledPackages()
        return Dir["#{@installDatabase}/*"].map() { |package| File.basename(package) }
    end

    def isInstalled?(package)
        return true if getInstalledPackages.include?(package)
    end

    def isAvailable?(package)
        return true if getAvailablePackages.include?(package)
    end

    def upgradeAvailable?(package)
        return true if (isAvailable?(package)) and
                (getSyncData(package)['version'] > getData(package)['version'])
    end

    def getChannel()
        return YAML::load_file("/etc/post/channel")
    end

    def updateDatabase()
        FileUtils.rm_r("/tmp/post") if (File.exists?("/tmp/post"))
        FileUtils.rm_r("/var/lib/post/available") if (File.exists?("/var/lib/post/available"))

        FileUtils.mkdir_p("/tmp/post")
        FileUtils.cd("/tmp/post")

        sourceUrl = getChannel()['url'] + '/info.tar'
        File.open('info.tar', 'w') do |file|
            file.puts(open(sourceUrl).read())
        end
        system("tar xf info.tar")
        FileUtils.cp_r('info', '/var/lib/post/available')
    end
end


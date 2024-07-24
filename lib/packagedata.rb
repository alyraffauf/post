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

require('yaml')
require('open-uri')
require('fileutils')
require('rbconfig')
require('zlib')

def runs_on_this?(arch)
    platform = RbConfig::CONFIG['host_cpu']
    if platform == 'x86_64'
        complist = ['i386', 'i486', 'i686', 'x86_64']
    elsif platform == 'i686'
        complist = ['i386', 'i486', 'i686']
    elsif platform == 'i486'
        complist = ['i386', 'i486', 'i686']
    else
        complist = platform
    end
    
    if complist.include?(arch)
        return true
    else
        return false
    end
end

class PackageDataBase
    include FileUtils
    def initialize(root = '/')
        @repos = []
        set_root(root)
    end

    def get_root()
        @root
    end
    
    def set_root(root)
        @root = root
        @database_location = "#{@root}/var/lib/post/"
        @install_database = File.join(@database_location, "installed")
        @sync_database = File.join(@database_location, "available")
        unless File.exist?(@database_location)
            mkdir_p(@install_database)
            mkdir_p(@sync_database)
        end
    end
    
    def get_data(package)
        begin
            package_data = File.join(@install_database, package, 'packageData')
            data = normalise(YAML::load_file(package_data))
        rescue
            data = {}
            data['version'] = "0"
        end
        return data
    end

    def normalise(data)
        data['version'] = data['version'].to_s()

        data['conflicts'] = [] if data['conflicts'] == nil
        data['dependencies'] = [] if data['dependencies'] == nil
        data['version'] = "0" if data['version'].empty?
        return data
    end

    def get_repos()
        list = Dir.entries("/etc/post/repos.d")
        list.delete('.')
        list.delete('..')
        return list
    end
    
    def get_repo(package)
    
        package_repo = ""
        version = "0"

        get_repos.each do |repo|
            data = Dir["#{@sync_database}/#{repo}/*"].map { |pack| File.basename(pack) }
            data.each do |member|
                if member == package
                    package_repo = repo
                    package_data = File.join(@sync_database + "/" + repo, package)
                    data = normalise(YAML::load_file(package_data))
                    unless (runs_on_this?(data['architecture'].to_s))
                        data['version'] = "0"
                    end
                    if version >= data['version']
                        version = data['version']
                        package_repo = repo
                    end
                
                end
            end
        end
        return package_repo
    end

    def get_sync_data(package)
        repo = File.join(@sync_database, get_repo(package))
        package_data = File.join(repo, package)
        data = normalise(YAML::load_file(package_data))
        
        unless (runs_on_this?(data['architecture'].to_s))
            data['version'] = "0"
        end
        return data
    end

    def get_files(package)
        file = File.join(@install_database, package, 'files')
        file_list = []
        IO.readlines(file).each do |entry|
            file_list.push(entry)
        end
        return file_list
    end

    def get_remove_script(package)
        remove_script = File.join(@install_database, package, 'remove')
        File.read(remove_script)
    end

    def install_package(package_data, remove_file, installed_files)
        data = YAML::load_file(package_data)

        dir_name = File.join(@install_database, data['name'])
        file_name = File.join(dir_name, 'files')
        package_data_name = File.join(dir_name, 'packageData')
        remove_file_name = File.join(dir_name, 'remove')

        mkdir_p(dir_name)
        install(package_data, package_data_name)
        install(remove_file, remove_file_name)

        file = open(file_name, 'w')
        file.puts(installed_files)
    end

    def remove_package(package)
        dir_name = File.join(@install_database, package)
        rm_r(dir_name)
    end

    def get_available_packages()
        list = []
        for repo in get_repos
            list += Dir["#{@sync_database}/#{repo}/*"].map() { |package| File.basename(package) }
            list.delete("repo.yaml")
        end
        return list
    end
    
    def get_group_repo(group)
        group_repo = nil
        for repo in get_repos
            data = YAML::load_file("#{@sync_database}/#{repo}/repo.yaml")
            unless data[group] == nil
                group_repo = repo
            end
        end
        return group_repo
    end
    
    def get_repodata(repo)
        if get_repos.include?(repo)
            return YAML::load_file("#{@sync_database}/#{repo}/repo.yaml")
        else
            return {}
        end
    end

    def get_installed_packages()
        Dir["#{@install_database}/*"].map() { |package| File.basename(package) }
    end

    def installed?(package)
        true if get_installed_packages.include?(package)
    end

    def available?(package)
        true if get_available_packages.include?(package)
    end

    def upgrade?(package)
        true if (available?(package)) and (get_sync_data(package)['version'] > get_data(package)['version'])
    end

    def get_url(repo)
        data = YAML::load_file("/etc/post/repos.d/#{repo}")
        return data['url']
    end

    def update_database()
        rm_r("/tmp/post") if (File.exists?("/tmp/post"))
        rm_r(@sync_database) if (File.exists?(@sync_database))

        mkdir_p("/tmp/post")
        cd("/tmp/post")
        mkdir_p(@sync_database)

        for repo in get_repos

            source_url = get_url(repo) + '/info.tar'
            if source_url.include?("file://")
                source_url.sub!("file://", '')
                cp(source_url, 'info.tar')
            else
                File.open('info.tar', 'w') do |file|
                    file.puts(open(source_url).read)
                end
            end

            system("tar xf info.tar")
            cp_r('info', "#{@sync_database}/#{repo}")
        
            source_url = get_url(repo) + '/repo.yaml'
            if source_url.include?("file://")
                source_url.sub!("file://", '')
                cp(source_url, 'repo.yaml')
            else
                File.open('repo.yaml', 'w') do |file|
                    file.puts(open(source_url).read)
                end
            end
            cp_r('repo.yaml', "#{@sync_database}/#{repo}/repo.yaml")
            rm('repo.yaml')
            rm('info.tar')
            rm_r('info')
        end
    end
end


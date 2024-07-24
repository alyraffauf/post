#!/usr/bin/ruby
# Copyright (C) Alexandra Chace 2011-2015 <achace@student.gsu.edu>

# Scribe is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Scribe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Scribe.  If not, see <http://www.gnu.org/licenses/>.

require("rbconfig")
require("yaml")
require("optparse")
require("fileutils")
include(FileUtils)

# This is MakePackage, our automatic package building tool.
class MakePackage
    # This gets some information from the user we need.
    def initialize(spec)
        @file = open(spec, 'r')
        @spec = YAML::load(@file)
        puts("Package:      #{@spec['name']}")
        puts("Version:      #{@spec['version']}")
        puts("Description:  #{@spec['description']}")
        print("Are you SURE you want to continue? [y/n] ")
        if gets.include?("y")
            mkdir_p("#{@spec['name']}-build/data")
            cp("packageData", "#{@spec['name']}-build/data/.packageData")
            cp("install", "#{@spec['name']}-build/data/.install")
            cp("remove", "#{@spec['name']}-build/data/.remove")
            @pwd = pwd()
            cd("#{@spec['name']}-build")
            get()
            compile()
            buildpkg()
        else
            puts("#{@spec['name']} not built.")
        end
    end
    # Downloads source code.
    def get()
        puts("Getting Source Code...")
        for source in @spec['source']
            if source.include?("http://") or source.include?("ftp://")
                action = system("wget -c #{source}")
                if action == false
                    puts("Could not download #{source}.")
                    exit(1)
                end
            elsif source.include?("git://")
                action = system("git clone #{source}")
                if action == false
                    puts("Could not download #{source}.")
                    exit(1)
                end
            end
        end
    end
    # Compiles the package.
    def compile()
        puts("Building Software...")
        build = File.read("../build")
        eval(build)
        cd("#{@pwd}/#{@spec['name']}-build/data")
        packageFiles = Dir["**/*"].reject {|file| File.directory?(file) }
        for file in packageFiles
            if file.include?("/bin/") or file.include?("/lib/")
                system("strip #{file}")
            end
        end
    end
    # Makes the package.
    def buildpkg()
        puts("Making Package...")
        packageName = "#{@spec['name']}-#{@spec['version']}-#{RbConfig::CONFIG["build_cpu"]}.pst"
        system("tar cf #{packageName} * .packageData .install .remove")
        system("xz #{packageName}")
        cp(packageName + ".xz", "#{@pwd}/#{packageName}")
        rm("#{packageName}.xz")
    end
end
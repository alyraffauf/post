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
require('yaml')

module BuildTools
	def get_flags
		config = YAML::load_file("/etc/post/config")
		return config['flags']
	end
	def configure
		system("./configure #{get_flags}")
	end
	def make
		system("make DESTDIR=../data/ install")
	end
	def get_spec
		file = open("../packageData", 'r')
		spec = YAML::load(file)
	end
	def extract(filename)
    	system("tar xf #{filename}")
	end
end
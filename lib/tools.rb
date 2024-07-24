# Copyright (C) Alexandra Chace 2011-2012 <ialyraffauf@gmail.com>
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

require('open-uri')
require('net/http')
require('rubygems')
#require('xz')
#require('archive/tar/minitar')
#require('zlib')

#include Archive::Tar

def file_exists(url)
	url = URI.parse(url)
	Net::HTTP.start(url.host, url.port) do |http|
		return http.head(url.request_uri).code == "200"
	end
end

def extract(filename)
    system("tar xf #{filename}")
    #XZ.decompress_file(filename, 'decomp.tar')
    #Minitar.unpack("decomp.tar", '.')
    #FileUtils.rm('decomp.tar')
end

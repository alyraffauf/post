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


class ConflictingEntry < Exception
end

class DepResolver < Plugin
    attr_accessor :queue
    def initialize(root, database)
        super(root, database)
        @queue = []
    end
    def conflict?(package)
        for conflict in @database.get_sync_data(package)['conflicts']
            raise ConflictingEntry,
                "Error: '#{conflict}' conflicts with '#{package}'" if @queue.include?(conflict)
        end
    end
    def build_tree(package)
        group = []
        repo = @database.get_group_repo(package).to_s
        group = @database.get_repodata(repo)[package].to_a
        if (group.to_a.empty?) and (@database.upgrade?(package))
            deps = @database.get_sync_data(package)['dependencies']
            deps.each { |dependency| build_tree(dependency) }
            unless (@queue.include?(package))
                conflict?(package)
                @queue.push(package)
            end
        else
            group.each { |member| build_tree(member) }
        end
    end
end
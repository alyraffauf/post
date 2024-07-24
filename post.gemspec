load('src/lib/post.rb')

time = Time.new
month = time.month
day = time.day
if (time.month < 10)
    month = "0#{month}"
end

if (day < 10)
    day = "0#{day}"
end

date = "#{time.year}-#{month}-#{day}"

Gem::Specification.new do |s|
    s.name        = 'post'
    s.executables << 'post'
    s.executables << 'postdb'
    s.version     = '2.0.4'
    s.date        = date
    s.summary     = "Package manager in pure ruby."
    s.description = "Small, fast package manager in pure Ruby."
    s.authors     = ["Alexandra Chace"]
    s.email       = 'tchacex@gmail.com'
    s.files       = ["lib/post.rb", "lib/fetch.rb", "lib/erase.rb",
            "lib/packagelist.rb", "lib/packagedata.rb",
            "lib/tools.rb"]
    s.homepage    =
        'http://github.com/alyraffauf/Post'
end

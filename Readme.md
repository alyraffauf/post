## License

Post is available under the Lesser General Public license.

## What Is Post?

Post is package manager for unix systems that focuses on clean design, efficiency, and simplicity.

Post is is supported by Rubinius(1.1+), but also works well on Ruby 1.9+.

## Dependencies:
	lzma(liblzma-dev on Ubuntu/Debian)

## Building Post Yourself

        git clone git://github.com/alyraffauf/Post.git
        cd Post
        gem build post.gemspec
        gem install post-2.0.4.gem

## Installing from Rubygems:

	gem install post -v 2.0.4

## Configuring The Test Repository

        sudo cp cfg/tchace /etc/post/repos.d/tchace

## Testing The Installation

        sudo post -h
        sudo post -s
        sudo post -i zile

If you have questions, email me at <tchacex@gmail.com>.

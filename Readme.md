## License

Post is available under the Lesser General Public license.

## What Is Post?

Post is package manager for unix systems that focuses on clean design, efficiency, and simplicity.

Post is is supported by Rubinius(1.1+), but also works well on Ruby 1.9+.

## Installing Post

        git clone git://github.com/alyraffauf/Post.git
        git checkout 1.0
        cd Post
        sudo rbx build.rb # For Rubinius
        sudo ruby1.9 build.rb # For Ruby 1.9

## Configuring The Test Repository

        sudo cp src/etc/post/channel /etc/post/channel

## Testing The Installation

        sudo post -h
        sudo post -s
        sudo post -i zile

If you have questions, email me at <tchacex@gmail.com>.

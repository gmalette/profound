# Profound

Create wallpapers like those on [theprofoundprogrammer](http://theprofoundprogrammer.com) even if you're aweful at Photoshop. It's based on *ImageMagick*.

## Installation

    $ brew install imagemagick
    $ gem install profound

## Usage

    $ profound path/to/source.jpg "Complain about something" path/to/destination.jpg

The source can also be a few keywords to help find an image. You also specify the size of the image to find

    $ profound --search-size=2880x1800 "road at night" "I hate cars" ~/profound-cars.jpg

The source can also be omitted altogether. In that case, `profound` will search for images.

    $ profound "Something ironic", ~/profound-ironic.jpg

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

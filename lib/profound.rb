require 'rmagick'
require 'google-search'
require 'net/http'
require 'uri'
require 'tempfile'

require 'profound/version'
require 'profound/filters/toy_camera'


module Profound
  class Theme
    def initialize(theme)
      @theme = theme
    end

    def color
      @theme == :dark ? 'black' : 'white'
    end

    def inverse_color
      @theme == :dark ? 'white' : 'black'
    end
  end

  class Input
    class EmptyQueryResult < RuntimeError; end

    Keywords = [
      'forest', 'jungle', 'prairie', 'fields', 'flowers' 'beach', 'city', 'skyline',
      'trail', 'lake', 'sky', 'sunrise', 'dawn', 'dusk', 'scenery', 'island', 'kitten', 'horse', 'puppy'
    ]

    Qualifiers = [
      'beautiful', 'gorgeous', 'magnificient', 'superb', nil
    ]

    def initialize(source, options = {})
      @source = source || [Qualifiers.sample, Keywords.sample].join(" ")
      @options = options
    end

    def path
      File.exists?(@source) ? @source : download
    end

    def download
      image = search

      response = Net::HTTP.get_response(URI.parse(image.uri))

      tmp = Tempfile.new("profound")
      tmp.write(response.body)
      tmp.rewind
      tmp.path
    end

    def search
      query = [@source, [@options[:width], @options[:height]].compact.join("x")].join(" ")
      image = Google::Search::Image.new(:query => query, :image_size => :huge, :file_type => :jpg).select{ |img|
        (@options[:width].nil? || @options[:width].to_s == img.width.to_s) &&
        (@options[:height].nil? || @options[:height].to_s == img.height.to_s)
      }.sample

      raise EmptyQueryResult, "Could not find images matching #{query}" unless image

      image
    end
  end

  class Image
    include Profound::Filters::ToyCamera

    def initialize(source, caption, options, destination)
      source        = Input.new(source, options).path

      @source       = Magick::ImageList.new(source).first
      @target       = Magick::ImageList.new
      @destination  = destination
      @caption      = caption
      @options      = options
      @theme        = Theme.new(options[:theme])
      @font_family  = options[:font_family] || 'Helvetica'
    end

    def convert
      shadow
      text
      filters
      save
    end

    def text
      @source = @source.composite(_text, Magick::CenterGravity, Magick::OverCompositeOp)
    end

    def filters
      case @options[:filter]
      when :toycamera
        toy_camera
      end
    end

    def shadow
      image = _text(40)
      shadow = image.shadow(0, 0, 30).colorize(1, 1, 1, 0, @theme.inverse_color)
      @source = @source.composite(shadow, Magick::CenterGravity, 20, 0, Magick::OverCompositeOp)
    end

    def save
      @source.write(@destination)
    end

    def _text(stroke_width = 0)
      image = Magick::Image.new(@source.columns, 100) {
        self.background_color = 'none'
      }
      text = Magick::Draw.new

      color = @theme.color
      font_family = @font_family

      text.annotate(image, 0, 0, 0, 0, @caption) {
        self.fill         = color
        self.font_family  = font_family
        self.pointsize    = 80
        self.stroke_width = stroke_width
        self.stroke       = color
        self.gravity      = Magick::CenterGravity
      }

      image
    rescue Magick::ImageMagickError => e
      puts "An error has occured. Try installing ghostscript"
      exit!
    end
  end
end

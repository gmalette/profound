require "profound/version"
require 'rmagick'

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

  class Image
    def initialize(source, caption, options, destination)
      @source       = Magick::ImageList.new(source).first
      @target       = Magick::ImageList.new
      @destination  = destination
      @caption      = caption
      @options      = options
      @theme        = Theme.new(options[:theme])
    end

    def convert
      shadow
      text
      save
    end

    def text
      @source = @source.composite(_text, Magick::CenterGravity, Magick::OverCompositeOp)
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
      text.annotate(image, 0, 0, 0, 0, @caption) {
        self.fill         = color
        self.font_family  = 'Arial'
        self.pointsize    = 80
        self.stroke_width = stroke_width
        self.stroke       = color
        self.gravity      = Magick::CenterGravity
      }

      image
    end
  end
end

require "profound/version"
require 'choice'
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
      @image_list   = Magick::ImageList.new(source)
      @source       = @image_list.first
      # @image_list = Magick::ImageList.new
      @target       = Magick::ImageList.new
      @destination  = destination
      @caption      = caption
      @options      = options
      @theme        = Theme.new(options[:theme])
    end

    def convert
      shadow!
      text!
      save!
    end

    def text!
      @source = @source.composite(text, Magick::CenterGravity, Magick::OverCompositeOp)
    end

    def text(color = nil, stroke_width = 0)
      image = Magick::Image.new(@source.columns, 100) {
        self.background_color = 'none'
      }
      text = Magick::Draw.new

      color ||= @theme.color
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

    def shadow!
      image = text(@theme.inverse_color, 40)
      @source = @source.composite(image.shadow(0, 0, 30), Magick::CenterGravity, 20, 0, Magick::OverCompositeOp)
    end

    def save!
      # img = @image_list.flatten_images
      @source.write(@destination)
    end
  end
end

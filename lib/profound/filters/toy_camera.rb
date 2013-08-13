module Profound::Filters
  module ToyCamera
    def toy_camera
      @source = @source.modulate(1.2, 1.2)
    end
  end
end
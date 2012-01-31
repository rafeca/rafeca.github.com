module Jekyll
  module ImageDimensionsFilter
    def image_dimensions(input)      
      # this will only work in mac os x!!!
      h_s = %x[sips -g pixelHeight "#{input}"]
      w_s = %x[sips -g pixelWidth "#{input}"]
      h = h_s[/.*: (.*)/, 1]
      w = w_s[/.*: (.*)/, 1]
      "width='#{w}px' height='#{h}px'"
    end
  end
end

Liquid::Template.register_filter(Jekyll::ImageDimensionsFilter)

module Jekyll
  module ImageDimensionsFilter
    def image_dimensions(input)      
      # this will only work in mac os x!!!
      name="#{input}".strip
      return "" unless File.exists?(name)
      h_s = %x[sips -g pixelHeight "#{name}"]
      w_s = %x[sips -g pixelWidth "#{name}"]
      h = h_s[/.*: (.*)/, 1]
      w = w_s[/.*: (.*)/, 1]
      begin
        h_i = Integer(h)
        w_i = Integer(w)
      rescue Exception => e
        puts "  - bad image, or tool could not calculate size"
        return ""
      end
      "width='#{w}px' height='#{h}px'"
    end
  end
end

Liquid::Template.register_filter(Jekyll::ImageDimensionsFilter)

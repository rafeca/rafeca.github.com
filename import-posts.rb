#!/usr/local/bin/ruby

# Based on a sample from https://gist.github.com/210359

require 'nokogiri'
require 'date'
require 'php_serialize'
require 'yaml'
require 'open-uri'
require 'uri'

def parse_content(content) 
  
  # caption items
  # example:
  # [caption id="attachment_6" align="aligncenter" width="212" caption="Some pencil drawing, then drafting a general layout with wacom and Inkscape."]<a href="http://gatillos.com/yay/wp-content/uploads/2010/03/01-page-b.jpg"><img class="size-medium wp-image-6" title="01 page-b" src="http://gatillos.com/yay/wp-content/uploads/2010/03/01-page-b-212x300.jpg" alt="" width="212" height="300" /></a>[/caption]
  
  # transform all [caption] wp tags into html,  \1 is the caption, \2 is the body
  content = content.gsub( /\[caption [^\]]+ caption=\"([^\"]*)\"\](.*)\[\/caption\]/, '<div class="post-image">\2</div><div class="post-image-caption">\1</div>' ) 

  # TODO strip class tags, change urls?
  # maybe the easiest solution is to just parse the whole content again looking for full URLs

  return content
end

def mkdir_if_not_exists(directory_name)
  Dir.mkdir(directory_name) unless File.exists?(directory_name)
end


doc = Nokogiri::XML( File.open("../../../Downloads/gatillos.wordpress.2012-01-24.xml") )

doc.xpath("//item").each_with_index do |item|

  # common properties of all post types

  comments = item.xpath("wp:comment")
  has_comments = ( comments.length > 0 )
  
  is_private   = ( item.xpath("wp:status").first.content == "private" )

  categories   = item.xpath("category[@domain='category']").collect(&:text).uniq

  post_name    = item.xpath("wp:post_name").first
  if post_name then post_name=post_name.content
  else post_name="no_name"
  end
  
   # other post_types:
   #   attachment  used by webcomic for images to be used in a comic
   #               link is link to comic, wp:attachment_url is link to actual file
   #   page        for pages
   #   nav_menu_item  menus...
   #   webcomic_post post of a webcomic page
   #                 has content and comments, plus categories
   #                 actual image is linked through wp:postmeta, wp:meta_key=webcomic, wp:meta_value
   #                  lists image name for all sizes
  
  post_type = item.xpath("wp:post_type").first.content

  title = item.xpath("title").first.content
  postdate = item.xpath("wp:post_date").first.content
  postdate = DateTime.parse(postdate)
  link     = item.xpath("link").first.content
  content = item.xpath("content:encoded").first.content


  # we'll build the @output in memory, posts are fairly small 
  @output = ""
  filename = ""

  case post_type

  # Regular Blog Entries
  #
  when 'post' then
    filename="#{postdate.strftime '%Y-%m-%d-%H-%M'}-#{post_name}.markdown"
    @output << "---\n"
    @output << "layout: post\n"
    @output << "title: #{title.inspect}\n"
    @output << "permalink: #{link}\n"
    @output << "published: false\n" if is_private
    @output << "categories: [blog]\n"
    # in my blog, I used wordpress categories for what jekyll would call tags, whle jekyll categories
    # would be blog and comic_1, comic_2, for the comics ...', so all posts go to category blog 
    @output << "tags: [#{categories.join(",")}]\n"
    @output << "date: #{postdate}\n"
    @output << "---\n"
    @output << "#{parse_content(content)}\n"
    @output << "[#{comments.length} comments]\n"
  # Webcomic Post Entries
  #
  when 'webcomic_post' then
    #categories   = item.xpath("category[@domain='category']").collect(&:text).uniq
    collection = item.xpath("category[@domain='webcomic_collection']").first['nicename']
    filename="#{postdate.strftime '%Y-%m-%d-%H-%M'}-#{collection}-#{post_name}.markdown"
    meta = item.xpath("wp:postmeta/wp:meta_value[(../wp:meta_key='webcomic')]").first.content
    meta = PHP.unserialize(meta)
    # example of @output of the above:
    # {"files"=>{"full"=>["chap1_01_b.jpg"], "large"=>["chap1_01_b-large.jpg"], "medium"=>["chap1_01_b-medium.jpg"], "small"=>["chap1_01_b-small.jpg"]}, "alternate"=>[], "description"=>[], "transcripts"=>[], "transcribe_toggle"=>"", "paypal"=>{"prints"=>"", "original"=>"", "price_d"=>"0", "price_i"=>"0", "price_o"=>"0", "shipping_d"=>"0", "shipping_i"=>"0", "shipping_o"=>"0"}}
    full_size_jpg = meta['files']['full'][0]
    large_size_jpg = meta['files']['large'][0]
    medium_size_jpg = meta['files']['medium'][0]
    small_size_jpg = meta['files']['small'][0]
    local_filename = "comics/#{collection}/#{full_size_jpg}"
    @output << "---\n"
    @output << "layout: post\n"     # TODO change to webcomic_post?
    @output << "title: #{title.inspect}\n"
    @output << "permalink: #{link}\n"
    @output << "published: false\n" if is_private
    @output << "categories: [comic, #{collection}]\n" # this way we can filter by 'all comics' (category=comic) and by specific comic (category=collection name)
    @output << "tags: [#{categories.join(", ")}]\n"
    @output << "date: #{postdate}\n"
    @output << "---\n"
    @output << "<div class='comic_image'><a href='#{link}'><img src='#{local_filename}'/></a>\n"
    @output << "<div class='comic_text'>#{parse_content(content)}</div>\n"
    @output << "<a href='#{link}'>[#{comments.length} comments] Click to view comments</a>\n"

    # retrieve image
    original_image_url = "http://gatillos.com/yay/wp-content/webcomic/#{collection}/#{URI.escape(full_size_jpg)}"
    puts "  - resource #{local_filename}"

    unless File.exists?(local_filename)
      puts "  - resource not found locally, retrieving from site"
      mkdir_if_not_exists("comics")
      mkdir_if_not_exists("comics/#{collection}")
      open(local_filename, 'wb') do |fout|
        open(original_image_url) do |fin|
          fout.write(fin.read)
        end
      end
    end

  end

  if filename && filename.length > 0
    puts "creating #{filename}"
    File.open( "_posts/" + filename, 'w' ) {|file| file.write(@output)}
  end

  # TODO export comments to disqus?
  # TODO may break with pingbacks... never seen one of those :)

end

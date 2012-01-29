#!/usr/local/bin/ruby

# Based on a sample from https://gist.github.com/210359

require 'nokogiri'
require 'date'
require 'php_serialize'
require 'yaml'
require 'open-uri'
require 'uri'
require 'fileutils'
require 'yaml'

def parse_content(postid, content) 
  
  # caption items
  # example:
  # [caption id="attachment_6" align="aligncenter" width="212" caption="Some pencil drawing, then drafting a general layout with wacom and Inkscape."]<a href="http://gatillos.com/yay/wp-content/uploads/2010/03/01-page-b.jpg"><img class="size-medium wp-image-6" title="01 page-b" src="http://gatillos.com/yay/wp-content/uploads/2010/03/01-page-b-212x300.jpg" alt="" width="212" height="300" /></a>[/caption]
  
  # transform all [caption] wp tags into html,  \1 is the caption, \2 is the body
  content = content.gsub( /\[caption [^\]]+ caption=\"([^\"]*)\"\](.*)\[\/caption\]/, '<div class="post-image">\2</div><div class="post-image-caption">\1</div>' ) 

  # transform img sources to local file
  doc = Nokogiri::HTML( content )
  doc.xpath("//img").each_with_index do |item|
    src = item['src']
    name = File.basename(URI(src).path)
    local = "gfx/posts/#{postid}/#{name}"
    puts "  - uses #{local}"
    retrieve_file(src, local) unless File.exists?(local)
    item['src'] = "#{@config['url_root']}#{@config['baseurl']}/#{local}"
    item['class'] = ''
  end

  # transform <a> urls that go to an image into references to local file
  doc.xpath("//a[ substring(@href, string-length(@href) - 3, 4) = '.jpg' or
                  substring(@href, string-length(@href) - 3, 4) = '.png' or
                  substring(@href, string-length(@href) - 4, 5) = '.jpeg' or
                  substring(@href, string-length(@href) - 3, 4) = '.gif' ]").each_with_index do |item|
    src = item['href']
    name = File.basename(URI(src).path)
    local = "gfx/posts/#{postid}/#{name}"
    puts "  - links to #{src}"
    retrieve_file(src, local) unless File.exists?(local)
    item['href'] = "#{@config['url_root']}#{@config['baseurl']}/#{local}"
  end

  return doc.xpath("//body")
end

def mkdir_if_not_exists(directory_name)
  Dir.mkdir(directory_name) unless File.exists?(directory_name)
end

def retrieve_file(remote_url, local_filename)
  unless File.exists?(local_filename)
    puts "  - resource not found locally, retrieving from site to #{local_filename}"
    dir = File.dirname(local_filename)
    FileUtils.mkdir_p(dir) unless dir==""
    open(local_filename, 'wb') do |fout|
      open(remote_url) do |fin|
        fout.write(fin.read)
      end
    end
  end
end

# read config
File.open( '_config.yml' ) { |file| @config = YAML::load(file) }
puts @config
puts @config['baseurl']

# remove generated files
File.delete('urlmap.txt') if File.exists?('urlmap.txt')
File.delete('htaccess.txt') if File.exists?('htaccess.txt')

doc = Nokogiri::XML( File.open("../../../Downloads/gatillos.wordpress.2012-01-29.xml") )

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
  postdate = postdate.to_time   # this converts to local time zone
  link     = item.xpath("link").first.content
  content = item.xpath("content:encoded").first.content


  # we'll build the @output in memory, posts are fairly small 
  @output = ""
  filename = ""

  case post_type

  # Regular Blog Entries
  #
  when 'post' then
    @output << "---\n"
    @output << "layout: post\n"
    @output << "title: #{title.inspect}\n"
    #@output << "permalink: #{link}\n"
    @output << "published: false\n" if is_private
    @output << "categories: [blog]\n"
    # in my blog, I used wordpress categories for what jekyll would call tags, whle jekyll categories
    # would be blog and comic_1, comic_2, for the comics ...', so all posts go to category blog 
    @output << "tags: [#{categories.join(",")}]\n"
    @output << "date: #{postdate}\n"
    @output << "---\n"
    @output << "#{parse_content(post_name, content)}\n"
    #@output << "[#{comments.length} comments]\n"
    filename="_posts/blog/#{postdate.strftime '%Y-%m-%d'}-#{post_name}.markdown"
    new_path = "#{postdate.strftime '%Y/%m/%d'}/#{post_name}/"
  # Webcomic Post Entries
  #
  when 'webcomic_post' then
    #categories   = item.xpath("category[@domain='category']").collect(&:text).uniq
    collection = item.xpath("category[@domain='webcomic_collection']").first['nicename']
    # hard-coded adjustments for my comics' names
    if title.inspect.include?('Paul')
	    local_collection = 'paul';
    else
	    local_collection = collection
    end
    meta = item.xpath("wp:postmeta/wp:meta_value[(../wp:meta_key='webcomic')]").first.content
    meta = PHP.unserialize(meta)
    # example of @output of the above:
    # {"files"=>{"full"=>["chap1_01_b.jpg"], "large"=>["chap1_01_b-large.jpg"], "medium"=>["chap1_01_b-medium.jpg"], "small"=>["chap1_01_b-small.jpg"]}, "alternate"=>[], "description"=>[], "transcripts"=>[], "transcribe_toggle"=>"", "paypal"=>{"prints"=>"", "original"=>"", "price_d"=>"0", "price_i"=>"0", "price_o"=>"0", "shipping_d"=>"0", "shipping_i"=>"0", "shipping_o"=>"0"}}
    full_size_jpg = meta['files']['full'][0]
    large_size_jpg = meta['files']['large'][0]
    medium_size_jpg = meta['files']['medium'][0]
    small_size_jpg = meta['files']['small'][0]
    image_filename = "comics/#{local_collection}/#{full_size_jpg}"
    @output << "---\n"
    @output << "layout: webcomic\n"     # TODO change to webcomic_post?
    @output << "title: #{title.inspect}\n"
    #@output << "permalink: #{link}\n"
    @output << "published: false\n" if is_private
    @output << "categories: [comics, #{local_collection}]\n" # this way we can filter by 'all comics' (category=comic) and by specific comic (category=collection name)
    @output << "tags: [#{categories.join(", ")}]\n"
    @output << "date: #{postdate}\n"
    @output << "image: #{@config['baseurl']}/#{image_filename}\n"
    @output << "---\n"
    @output << "#{parse_content(post_name, content)}\n"
    #@output << "[#{comments.length} comments]"

    # retrieve image
    original_image_url = "#{@config['import_location']}/wp-content/webcomic/#{collection}/#{URI.escape(full_size_jpg)}"
    puts "  - uses #{original_image_url}"
    retrieve_file(original_image_url, image_filename)

    filename="_posts/#{local_collection}/#{postdate.strftime '%Y-%m-%d'}-#{post_name}.markdown"
    new_path = "#{postdate.strftime '%Y/%m/%d'}/#{post_name}/"
    puts "#{postdate} --> #{filename} --> #{new_path}"
  end

  if filename && filename.length > 0
    puts "creating new post #{filename}"
    dir = File.dirname(filename) 
    FileUtils.mkdir_p(dir) unless dir==""
    File.open(filename, 'w' ) {|file| file.write(@output)}
    # record the mapping that we just did
    new_link = "#{@config['url_root']}#{@config['baseurl']}/#{new_path}"
    if new_link != link
      File.open("urlmap.txt", 'a' ) {|file| file.write("#{link}, #{new_link}\n")}
    end
    original_path = URI(link).path
    migrated_path = "#{@config['baseurl']}/#{new_path}"
    if migrated_path != original_path
      File.open("htaccess.txt", 'a' ) {|file| file.write("Redirect permanent #{original_path} #{migrated_path}\n")}
    end
  end

  # TODO export comments to disqus?
  # TODO may break with pingbacks... never seen one of those :)

end

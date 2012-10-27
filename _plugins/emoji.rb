# Jekyll Emoji
#
# Chris Kempson (http://chriskempson.com)
# https://github.com/chriskempson/jekyll-emoji
#
# Update:
# Juan de Bravo (http://www.juandebravo.com)
#
# A jekyll plug-in that provides a Liquid filter for emojifying text with
# https://github.com/github/gemoji. See http://www.emoji-cheat-sheet.com for
# a full listing of emoji codes.
#
# Installation:
#
#   - Copy this file to your `_plugins` directory
#
#   - Define the configuration variable emoji in your _config.yml file:
#
#          emoji: gfx/emoji
#
#   - Run the following rake task:
#
#          rake emoji
# 
# Usage: 
#
#   - Apply the filter wherever needed
#
#          {{ content | emojify }}
#   - Add some emoji to your article!
#
#          Hello :wink:

require "gemoji"

module Jekyll
  module EmojiFilter

    def emojify(content)
      if @context.registers[:site].config['emoji']
        content.to_str.gsub(/:([a-z0-9\+\-_]+):/) do |match|
          if Emoji.names.include?($1)
            "<span class='emoji emoji_#{$1}'>#{$1} emoji</span>"
          else
            match
          end
        end
      else
        content
      end
    end # emojify

  end # EmojiFilter
end # Jekyll

Liquid::Template.register_filter(Jekyll::EmojiFilter)
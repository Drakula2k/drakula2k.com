module Jekyll
  class Spoiler < Liquid::Block
    def initialize (tag_name, markup, tokens)
      super
      @summary = markup.strip
    end

    def render(context)
      output = '<details>'
      output << "<summary>#{@summary.empty? ? 'Open' : @summary}</summary>"
      output << super
      output << '</details>'
    end
  end
end

Liquid::Template.register_tag('spoiler', Jekyll::Spoiler)

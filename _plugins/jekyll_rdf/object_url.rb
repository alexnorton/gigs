module JekyllRDF
  class ObjectUrl < Liquid::Tag
    def initialize(tag_name, object, tokens)
      super
      @object = object
    end

    def render(context)
      # @object["uri"].downcase.strip.gsub(/([^\w-]+)/, "-")
      @object
    end

    def self.convert(uri)
      uri.downcase.strip.gsub(/([^\w-]+)/, "-")
    end
  end
end

Liquid::Template.register_tag("object_url", JekyllRDF::ObjectUrl)

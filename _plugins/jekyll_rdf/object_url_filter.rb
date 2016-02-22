module JekyllRDF
  module ObjectUrlFilter
    # def initialize(tag_name, object, tokens)
    #   super
    #   @object = object
    # end
    #
    # def render(context)
    #   # @object["uri"].downcase.strip.gsub(/([^\w-]+)/, "-")
    #   @object
    # end
    #


    def object_url(uri)
      JekyllRDF::ObjectUrlGenerator.generate(uri)
    end
  end
end

Liquid::Template.register_filter(JekyllRDF::ObjectUrlFilter)

module JekyllRDF
  class ObjectUrlGenerator
    def self.generate(uri)
      uri.downcase.strip.gsub(/([^\w-]+)/, "-") + ".html"
    end
  end
end

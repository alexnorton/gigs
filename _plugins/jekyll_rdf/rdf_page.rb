require "rdf"
require "linkeddata"
require "json"
require "uri"

module JekyllRDF
  class RDFPage < Jekyll::Page
    def initialize(site, graph, layout, subject)
      @site = site
      @base = site.source
      @name = JekyllRDF::ObjectUrlGenerator.generate(subject.to_s)

      process(@name)
      read_yaml(File.join(site.source, "_layouts"), layout.name)

      layout.data["rdf"]["queries"].each do |key, query_template|
        query = Liquid::Template.parse(query_template).render "subject" => subject.to_s
        solutions = SPARQL.execute(query, graph)
        data[key] = solutions.map(&:to_hash)
        # data["hello"] = "hey"
        # binding.pry
      end

    end
  end
end

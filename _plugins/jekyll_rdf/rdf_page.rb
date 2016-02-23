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
        if query_template.is_a? Array
          array = true
          query_template = query_template.first
        end

        query = Liquid::Template.parse(query_template).render "subject" => subject.to_s
        solutions = SPARQL.execute(query, graph)
        solution_hashes = solutions.map(&:to_hash)
        # binding.pry
        data[key] = array ? solution_hashes : solution_hashes.first
      end
    end
  end
end

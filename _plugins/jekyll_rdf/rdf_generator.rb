require "rdf"
require "linkeddata"
require "json"
require "uri"
require "pry"

module JekyllRDF
  class RDFGenerator < Jekyll::Generator

    def generate(site)
      graph = RDF::Graph.new

      Dir["_graph/*"].each do |file|
        graph << RDF::Graph.load(file)
      end

      rdf_layouts = site.layouts.select { |_, v| v.data["rdf"] }

      rdf_layouts.each do |name, layout|
        query = SPARQL.parse(layout.data["rdf"]["subject"])
        query.execute(graph).each do |solution|
          site.pages << RDFPage.new(site, graph, layout, solution.subject)
        end
      end

      # binding.pry

      # puts site.layouts.to_json


      # Dir["_templates/*"].each do |template|
      #   read_yaml(template)
      # end

      #
      # site.data["graph"] = graph.statements.group_by(&:subject).map do |subject, statements|
      #   {
      #     "uri"        => subject.to_s,
      #     "properties" => Hash[statements.map do |statement|
      #       [statement.predicate.to_s, statement.object.to_s]
      #     end]
      #   }
      # end

      # site.pages << SubjectsPage.new(site, site.source, graph)

      # graph.each_subject do |subject|
      #   site.pages << ObjectPage.new(site, site.source, graph, subject)
      # end
    end
  end
end

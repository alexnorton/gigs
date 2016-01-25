require "rdf"
require "linkeddata"
require "json"
require "uri"

module JekyllRDF
  class RDFGenerator < Jekyll::Generator
    # safe true

    def generate(site)
      graph = RDF::Graph.new

      Dir["_graph/*"].each do |file|
        graph << RDF::Graph.load(file)
      end

      site.data["graph"] = graph.statements.group_by(&:subject).map do |subject, statements|
        {
          "uri"        => subject.to_s,
          "properties" => Hash[statements.map do |statement|
            [statement.predicate.to_s, statement.object.to_s]
          end]
        }
      end

      # site.pages << SubjectsPage.new(site, site.source, graph)

      graph.each_subject do |subject|
        site.pages << ObjectPage.new(site, site.source, graph, subject)
      end
    end
  end
end

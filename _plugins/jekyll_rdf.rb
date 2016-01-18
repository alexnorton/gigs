require "rdf"
require "linkeddata"
require "json"
require "uri"

module JekyllRDF
  class RDFGenerator < Jekyll::Generator
    safe true

    def generate(site)
      graph = RDF::Graph.new

      Dir["_graph/*"].each do |file|
        graph << RDF::Graph.load(file)
      end

      site.pages << SubjectsPage.new(site, site.source, graph)

      graph.each_subject do |subject|
        site.pages << SubjectPage.new(site, site.source, graph, subject)
      end
    end
  end

  class SubjectPage < Jekyll::Page
    attr_reader :graph, :subject

    def initialize(site, base, graph, subject)
      @site = site
      @base = base
      @name = subject.to_s.downcase.strip.gsub(/([^\w-]+)/, "-")
      @graph = graph
      @subject = subject

      process(@name)
      read_yaml(File.join(base, "_layouts"), "term.html")
      set_data graph, subject
    end

    def set_data(graph, subject)
      data["subject"] = subject.to_s
      data["triples"] = triples graph, subject
    end

    def triples(graph, subject)
      triples = RDF::Query.execute(graph) do
        pattern [subject, :predicate, :object]
      end
      triples.map do |triple|
        {
          :predicate => triple.predicate.to_s,
          :object    => triple.object.to_s
        }
      end
    end
  end

  class SubjectsPage < Jekyll::Page
    def initialize(site, base, graph)
      @site = site
      @base = base
      @name = "index.html"
      @graph = graph

      process(@name)
      read_yaml(File.join(base, "_layouts"), "index.html")
      data["subjects"] = graph.subjects.map(&:to_s)
    end
  end
end

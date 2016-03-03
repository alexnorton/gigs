require "rdf"
require "linkeddata"
require "json"
require "uri"

module JekyllRDF
  class SubjectPage < Jekyll::Page
    attr_reader :graph, :subject

    def initialize(site, graph, layout, name, subject)
      @site = site
      @base = site.source
      @name = name
      @graph = graph

      process(@name)
      read_yaml(File.join(site.source, "_layouts"), layout)

      data["subject"] = subject.to_s
    end
  end
end

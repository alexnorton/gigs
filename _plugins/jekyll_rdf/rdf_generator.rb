require "rdf"
require "linkeddata"
require "json"
require "uri"
require "pry"

module JekyllRDF
  class RDFGenerator < Jekyll::Generator
    Liquid::Template.register_filter(Jekyll::Filters)

    def generate(site)
      @site = site
      @graph = RDF::Graph.new

      Dir["_graph/**/*"].select { |path| File.file?(path) }.each do |file|
        @graph << RDF::Graph.load(file)
      end

      subject_pages
      page_queries
    end

    def subject_pages
      @site.config["rdf"]["subjects"].each do |subject_config|
        query = SPARQL.parse subject_config["query"]
        query.execute(@graph).each do |solution|
          subject = solution.subject

          solution_hash = Hash[
            solution.to_h.map{ |k, v| [k.to_s, v.to_s] }
          ]

          name = Liquid::Template.parse(
            subject_config["url"]
          ).render(solution_hash)

          @site.pages << SubjectPage.new(
            @site, @graph, subject_config["layout"], name, subject
          )
        end
      end
    end

    def page_queries
      @site.pages.select { |page| page.data["rdf"] }.each do |page|
        page.data["rdf"]["queries"].each do |key, query_template|
          if query_template.is_a? Array
            array = true
            query_template = query_template.first
          end

          if page.data["subject"]
            query = Liquid::Template.parse(query_template).render(
              "subject" => page.data["subject"]
            )
          else
            query = query_template
          end

          solutions = SPARQL.execute(query, @graph)

          solution_hashes = solutions.map do |solution|
            Hash[solution.to_h.map{ |k, v| [k.to_s, v.to_s] }]
          end

          page.data[key] = array ? solution_hashes : solution_hashes.first
        end
      end
    end
  end
end

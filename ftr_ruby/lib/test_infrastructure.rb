module FtrRuby
  class TestInfra
    attr_accessor :test_protocol, :test_host, :basepath

    def initialize(test_host:, basepath:, test_protocol:)
      @test_host = test_host
      @test_protocol = test_protocol
      @basepath = basepath
    end

    # there is a need to map between a test and its registered Metric in FS.  This will return the label for the test
    # in principle, we cojuld return a more complex object, but all I need now is the label
    def get_tests_metrics(tests:)
      labels = {}
      landingpages = {}
      tests.each do |testid|
        warn "getting dcat for #{testid}    #{test_protocol}://#{test_host}/#{basepath}/#{testid}"
        dcat = RestClient::Request.execute({
                                             method: :get,
                                             url: "#{test_protocol}://#{test_host}/#{basepath}/#{testid}",
                                             headers: { "Accept" => "application/json" }
                                           }).body
        parseddcat = JSON.parse(dcat)
        # this next line should probably be done with SPARQL
        # # TODO TODO TODO
        jpath = JsonPath.new('[0]["http://semanticscience.org/resource/SIO_000233"][0]["@id"]') # is implementation of
        metricurl = jpath.on(parseddcat).first

        begin
          g = RDF::Graph.load(metricurl, format: :turtle)
        rescue StandardError => e
          warn "DCAT Metric loading failed #{e.inspect}"
          g = RDF::Graph.new
        end

        title = g.query([nil, RDF::Vocab::DC.title, nil])&.first&.object&.to_s
        lp = g.query([nil, RDF::Vocab::DCAT.landingPage, nil])&.first&.object&.to_s

        labels[testid] = if title != ""
                           title
                         else
                           "Metric label not available"
                         end
        landingpages[testid] = if lp != ""
                                 lp
                               else
                                 ""
                               end
      end
      [labels, landingpages]
    end
  end
end

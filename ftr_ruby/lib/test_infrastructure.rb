require "jsonpath"

module FtrRuby
  class TestInfra
    attr_accessor :test_protocol, :test_host, :basepath

    def initialize(test_host:, basepath:, test_protocol:)
      @test_host = test_host
      @test_protocol = test_protocol
      @basepath = basepath
    end

    # there is a need to map between a test and its registered Metric in FS.
    # This will return the label for the test
    # in principle, we cojuld return a more complex object,
    # but all I need now is the label
    def get_tests_metrics(tests:)
      threads = tests.map { |testid| Thread.new(testid) { |tid| fetch_metric(tid) } }

      labels = {}
      landingpages = {}
      threads.each do |t|
        tid, label, lpage = t.value
        labels[tid] = label
        landingpages[tid] = lpage
      end
      [labels, landingpages]
    end

    private

    def fetch_metric(testid)
      metricurl = fetch_metric_url(testid)
      g = load_metric_graph(metricurl)
      title, lp = query_metric_graph(g)
      label = title.to_s != "" ? title : "Metric label not available"
      [testid, label, lp.to_s]
    end

    def fetch_metric_url(testid)
      warn "getting dcat for #{testid}    #{test_protocol}://#{test_host}/#{basepath}/#{testid}"
      dcat = RestClient::Request.execute({
                                           method: :get,
                                           url: "#{test_protocol}://#{test_host}/#{basepath}/#{testid}",
                                           headers: { "Accept" => "application/json" }
                                         }).body
      parseddcat = JSON.parse(dcat)
      # TODO: this should probably be done with SPARQL
      jpath = JsonPath.new('[0]["http://semanticscience.org/resource/SIO_000233"][0]["@id"]') # is implementation of
      jpath.on(parseddcat).first
    end

    def load_metric_graph(metricurl)
      RDF::Graph.load(metricurl, format: :turtle)
    rescue StandardError => e
      warn "DCAT Metric loading failed #{e.inspect}"
      RDF::Graph.new
    end

    def query_metric_graph(graph)
      title = graph.query([nil, RDF::Vocab::DC.title, nil])&.first&.object&.to_s
      lp = graph.query([nil, RDF::Vocab::DCAT.landingPage, nil])&.first&.object&.to_s
      [title, lp]
    end
  end
end

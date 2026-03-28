# frozen_string_literal: true

require_relative "./spec_helper"

RSpec.describe FtrRuby::DCAT_Record do
  let(:minimal_meta) do
    {
      testid: "ftr-test-001",
      testname: "Test Persistent Identifier",
      description: "Checks if the resource has a persistent identifier.",
      creator: "https://orcid.org/0000-0002-1825-0097",
      metric: "https://w3id.org/ftr/metric/F1-01M",
      protocol: "https",
      host: "tests.ostrails.eu",
      basePath: "api"
    }
  end

  subject(:record) { described_class.new(meta: minimal_meta) }

  describe "#initialize" do
    it "sets required attributes" do
      expect(record.testid).to eq("ftr-test-001")
      expect(record.testname).to eq("Test Persistent Identifier")
      expect(record.description).to eq("Checks if the resource has a persistent identifier.")
    end

    it "builds correct URLs" do
      expect(record.identifier).to start_with("https://tests.ostrails.eu/api/")
      expect(record.end_url).to include("/assess/test/")
      expect(record.end_desc).to end_with("/api")
    end

    it "applies sensible defaults" do
      expect(record.dctype).to eq("http://edamontology.org/operation_2428")
      expect(record.supportedby).to include("https://tools.ostrails.eu/champion")
      expect(record.isapplicablefor).to include("https://schema.org/Dataset")
    end
  end

  describe "#get_dcat" do
    let(:graph) { record.get_dcat }

    it "returns an RDF::Graph" do
      expect(graph).to be_a(RDF::Graph)
    end

    it "contains the test as dcat:DataService and ftr:Test" do
      me = RDF::URI(record.identifier)
      expect(graph).to have_statement(RDF::Statement.new(me, RDF.type, RDF::Vocab::DCAT.DataService))
      expect(graph).to have_statement(RDF::Statement.new(me, RDF.type, RDF::Vocabulary.new("https://w3id.org/ftr#").Test))
    end

    it "includes basic metadata" do
      expect(graph.dump(:turtle)).to include(record.testname)
      expect(graph.dump(:turtle)).to include(record.description)
    end

    it "includes the metric relationship" do
      expect(graph.dump(:turtle)).to include(minimal_meta[:metric])
    end
  end
end

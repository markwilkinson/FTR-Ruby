# frozen_string_literal: true

require "spec_helper"

RSpec.describe FtrRuby::Output do
  let(:meta) do
    {
      testname: "Test Persistent Identifier",
      description: "Checks persistent identifier presence.",
      testversion: "1.0.0",
      metric: "https://w3id.org/ftr/metric/F1-01M",
      protocol: "https",
      host: "tests.ostrails.eu",
      basePath: "api",
      testid: "ftr-test-001"
    }
  end

  let(:tested_guid) { "https://doi.org/10.5281/zenodo.12345678" }

  subject(:output) { described_class.new(testedGUID: tested_guid, meta: meta) }

  describe "#initialize" do
    it "sets uniqueid as a URN" do
      expect(output.uniqueid).to start_with("urn:fairtestoutput:")
    end

    it "sets softwareid correctly" do
      expect(output.softwareid).to include("https://tests.ostrails.eu/api/ftr-test-001")
    end

    it "defaults score to indeterminate" do
      expect(output.score).to eq("indeterminate")
    end
  end

  describe "#createEvaluationResponse" do
    let(:jsonld) { output.createEvaluationResponse }

    it "returns a JSON-LD string" do
      expect(jsonld).to be_a(String)
      expect(jsonld).to include("@context")
      expect(jsonld).to include("TestResult")
    end

    it "includes the tested GUID" do
      expect(jsonld).to include(tested_guid)
    end

    it "includes the test name in the output" do
      expect(jsonld).to include(meta[:testname])
    end

    context "when score is pass" do
      before { output.score = "pass" }

      it "does not add guidance suggestions" do
        json = JSON.parse(jsonld)
        # This is a rough check — adjust based on your exact JSON-LD structure
        expect(json.to_s).not_to include("suggestion")
      end
    end

    context "when score is not pass" do
      before do
        output.score = "fail"
        output.guidance = [["https://fix.example.org", "Add a PID"]]
      end

      it "includes guidance suggestions" do
        expect(output.createEvaluationResponse).to include("GuidanceContext")
      end
    end
  end

  describe ".clear_comments" do
    it "clears the comments class variable" do
      FtrRuby::Output.clear_comments
      expect(FtrRuby::Output.comments).to eq([])
    end
  end
end

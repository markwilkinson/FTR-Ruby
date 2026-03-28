# frozen_string_literal: true

require_relative "ftr_ruby/version"
require "rest-client"
require "json"
require "sparql"
require "sparql/client"
require "linkeddata"
require "safe_yaml"
require "rdf/nquads"
require "cgi"
require "securerandom"
require "rdf/vocab"
require "triple_easy" # provides "triplify" top-level function

# lib/ftr_ruby.rb

require "dcat_metadata"
require "output"
require "fdp_index"
require "openapi"
require "registertest"
require "test_infrastructure"

module FtrRuby
  class Error < StandardError; end
  # Your code goes here...
end

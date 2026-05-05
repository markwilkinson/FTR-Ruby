module FtrRuby
  # Generates a valid OpenAPI 3.0 YAML document describing a single FAIR test endpoint.
  #
  # The document is built from metadata supplied by the test author (title, description,
  # contact info, etc.) and is served as a machine-readable API specification that client
  # UIs fetch to dynamically build submission forms.
  #
  # Key concern: author-supplied text (especially +description+) may contain arbitrary
  # Markdown, including blank lines and heading markers (##).  YAML block scalars require
  # every continuation line to be indented at least as deeply as the first content line;
  # raw multi-line strings break this rule.  All free-text fields are therefore passed
  # through +yaml_block_indent+ before interpolation.
  class OpenAPI
    attr_accessor :title, :metric, :description, :indicator, :testid,
                  :organization, :org_url, :version, :creator,
                  :responsible_developer, :email, :developer_ORCiD, :protocol,
                  :host, :basePath, :path, :response_description, :schemas, :endpointpath

    # Initialises the OpenAPI document from a metadata hash.
    #
    # @param meta [Hash] keys: :testid, :testname, :testversion, :metric, :description,
    #   :indicators, :organization, :org_url, :responsible_developer, :email, :creator,
    #   :host, :protocol, :basePath, :response_description, :schemas
    def initialize(meta:)
      indics = [meta[:indicators]] unless meta[:indicators].is_a? Array
      @testid = meta[:testid]
      @title = meta[:testname]
      @version = meta[:testversion]
      @metric = meta[:metric]
      @description = meta[:description]
      @indicator = indics.first
      @organization = meta[:organization]
      @org_url = meta[:org_url]
      @responsible_developer = meta[:responsible_developer]
      @email = meta[:email]
      @creator = meta[:creator]
      @host =  meta[:host]
      @host = @host.gsub(%r{/$}, "") # remove trailing slash if present
      @protocol =  meta[:protocol].gsub(%r{[:/]}, "")
      @basePath =  meta[:basePath].gsub(%r{[:/]}, "")
      @basePath = "/#{basePath}" unless basePath[0] == "/" # must start with a slash
      # @path = meta[:path]
      @response_description = meta[:response_description]
      @schemas = meta[:schemas]
      @endpointpath = "assess/test"
      # @end_url = "#{protocol}://#{host}#{basePath}/#{endpointpath}/#{testid}" # basepath starts with /
    end

    # Returns the complete OpenAPI 3.0 YAML document as a String.
    #
    # Free-text fields that may contain Markdown (description, response_description) are
    # pre-processed with +yaml_block_indent+ so that embedded newlines do not escape the
    # YAML block scalar — see that method for details.
    def get_api
      safe_desc = yaml_block_indent(description, 4)
      safe_resp = yaml_block_indent(response_description, 12)
      <<~"EOF_EOF"

        openapi: 3.0.0
        info:
          version: "#{version}"
          title: "#{title}"
          x-tests_metric: "#{metric}"
          description: >-
            #{safe_desc}
          x-applies_to_principle: "#{indicator}"
          contact:
            x-organization: "#{organization}"
            url: "#{org_url}"
            name: "#{responsible_developer}"
            x-role: responsible developer
            email: "#{email}"
            x-id: "#{creator}"
        paths:
          "/#{testid}":
            post:
              requestBody:
                content:
                  application/json:
                    schema:
                      $ref: "#/components/schemas/schemas"
                required: true
              responses:
                "200":
                  description:  >-
                    #{safe_resp}
        servers:
          - url: "#{protocol}://#{host}#{basePath}/#{endpointpath}"
        components:
          schemas:
            schemas:
              required:
                - resource_identifier
              properties:
                resource_identifier:
                  type: string
                  description: the GUID being tested

      EOF_EOF
    end

    private

    # Ensures a multi-line string is safe for use inside a YAML block scalar (>- or |).
    #
    # YAML block scalars determine their indentation level from the first content line.
    # Any subsequent line that is indented less than that level terminates the scalar,
    # which causes parse errors when the text contains blank lines followed by
    # unindented content (a common pattern in Markdown).
    #
    # This method leaves the first line untouched (the heredoc template already places
    # it at the correct column) and prepends +spaces+ spaces to every non-empty
    # continuation line so they remain inside the block scalar.  Blank lines are left
    # blank intentionally — YAML allows empty lines within a block scalar without
    # requiring indentation.
    #
    # @param text   [String]  the raw author-supplied text
    # @param spaces [Integer] number of spaces matching the block scalar's indentation
    #   in the rendered YAML (4 for +description+, 12 for +response_description+)
    # @return [String]
    def yaml_block_indent(text, spaces)
      indent = " " * spaces
      text.split("\n").map.with_index { |line, i| i.zero? || line.empty? ? line : "#{indent}#{line}" }.join("\n")
    end
  end
end

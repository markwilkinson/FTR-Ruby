# FtrRuby

**Ruby library for generating DCAT-compliant metadata and FAIR test outputs following the FTR Vocabulary**

`FtrRuby` provides two main classes for working with FAIR Tests in Ruby:

- `DCAT_Record` – Creates rich DCAT metadata describing a FAIR Test (as a `dcat:DataService` + `ftr:Test`)
- `Output` – Generates a standardized FAIR test execution result (as a `ftr:TestResult` with provenance)

The library uses the **TripleEasy** mixin for easy RDF triple creation and produces graphs compatible with DCAT, DQV, PROV, and the **FAIR Test Registry (FTR)** vocabulary.

---

## Features

- Full DCAT 2 metadata generation for FAIR Tests
- Standardized test result output with provenance (`prov:wasGeneratedBy`, `ftr:TestResult`, etc.)
- Automatic URL construction for test endpoints and identifiers
- Support for contact points, indicators, metrics, themes, and guidance
- JSON-LD output for easy consumption by registries and portals
- Ready for use in FAIR assessment platforms, OSTrails, and EOSC services

---

## Installation

If published as a gem:

```ruby
gem 'ftr_ruby'
```

Or install manually:

```bash
gem install ftr_ruby
```

For local development:

```ruby
require_relative 'lib/ftr_ruby'
```

---

## Usage

### 1. Documenting a FAIR Test (`DCAT_Record`)

```ruby
require 'ftr_ruby'

meta = {
  testid:        "ftr-rda-f1-01m",
  testname:      "FAIR Test F1-01M: Globally Unique Persistent Identifier",
  description:   "This test checks whether a digital object is identified by a globally unique persistent identifier.",
  keywords:      ["FAIR", "F1", "persistent identifier", "PID"],
  creator:       "https://orcid.org/0000-0001-2345-6789",
  indicators:    ["https://w3id.org/ftr/indicator/F1-01M"],
  metric:        "https://w3id.org/ftr/metric/F1-01M",
  license:       "https://creativecommons.org/licenses/by/4.0/",
  testversion:   "1.0.0",
  protocol:      "https",
  host:          "tests.ostrails.eu",
  basePath:      "api",
  individuals:   [{ "name" => "Mark Wilkinson", "email" => "mark.wilkinson@upm.es" }],
  organizations: [{ "name" => "CBGP", "url" => "https://www.cbgp.upm.es" }]
}

record = FtrRuby::DCAT_Record.new(meta: meta)
graph  = record.get_dcat

puts graph.dump(:turtle)
```

### 2. Generating Test Output (`Output`)

```ruby
require 'ftr_ruby'

# Meta comes from the same test definition used for DCAT_Record
meta = { ... }   # same hash as above

output = FtrRuby::Output.new(
  testedGUID: "https://doi.org/10.1234/example.dataset",
  meta: meta
)

# Add test results and comments
output.score = "pass"
output.comments << "The resource has a valid persistent identifier."
output.comments << "Identifier resolves correctly."

# Optional: add guidance for non-passing cases
output.guidance = [
  ["https://example.org/fix-pid", "Register a persistent identifier"],
]

jsonld = output.createEvaluationResponse
puts jsonld
```

---

## Classes

### `FtrRuby::DCAT_Record`

Creates metadata describing the test itself.

- Builds a `dcat:DataService` + `ftr:Test`
- Automatically constructs endpoint URLs, landing pages, and identifiers
- Includes indicators, metrics, themes, license, contact points, etc.

See the class for full list of supported metadata fields.

### `FtrRuby::Output`

Represents the result of executing a FAIR test against a specific resource.

- Produces a `ftr:TestResult` linked to a `ftr:TestExecutionActivity`
- Includes score, summary, log/comments, guidance suggestions, and provenance
- Outputs as JSON-LD (with configurable prefixes)
- Automatically handles assessment target (the tested GUID)

**Key methods:**

- `new(testedGUID:, meta:)` – Initialize with the tested resource and test metadata
- `createEvaluationResponse` – Returns JSON-LD string of the full evaluation graph

---

## Vocabulary & Standards Used

- **DCAT** – Data Catalog Vocabulary (W3C)
- **DQV** – Data Quality Vocabulary
- **PROV** – Provenance Ontology
- **FTR** – FAIR Test Registry vocabulary (`https://w3id.org/ftr#`)
- **SIO** – Semanticscience Integrated Ontology
- **vCard** – Contact points
- Schema.org

---

## Project Structure

```
ftr_ruby/
├── lib/
│   └── ftr_ruby.rb
├── lib/ftr_ruby/
│   ├── dcat_record.rb
│   └── output.rb
└── README.md
```

---

## Contributing

Bug reports and pull requests are welcome on GitHub at:
https://github.com/markwilkinson/ftr_ruby

---

## License

This project is licensed under the [MIT License](LICENSE) (or specify your license).

---

# ACKNOWLEDGEMENTS

Developed in the context of the **OSTrails** project and the **FAIR Champion** initiative.

This project has received funding from the European Union’s Horizon Europe framework programme under grant agreement No. 101130187. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Research Executive Agency. Neither the European Union nor the European Research Executive Agency can be held responsible for them.

---

**Made with ❤️ for the FAIR community**
(import "shared/default_format.jsonnet") + {
  links: (import "shared/base_links.jsonnet") + {
    fatality_notices: { "$ref": "#/definitions/fatality_notices" }
    }
  }

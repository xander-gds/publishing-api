(import "shared/default_format.jsonnet") + {
  definitions: (import "shared/definitions/_whitehall.jsonnet") + {
    details: {
      type: "object",
      additionalProperties: false,
      properties: {
        ordered_corporate_information_pages: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: [
              "content_id",
              "title",
            ],
            properties: {
              content_id: {
                "$ref": "#/definitions/guid",
              },
              title: {
                type: "string",
              },
            },
          },
          description: "A set of links to corporate information pages to display for the worldwide organisation.",
        },
      },
    },
    links: (import "shared/base_links.jsonnet") + {
      corporate_information_pages: "Corporate information pages for this Worldwide Organisation"
    },
  },
}

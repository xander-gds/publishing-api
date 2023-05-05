{
  type: "object",
  required: [
    "formatted_title",
  ],
  additionalProperties: false,
  properties: {
    formatted_title: {
      type: "string",
    },
    crest: {
      type: "string",
      enum: [
        "bis",
        "dbt",
        "eo",
        "hmrc",
        "ho",
        "mod",
        "portcullis",
        "single-identity",
        "so",
        "ukaea",
        "wales",
      ],
    },
    image: {
      "$ref": "#/definitions/image",
    },
  },
  description: "The organisation's logo, including the logo image and formatted name.",
}

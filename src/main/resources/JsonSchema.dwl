%dw 2.0
output application/dw



type ObjectPropertyType = {
    name: String,
    label?: String,
    defaultValue?: String
} & Types

type ArrayType = {
                     "type"?: "array",
                     item: Types
                 }

type ObjectType = {
    "type"? : "object",
    fields: Array<ObjectPropertyType>
}

type SimpleType = {
                      "type": "integer" | "string" | "boolean",
                  }

type Types = SimpleType | ObjectType | ArrayType

type TypeDefinition =
    {
        name: String,
    } & Types

fun typeToJsonSchema(aType: Types) =
    aType  match {
        case s is SimpleType -> {
           "type": s."type" match  {
                case "integer" -> "number"
                else -> $
           }
        }
        case o is ObjectType -> {
            "type": "object",
            properties: {
                (
                    o.fields map ((field, index) -> {
                        (field.name): {
                            (typeToJsonSchema(field)),
                            "description": field.label
                        }
                    })
                )
            },
            required: o.fields
                            filter ((field, index) -> !field.defaultValue?)
                            map ((field, index) -> field.name)
        }
        case a is ArrayType -> {
            "type": "array"
        }
    }


fun toJsonSchema(typeDef: TypeDefinition) =
    {
        (typeDef.name) : typeToJsonSchema(typeDef)
    }
---
toJsonSchema(payload)
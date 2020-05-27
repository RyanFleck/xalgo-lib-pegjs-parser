# Xalgo PEGjs Parser
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FRyanFleck%2Fxalgo-lib-pegjs-parser.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FRyanFleck%2Fxalgo-lib-pegjs-parser?ref=badge_shield)


This is a test parser based on a rule format proposal made on May 21, 2020. It
is currently not compatible with the master Interlibr system.

## PEGjs Grammar:

```js
// Xalgo Testing Revision v5.1 PEG.js Grammar

start
  = _ program:Program _ { return program; }

Program
  = input:(InputSection+)? _ output:(OutputSection+)? _ meta:(MetaSection+)?
  { return { "input": input, "output" : output, "meta" : meta }; }

InputSection
  = "INPUT." _ type:SectionType _ EOL header:DataHeader? data:InputData+
  { return {"type":type, "dataHeader":header, "data":data }; }

OutputSection
  = "OUTPUT." type:SectionType _ EOL header:DataHeader? data:OutputData+
  { return {"type":type, "dataHeader":header, "data":data }; }

MetaSection
  = "METADATA." type:SectionType _ EOL header:DataHeader? data:InputData+
  { return {"type":type, "dataHeader":header, "data":data }; }

SectionType
  = str:String { return str; }

EOL
 = ";" _ Comment? ("\n" _ Comment?)*

DataHeader
  = _ RowNumber? _  elems:Element+ _ "|" _ EOL { return elems; }

InputData
  = _ RowNumber? _ columns:Element+ _ "|" _":"_ context:Imperative _ EOL
  { return { "context":context, "cells":columns }; }

OutputData
  = _ RowNumber? _ rows:Element+ _ "|" _":"_ p:Property a:Assignment?  _ EOL
  { return { "property":p, "property-operations":a, "cells":rows }; }

Property
  = "\""? prop:String "\""? { return prop; }

Assignment
  = _ "=" _ o:Operation { return o; }

Operation
  = op:Operand _ dox:Operator _ nop:Operation &_ &";" { return [op, dox].concat(nop);}
  / op: Operand _ dox:Operator _ op2:Operand &_ &";" { return [op, dox, op2];}

Operator
  = $("*" !"="){return "*";}
  / $("/" !"="){return "/";}
  / $("%" !"="){return "%";}
  / $("+" !"="){return "+";}
  / $("-" !"="){return "-";}

Operand
  = Float
  / Integer
  / String

RowNumber
  = [0-9A-Za-z]+

Imperative
  = "\""? val:String "\""? _ matches:MatchSet?
  {return {"value":val, "possible-matches":matches};}

MatchSet
  = _ "==" matches:Match+ { return matches; }

Match
  = _ "\""? val:String "\""? ","? { return val; }

Element
  = "|" _? content:Content _? &"|" { return content; }

Content
  = _? con:Integer _? &"|" { return con; }
  / _? con:Float _? &"|"   { return con; }
  / _? con:String _? &"|"  { return con; }

String
  = str:[\<\>\{\}@\(\)0-9A-Za-z\-_:\+,\.\/\n\r ]+ {return (str.join("")).trim();}

Integer "integer"
  = _ [0-9]+ { return parseInt(text(), 10); }

Float
  = _ ( [0-9]+ "." [0-9]+ ) { return parseFloat(text(), 10); }

_ "whitespace"
  = [ \t\n\r]* { return; }

Comment
  = _ "//" [^(\n)]+ _ { return; }

```

## Rule:

```
INPUT.CONTEXT ;
|SG|SG| : "jurisdictions" ;
|20180401T00:00|99991230T23:50| : "datestimes" ;
|UTC+08:00| : "timezones" ;

INPUT.SOURCES ;
|is.xalgo|purchaseorder| : "document" ;

INPUT.FILTER ;
|6810| : "parties.buyer.industry" ;//RealEstateActivitiesWithOwnOrLeasedProperty
|80131600| : "item.classification" ;//Saleofpropertyandbuilding
|SGD| : "item.price.currency" ;

INPUT.PARTITION.onehot ;
00|A|B|C|D|E|F| ;
01|Y|N|N|N|N|N| : "buyer_profile"=="sgc1" ;//SingaporeCitizen,1stPrpty
02|N|Y|N|N|N|N| : "buyer_profile"=="sgc2" ;//SingaporeCitizen,2ndPrpty
03|N|N|Y|N|N|N| : "buyer_profile"=="sgcn" ;//SingaporeCitizen,AddtlPrpty
04|N|N|N|Y|N|N| : "buyer_profile"=="spr1" ;//SingaporePerm.Residnt,1stPrpty
05|N|N|N|N|Y|N| : "buyer_profile"=="sprn" ;//SingaporePerm.Residnt,AddtlPrpty
06|N|N|N|N|N|Y| : "buyer_profile"=="sfen" ;//SingaporeForeignEntity,AnyPrpty

OUTPUT.ASSERTION ;
00|A|B|C|D|E|F| ;
01|X|U|U|U|U|U| : "absd_rate"=0.00*price ;
02|U|X|U|U|U|U| : "absd_rate"=0.07*price ;
03|U|U|X|U|U|U| : "absd_rate"=0.10*price ;
04|U|U|U|X|U|U| : "absd_rate"=0.05*price ;
05|U|U|U|U|X|U| : "absd_rate"=0.10*price ;
06|U|U|U|U|U|X| : "absd_rate"=0.15*price ;

OUTPUT.PURPOSE ;
|ruletaker| : "agency.rulemaker_ruletaker_thirdparty" ;
|must| : "agency.must_may_should" ;
|affirmative| : "agency.affirmative_negative_interrogative ;
|do| : "agency.be_do_have" ;
|practical|ethical| : "intent.logical_practical_ethical" ;
|imperative| : "intent.imperative_declarative_empirical" ;
|governance| : "intent.governance_commerce_other" ;

OUTPUT.WEIGHT ;
|70/99| : "weight.obligation" ;
|60/99| : "weight.commitment" ;
|15/99| : "weight.consequence" ;

METADATA.MANAGEMENT ;
|InlandRevenueAuthorityofSingapore|https://www.iras.gov.sg/|d6mgsIlDx5ME| : "rule.entity.id" ;
|AdditionalBuyersStampDutyonPurchaseorTransferofResidentialProperty| : "rule.name.eng" ;
|r6qW2UeKE5hq| : "rule.id" ;
|0.0.2| : "rule.version" ;
|0.5.0| : "rule.runtime" ;
|experimental| : "rule.criticality" ;
|https://www.iras.gov.sg/IRASHome/OtherTaxes/StampDutyforProperty/WorkingoutyourStamp
Duty/BuyingorAcquiringProperty/WhatistheDutythatINeedtoPayasaBuyerorTransfereeof
ResidentialProperty/AdditionalBuyersStampDutyABSD/| : "rule.url" ;
|10.1206/yd5Dw9Im5rJfaGheM84cFq| : "rule.doi" ;
|JosephPotvin|<jpotvin@xalgorithms.org|3ErzHgMpIhYI| : "rule.manager.id" ;
|JosephPotvin|<jpotvin@xalgorithms.org|3ErzHgMpIhYI| : "rule.author.id" ;
|RyanFleck|<ryan.fleck@protonmail.com>|wVXkRXp1palS| : "rule.maintainer.id" ;

METADATA.STANDARDS ;
|ISIC| : "parties.buyer.industry" ;
|https://unstats.un.org/unsd/publication/seriesM/seriesm_4rev4e.pdf| : "data" ;
|UNSPSC|https://www.unspsc.org| : "item:classification";
|UBL|https://docs.oasisopen.org/ubl/osUBL2.2/mod/summary/reports/AllUBL2.2Documents.html|:
"document" ;
```

## Output:

```json
{
    "input": [
        {
            "type": "CONTEXT",
            "dataHeader": null,
            "data": [
                {
                    "context": {
                        "value": "jurisdictions",
                        "possible-matches": null
                    },
                    "cells": ["SG", "SG"]
                },
                {
                    "context": {
                        "value": "datestimes",
                        "possible-matches": null
                    },
                    "cells": ["20180401T00:00", "99991230T23:50"]
                },
                {
                    "context": {
                        "value": "timezones",
                        "possible-matches": null
                    },
                    "cells": ["UTC+08:00"]
                }
            ]
        },
        {
            "type": "SOURCES",
            "dataHeader": null,
            "data": [
                {
                    "context": {
                        "value": "document",
                        "possible-matches": null
                    },
                    "cells": ["is.xalgo", "purchaseorder"]
                }
            ]
        },
        {
            "type": "FILTER",
            "dataHeader": null,
            "data": [
                {
                    "context": {
                        "value": "parties.buyer.industry",
                        "possible-matches": null
                    },
                    "cells": [6810]
                },
                {
                    "context": {
                        "value": "item.classification",
                        "possible-matches": null
                    },
                    "cells": [80131600]
                },
                {
                    "context": {
                        "value": "item.price.currency",
                        "possible-matches": null
                    },
                    "cells": ["SGD"]
                }
            ]
        },
        {
            "type": "PARTITION.onehot",
            "dataHeader": ["A", "B", "C", "D", "E", "F"],
            "data": [
                {
                    "context": {
                        "value": "buyer_profile",
                        "possible-matches": ["sgc1"]
                    },
                    "cells": ["Y", "N", "N", "N", "N", "N"]
                },
                {
                    "context": {
                        "value": "buyer_profile",
                        "possible-matches": ["sgc2"]
                    },
                    "cells": ["N", "Y", "N", "N", "N", "N"]
                },
                {
                    "context": {
                        "value": "buyer_profile",
                        "possible-matches": ["sgcn"]
                    },
                    "cells": ["N", "N", "Y", "N", "N", "N"]
                },
                {
                    "context": {
                        "value": "buyer_profile",
                        "possible-matches": ["spr1"]
                    },
                    "cells": ["N", "N", "N", "Y", "N", "N"]
                },
                {
                    "context": {
                        "value": "buyer_profile",
                        "possible-matches": ["sprn"]
                    },
                    "cells": ["N", "N", "N", "N", "Y", "N"]
                },
                {
                    "context": {
                        "value": "buyer_profile",
                        "possible-matches": ["sfen"]
                    },
                    "cells": ["N", "N", "N", "N", "N", "Y"]
                }
            ]
        }
    ],
    "output": [
        {
            "type": "ASSERTION",
            "dataHeader": ["A", "B", "C", "D", "E", "F"],
            "data": [
                {
                    "property": "absd_rate",
                    "property-operations": [0, "*", "price"],
                    "cells": ["X", "U", "U", "U", "U", "U"]
                },
                {
                    "property": "absd_rate",
                    "property-operations": [0.07, "*", "price"],
                    "cells": ["U", "X", "U", "U", "U", "U"]
                },
                {
                    "property": "absd_rate",
                    "property-operations": [0.1, "*", "price"],
                    "cells": ["U", "U", "X", "U", "U", "U"]
                },
                {
                    "property": "absd_rate",
                    "property-operations": [0.05, "*", "price"],
                    "cells": ["U", "U", "U", "X", "U", "U"]
                },
                {
                    "property": "absd_rate",
                    "property-operations": [0.1, "*", "price"],
                    "cells": ["U", "U", "U", "U", "X", "U"]
                },
                {
                    "property": "absd_rate",
                    "property-operations": [0.15, "*", "price"],
                    "cells": ["U", "U", "U", "U", "U", "X"]
                }
            ]
        },
        {
            "type": "PURPOSE",
            "dataHeader": null,
            "data": [
                {
                    "property": "agency.rulemaker_ruletaker_thirdparty",
                    "property-operations": null,
                    "cells": ["ruletaker"]
                },
                {
                    "property": "agency.must_may_should",
                    "property-operations": null,
                    "cells": ["must"]
                },
                {
                    "property": "agency.affirmative_negative_interrogative",
                    "property-operations": null,
                    "cells": ["affirmative"]
                },
                {
                    "property": "agency.be_do_have",
                    "property-operations": null,
                    "cells": ["do"]
                },
                {
                    "property": "intent.logical_practical_ethical",
                    "property-operations": null,
                    "cells": ["practical", "ethical"]
                },
                {
                    "property": "intent.imperative_declarative_empirical",
                    "property-operations": null,
                    "cells": ["imperative"]
                },
                {
                    "property": "intent.governance_commerce_other",
                    "property-operations": null,
                    "cells": ["governance"]
                }
            ]
        },
        {
            "type": "WEIGHT",
            "dataHeader": null,
            "data": [
                {
                    "property": "weight.obligation",
                    "property-operations": null,
                    "cells": ["70/99"]
                },
                {
                    "property": "weight.commitment",
                    "property-operations": null,
                    "cells": ["60/99"]
                },
                {
                    "property": "weight.consequence",
                    "property-operations": null,
                    "cells": ["15/99"]
                }
            ]
        }
    ],
    "meta": [
        {
            "type": "MANAGEMENT",
            "dataHeader": null,
            "data": [
                {
                    "context": {
                        "value": "rule.entity.id",
                        "possible-matches": null
                    },
                    "cells": [
                        "InlandRevenueAuthorityofSingapore",
                        "https://www.iras.gov.sg/",
                        "d6mgsIlDx5ME"
                    ]
                },
                {
                    "context": {
                        "value": "rule.name.eng",
                        "possible-matches": null
                    },
                    "cells": ["AdditionalBuyersStampDutyonPurchaseorTransferofResidentialProperty"]
                },
                {
                    "context": {
                        "value": "rule.id",
                        "possible-matches": null
                    },
                    "cells": ["r6qW2UeKE5hq"]
                },
                {
                    "context": {
                        "value": "rule.version",
                        "possible-matches": null
                    },
                    "cells": ["0.0.2"]
                },
                {
                    "context": {
                        "value": "rule.runtime",
                        "possible-matches": null
                    },
                    "cells": ["0.5.0"]
                },
                {
                    "context": {
                        "value": "rule.criticality",
                        "possible-matches": null
                    },
                    "cells": ["experimental"]
                },
                {
                    "context": {
                        "value": "rule.url",
                        "possible-matches": null
                    },
                    "cells": [
                        "https://www.iras.gov.sg/IRASHome/OtherTaxes/StampDutyforProperty/WorkingoutyourStamp\r\nDuty/BuyingorAcquiringProperty/WhatistheDutythatINeedtoPayasaBuyerorTransfereeof\r\nResidentialProperty/AdditionalBuyersStampDutyABSD/"
                    ]
                },
                {
                    "context": {
                        "value": "rule.doi",
                        "possible-matches": null
                    },
                    "cells": ["10.1206/yd5Dw9Im5rJfaGheM84cFq"]
                },
                {
                    "context": {
                        "value": "rule.manager.id",
                        "possible-matches": null
                    },
                    "cells": ["JosephPotvin", "<jpotvin@xalgorithms.org", "3ErzHgMpIhYI"]
                },
                {
                    "context": {
                        "value": "rule.author.id",
                        "possible-matches": null
                    },
                    "cells": ["JosephPotvin", "<jpotvin@xalgorithms.org", "3ErzHgMpIhYI"]
                },
                {
                    "context": {
                        "value": "rule.maintainer.id",
                        "possible-matches": null
                    },
                    "cells": ["RyanFleck", "<ryan.fleck@protonmail.com>", "wVXkRXp1palS"]
                }
            ]
        },
        {
            "type": "STANDARDS",
            "dataHeader": null,
            "data": [
                {
                    "context": {
                        "value": "parties.buyer.industry",
                        "possible-matches": null
                    },
                    "cells": ["ISIC"]
                },
                {
                    "context": {
                        "value": "data",
                        "possible-matches": null
                    },
                    "cells": ["https://unstats.un.org/unsd/publication/seriesM/seriesm_4rev4e.pdf"]
                },
                {
                    "context": {
                        "value": "item:classification",
                        "possible-matches": null
                    },
                    "cells": ["UNSPSC", "https://www.unspsc.org"]
                },
                {
                    "context": {
                        "value": "document",
                        "possible-matches": null
                    },
                    "cells": [
                        "UBL",
                        "https://docs.oasisopen.org/ubl/osUBL2.2/mod/summary/reports/AllUBL2.2Documents.html"
                    ]
                }
            ]
        }
    ]
}
```

### Development Information:

1. Using _VS Code_ with [_Eslint_](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) and [_Prettier_](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) plugins.
1. Using _Jest_ for unit tests.
1. Using `eslint-config-airbnb` with _Prettier_ to enforce style
   ([guide](https://blog.echobind.com/integrating-prettier-eslint-airbnb-style-guide-in-vscode-47f07b5d7d6a))

### Plugins

Name: PEG.js Language

Id: sirtobi.pegjs-language

Description: Syntax highlighting for PEG.js in Visual Studio Code.

Version: 0.1.0

Publisher: SrTobi

VS Marketplace Link:
https://marketplace.visualstudio.com/items?itemName=SirTobi.pegjs-language

Name: PEG.js

Id: tamuratak.vscode-pegjs

Description: PEG.js language support for Visual Studio Code

Version: 0.1.2

Publisher: tamuratak

VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=tamuratak.vscode-pegjs


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FRyanFleck%2Fxalgo-lib-pegjs-parser.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FRyanFleck%2Fxalgo-lib-pegjs-parser?ref=badge_large)
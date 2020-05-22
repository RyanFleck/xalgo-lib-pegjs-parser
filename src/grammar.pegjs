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
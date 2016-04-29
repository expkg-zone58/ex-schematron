
import module namespace sch="expkg-zone58.validation.schematron" at "../main/content/schematron.xqm";

declare namespace svrl="http://purl.oclc.org/dsdl/svrl";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
let $a:=doc("resources/schematron.xml")
let $b:=doc("resources/cv.xml")

let $x:= sch:validate-document($b,$a) 
return $x/svrl:schematron-output

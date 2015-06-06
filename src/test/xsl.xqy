
import module namespace sch="https://github.com/apb2006/EX-schematron" at "../Modules/schematron.xqy";

declare namespace svrl="http://purl.oclc.org/dsdl/svrl";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
let $a:=doc("C:\Users\andy\Desktop\schematron\examples\schematron.xml")
let $b:=doc("C:\Users\andy\Desktop\schematron\examples\cv.xml")

let $x:= sch:validate-document($b,$a) 
return $x/svrl:schematron-output

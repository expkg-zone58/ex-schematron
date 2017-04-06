xquery version "3.0" encoding "UTF-8";
(:~
 : Perform Schematron validation from XQuery using the reference XSLT implementation
 : packaged using EXPath targeted at BaseX 8.6+
 : based on <a href="https://github.com/ndw/ML-Schematron">https://github.com/ndw/ML-Schematron</a>
 : @author Andy Bunce
 : @version 0.3.0 
 :)
 
module namespace schx="expkg-zone58:validation.schematron";


declare namespace iso="http://purl.oclc.org/dsdl/schematron";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace svrl="http://purl.oclc.org/dsdl/svrl";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: ***** Turn whitespace chopping off. NOT ALLOWED SINCE 8.4.3 SET IN MAIN ***** :)
(: declare option db:chop 'no'; :)

(: paths to xslt  :)
declare %private variable $schx:include := resolve-uri("schematron/iso_dsdl_include.xsl");
declare %private variable $schx:expand  := resolve-uri("schematron/iso_abstract_expand-fix.xsl");
declare %private variable $schx:compile := resolve-uri("schematron/iso_svrl_for_xslt2.xsl");

declare %private variable $schx:BADSCHEMA := xs:QName("schx:BADSCHEMA");
declare %private variable $schx:BADDOC := xs:QName("schx:BADDOC");

(:~
 : Validate <code>$document</code> using schematron <code>$schema</code>
 : @param $params schematron options passed to xslt
 : @result SVRL validation report
 : @error schx:BADDOC
 :)
declare function schx:validate-document(
  $document as node(),
  $schema as node(),
  $params as map(*))
as document-node(element(svrl:schematron-output))?
{
  let $compiled := schx:compile-schema($schema, $params)
  let $doc:= schx:check-src($document,
                         $schx:BADDOC,
                         "Schematron can only validate a document or element.")
  return
    xslt:transform( $doc, $compiled,$params)
};

declare function schx:validate-document($document, $schema)
as document-node(element(svrl:schematron-output))?
{
  schx:validate-document($document, $schema, map{})
};

(:~
 : flatten schematron source by processing includes
 : @error schx:BADSCHEMA
 :)
declare function schx:include($schema as node(),$params as map(*))
as document-node(element(iso:schema))
{
 let $sch:=schx:check-src($schema,
                         $schx:BADSCHEMA,
                         "Schematron schema must be a document or element.")
    
 return xslt:transform($sch,$schx:include,$params)
}; 

declare function schx:include($schema as node())
as document-node(element(iso:schema))
{
    schx:include($schema,map{})
}; 

(:~
 : Compile a schematron source to XSLT 
 : @param $schema schematron as document or element 
 : @return xslt implementation of rules in $schema
 : @error schx:BADSCHEMA
 :)
declare function schx:compile-schema(
  $schema as node(),
  $params as map(*)
) as document-node(element(xsl:stylesheet))
{
  let $sch:=schx:check-src($schema,
                         $schx:BADSCHEMA,
                         "Schematron schema must be a document or element.")
    
  let $included := xslt:transform($sch,$schx:include, $params)
  let $expanded := xslt:transform( $included, $schx:expand,$params)
  return
    xslt:transform( $expanded,$schx:compile, $params)
};



(:~ 
 : check $document is suitable for validation node or document
 : @error varies
 :)
declare %private function schx:check-src(
		$document as node(),
		$err as xs:QName,
		$errmsg as xs:string )
as document-node(element())
{
	typeswitch ($document)
       case document-node()
            return $document
       case element()
            return document { $document }
       default
            return error($err,$errmsg)

};

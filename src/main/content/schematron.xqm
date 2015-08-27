xquery version "3.0" encoding "UTF-8";
(:~
 : Schematron validation from XQuery
 : uses XSLT from http://www.schematron.com/implementation.html
 :  <xsl:param name="include-schematron">true</xsl:param>
 :	<xsl:param name="include-crdl">true</xsl:param>
 :	<xsl:param name="include-xinclude">true</xsl:param>
 :	<xsl:param name="include-dtll">true</xsl:param>
 :	<xsl:param name="include-relaxng">true</xsl:param>
 :	<xsl:param name="include-xlink">true</xsl:param>
 : packaged using EXPath targeted at BaseX 8.2+
 : based on https://github.com/ndw/ML-Schematron
 : @author Andy Bunce
 : @since 2014 
 :)
 
module namespace schx="expkg-zone58.validation.schematron";


declare namespace iso="http://purl.oclc.org/dsdl/schematron";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace svrl="http://purl.oclc.org/dsdl/svrl";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: ***** Turn whitespace chopping off. ***** :)
declare option db:chop 'no';

(: paths to xslt  :)
declare variable $schx:include := resolve-uri("schematron/iso_dsdl_include.xsl");
declare variable $schx:expand  := resolve-uri("schematron/iso_abstract_expand.xsl");
declare variable $schx:compile := resolve-uri("schematron/iso_svrl_for_xslt2.xsl");

declare variable $schx:BADSCHEMA := xs:QName("schx:BADSCHEMA");
declare variable $schx:BADDOC := xs:QName("schx:BADDOC");

(:~
 : flatten schematron source
 :)
declare function schx:flatten($schema as node())
as  document-node(element(iso:schema))
{
 let $sch:=schx:check-src($schema,
                         $schx:BADSCHEMA,
                         "Schematron schema must be a document or element.")
    
 return xslt:transform($sch,$schx:include)
}; 

(:~ 
 : @param $schema schematron as document or element 
 : @return xslt implementation of rules in $schema
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

declare function schx:validate-document($document, $schema)
as document-node(element(svrl:schematron-output))?
{
  schx:validate-document($document, $schema, map{})
};

(:~
 : @param $params schematron options
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

(:~ 
 : check node or document
 :)
declare function schx:check-src(
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

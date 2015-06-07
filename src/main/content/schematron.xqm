(:~
 : Schematron validation from XQuery
 : uses XSLT from http://www.schematron.com/implementation.html
 : packaged using EXPath 
 : targeted at BaseX
 : large chunks based on https://github.com/ndw/ML-Schematron
 : @author Andy Bunce
 : @since 2014 
 :)

module namespace sch="expkg-zone58.validation.schematron";

declare namespace s="http://www.ascc.net/xml/schematron";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace svrl="http://purl.oclc.org/dsdl/svrl";

declare default function namespace "http://www.w3.org/2005/xpath-functions";



(: Edit these paths if you don't follow the "global" install instructions :)
declare variable $sch:include := resolve-uri("schematron/iso_dsdl_include.xsl");
declare variable $sch:expand  := resolve-uri("schematron/iso_abstract_expand.xsl");
declare variable $sch:compile := resolve-uri("schematron/iso_svrl_for_xslt2.xsl");

declare variable $sch:BADSCHEMA := xs:QName("sch:BADSCHEMA");
declare variable $sch:BADDOC := xs:QName("sch:BADDOC");

declare function sch:compile-schema(
  $schema as node(),
  $params as map(*)
) as document-node(element(xsl:stylesheet))
{
  let $sch
    := typeswitch ($schema)
       case document-node()
            return $schema
       case element()
            return document { $schema }
       default
            return error($sch:BADSCHEMA,
                         "Schematron schema must be a document or element.")
  let $included := xslt:transform($sch,$sch:include, $params)
  let $expanded := xslt:transform( $included, $sch:expand,$params)
  return
    xslt:transform( $expanded,$sch:compile, $params)
};

declare function sch:validate-document($document, $schema) {
  sch:validate-document($document, $schema, map{})
};

declare function sch:validate-document(
  $document as node(),
  $schema as node(),
  $params as map(*))
as document-node(element(svrl:schematron-output))?
{
  let $compiled := sch:compile-schema($schema, $params)
  let $doc
    := typeswitch ($document)
       case document-node()
            return $document
       case element()
            return document { $document }
       default
            return error($sch:BADDOC,
                         "Schematron can only validate a document or element.")
  return
    xslt:transform( $doc, $compiled,$params)
};

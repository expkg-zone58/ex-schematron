# ISO Schematron validation from XQuery

* uses XSLT from http://www.schematron.com/implementation.html
* adds fix for abstract rules bug #6 (https://code.google.com/p/schematron/issues/detail?id=6)
* packaged using EXPath 
* targeted at BaseX 8.2+

## Installation

````
"https://github.com/expkg-zone58/ex-schematron/releases/download/v0.0.11/schematron-0.0.11.xar"
!repo:install()
````

## Usage

````
import module namespace sch="expkg-zone58.validation.schematron";
sch:validate-document($doc, $sch)
````

## Related work
* Marklogic implementation by Norman Walsh https://github.com/ndw/ML-Schematron
* BaseX implementation Vincent Lizzi by https://github.com/vincentml/schematron-basex 
* ExistDb implementation Vincent Lizzi by https://github.com/vincentml/schematron-exist

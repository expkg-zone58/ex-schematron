(: create o/ps
 : xar package and xqdoc
 :)
declare namespace pkg="http://expath.org/ns/pkg";
import module namespace build = "quodatum.utils.build" at "buildx.xqm";

declare variable $src:=resolve-uri("src/main/");
declare variable $dest:=resolve-uri("dist/");

(:~ 
 : the package definition as a pkg:package 
 :)
declare variable $package as element(pkg:package) :=doc(resolve-uri("expath-pkg.xml",$src))/pkg:package;

declare variable $content:=resolve-uri( $package/@abbrev,$src);
declare variable $dest-doc:=resolve-uri("doc/",$dest);


let $files:=build:files($src) 
let $name:= build:xar($package)
(: save xqdoc :) 
return (build:transform(
          $package/pkg:xquery/pkg:file,
          function($path){inspect:xqdoc(file:resolve-path( $path,$content))},
          function($path,$data){ fn:put($data,
                                resolve-uri(fn:trace($path) || ".xml",$dest-doc))
                              }
          ),
          (: write xar  :)       
          build:merge(
           $files,
           function($path){file:read-binary(file:resolve-path($path,$src))},
           function($paths,$data){file:write-binary(
                                         resolve-uri($name,$dest),
                                         archive:create($paths,$data))}
           ),
           build:publish($package,fn:resolve-uri("package.xml"))
 )
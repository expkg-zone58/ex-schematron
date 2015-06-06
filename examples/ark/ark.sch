
<schema xmlns="http://purl.oclc.org/dsdl/schematron">
  <ns uri="http://www.schematron.info/ark" prefix="ark"/>
  <pattern>
    <rule context="ark:animal[@carnivore='yes']">
      <report test="parent::*/ark:animal[@carnivore='no']">
      There are carnivores and herbivores in one accommodation. 
      The animals are not a food source!
      </report>
    </rule>
  </pattern>
</schema>

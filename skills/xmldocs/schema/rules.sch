<?xml version="1.0" encoding="UTF-8"?>
<!-- Rules between attributes that XSD 1.0 cannot express. Applies to every type. -->
<schema xmlns="http://purl.oclc.org/dsdl/schematron">
  <pattern id="decisions">
    <rule context="decision[@status='decided']">
      <assert test="choice">decision '<value-of select="@id"/>' is decided but has no choice.</assert>
    </rule>
    <rule context="decision[@status='open']">
      <assert test="not(choice)">decision '<value-of select="@id"/>' is open but has a choice.</assert>
    </rule>
    <rule context="choice">
      <assert test="@option = ../option/@id">choice in decision '<value-of select="../@id"/>' names an option that is not in that decision.</assert>
    </rule>
  </pattern>
  <pattern id="plans">
    <rule context="phase[@needs]">
      <assert test="not(//decision[contains(concat(' ', normalize-space(current()/@needs), ' '), concat(' ', @id, ' '))][@status != 'decided'])
                    or not(@status) or @status = 'todo'">phase '<value-of select="@id"/>' has started but a decision it needs is not decided.</assert>
    </rule>
    <rule context="/plan[@status='approved' or @status='in-progress' or @status='done']">
      <assert test="not(.//decision[@status='open'])">plan is <value-of select="@status"/> but still has open decisions.</assert>
    </rule>
  </pattern>
  <pattern id="documents">
    <rule context="/*[@status='accepted']">
      <assert test="not(.//decision[@status='open'])">document is accepted but still has open decisions.</assert>
    </rule>
  </pattern>
</schema>

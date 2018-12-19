<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:grg="http://www.isotc211.org/2005/grg"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-core="http://geonetwork-opensource.org/xsl/functions/core"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="#all">


  <!-- Readonly -->
  <xsl:template mode="mode-iso19135" priority="200"
                match="grg:uniformResourceIdentifier/gmd:CI_OnlineResource/gmd:linkage[gmd:URL]">
    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>

    <xsl:call-template name="render-element">
      <xsl:with-param name="label"
                      select="$labelConfig"/>
      <xsl:with-param name="value" select="*"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="xpath" select="$xpath"/>
      <xsl:with-param name="type" select="gn-fn-metadata:getFieldType($editorConfig, name(), '')"/>
      <xsl:with-param name="name" select="''"/>
      <xsl:with-param name="editInfo" select="*/gn:element"/>
      <xsl:with-param name="parentEditInfo" select="gn:element"/>
      <xsl:with-param name="isDisabled" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Simply show the full content of the list -->
  <xsl:template name="iso19135-list-full-content">
    <xsl:apply-templates select="$metadata//grg:containedItem[not(@xlink:href)]"
        mode="mode-iso19135" />
  </xsl:template>

  <xsl:template name="iso19135-list-full-content-index">
    <xsl:variable name="items" select="$metadata//grg:RE_RegisterItem/grg:name/gco:CharacterString"/>
    <h3>
        <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'codeListIndexSide', $labels)/label"/>
    </h3>
    <ul>
      <xsl:for-each select="$items">
        <xsl:variable name="ref" select="../../../gn:element/@ref" />
        <li><a onclick="document.getElementById('gn-el-{$ref}').scrollIntoView();" ><xsl:value-of select="."/></a></li>
      </xsl:for-each>
    </ul>
  </xsl:template> 

  <!-- Create a table of content of list of items

  TODO: Create a TOC based on status ?
  -->
  <xsl:template name="iso19135-table-of-content">
    <hr/>
    <xsl:variable name="items" select="$metadata//grg:RE_RegisterItem/grg:name/gco:CharacterString"/>
    <xsl:variable name="currentLetter"
                  select="if ($requestParameters/tocIndex != '' and
                            count($metadata//grg:RE_RegisterItem[
                              starts-with(grg:name/gco:CharacterString, $requestParameters/tocIndex)]) > 0)
                          then $requestParameters/tocIndex
                          else substring(upper-case($items[1]), 1, 1)"/>


    <xsl:for-each-group select="$items"
                        group-by="substring(upper-case(.), 1, 1)">
      <xsl:sort select="current-grouping-key()"/>

      <xsl:variable name="label">
        <xsl:value-of select="current-grouping-key()"/>(<xsl:value-of select="count(current-group())"/>)
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="current-grouping-key() = $currentLetter">
          <xsl:value-of select="$label"/>
        </xsl:when>
        <xsl:otherwise>
          <a data-ng-click="tocIndex = '{current-grouping-key()}'"><xsl:value-of select="$label"/></a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()"> - </xsl:if>
    </xsl:for-each-group>
    <hr/>
    <input name="tocIndex" type="text" class="hidden" value="{$currentLetter}"
           data-ng-model="tocIndex"/>



    <!-- Display items according to the letter -->
    <xsl:apply-templates
        select="$metadata//grg:containedItem[starts-with(grg:RE_RegisterItem/grg:name/gco:CharacterString, $currentLetter)]"
        mode="mode-iso19135"
        />
  </xsl:template>

  <!-- TODO : improve editor in simple mode -->
  <xsl:template mode="mode-iso19135"
                match="grg:fieldOfApplication[$tab='default']"
                priority="2000"></xsl:template>

  <xsl:template mode="mode-iso19135"
                match="grg:specificationLineage[$tab='default']"
                priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="codelists" select="$codelists" required="no"/>

    <xsl:variable name="listOfRelations"
                  select="gn-fn-metadata:getCodeListValues($schema, 'grg:RE_SimilarityToSource', $codelists, .)"/>
    <xsl:variable name="typeOfRelation"
                  select="grg:RE_Reference/grg:similarity/grg:RE_SimilarityToSource"/>
    <xsl:variable name="itemIdentifier" select="grg:RE_Reference/grg:itemIdentifierAtSource/gco:CharacterString"/>

    <div class="form-group">
      <label class="col-sm-2 control-label">
        <xsl:value-of select="gn-fn-metadata:getLabel($schema, 'grg:specificationLineage', $labels)/label"/>
      </label>
      <div class="col-sm-3">
        <xsl:value-of select="$typeOfRelation"/>
        <select name="_{$typeOfRelation/gn:element/@ref}_codeListValue">
          <xsl:for-each select="$listOfRelations/entry">
            <option value="{code}">
              <xsl:if test="code = $typeOfRelation/@codeListValue">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:value-of select="label"/>
            </option>
          </xsl:for-each>
        </select>
      </div>
      <div class="col-sm-5">
        <select name="_{$itemIdentifier/gn:element/@ref}">
          <xsl:for-each select="$metadata//grg:RE_RegisterItem">
            <option value="{grg:itemIdentifier/gco:Integer/text()}">
              <xsl:if test="$itemIdentifier/text() = grg:itemIdentifier/gco:Integer/text()">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:value-of select="grg:name/gco:CharacterString"/>
            </option>
          </xsl:for-each>
        </select>
      </div>
      <div class="col-sm-2 gn-control">

      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>

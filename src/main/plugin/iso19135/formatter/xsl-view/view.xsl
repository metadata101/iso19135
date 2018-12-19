<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:grg="http://www.isotc211.org/2005/grg"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19135="http://geonetwork-opensource.org/xsl/functions/profiles/iso19135"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!-- This formatter render an ISO19139 record based on the
  editor configuration file.


  The layout is made in 2 modes:
  * render-field taking care of elements (eg. sections, label)
  * render-value taking care of element values (eg. characterString, URL)

  3 levels of priority are defined: 100, 50, none

  -->


  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

 <!-- Required for utility-fn.xsl -->
  <xsl:variable name="editorConfig"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>
  <xsl:include href="../../layout/utility-fn.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/grg:RE_Register"/>

  <xsl:variable name="langId" select="gn-fn-iso19135:getLangId($metadata, $language)"/>


  <!-- Ignore some fields displayed in header or in right column -->
  <xsl:template mode="render-field"
                match="//grg:RE_Register/grg:name|grg:contentSummary"
                priority="2000"/>




  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="grg:RE_Register">
    <xsl:for-each select="grg:name">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="grg:RE_Register">
    <xsl:for-each select="grg:contentSummary">

      <xsl:variable name="txt">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="addLineBreaksAndHyperlinks">
        <xsl:with-param name="txt" select="$txt"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataHierarchyLevel" match="grg:RE_Register">

  </xsl:template>

  <xsl:template mode="getMetadataThumbnail" match="grg:RE_Register">

  </xsl:template>

  <xsl:template mode="getOverviews" match="grg:RE_Register">

  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="grg:RE_Register">
    <div class="alert alert-info">
      <xsl:for-each select="grg:contentSummary">
        <xsl:variable name="txt">
          <xsl:call-template name="localised">
            <xsl:with-param name="langId" select="$langId"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="addLineBreaksAndHyperlinks">
          <xsl:with-param name="txt" select="$txt"/>
        </xsl:call-template>
      </xsl:for-each>
    </div>

  </xsl:template>


  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
                match="*[gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|
       gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gmd:PT_FreeText|gml:beginPosition|gml:endPosition|
       gco:Date|gco:DateTime|*/@codeListValue|grg:RE_ItemStatus]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <xsl:if test="normalize-space(string-join(*|*/@codeListValue, '')) != ''">
      <dl>
        <dt>
          <xsl:value-of select="if ($fieldName)
                                  then $fieldName
                                  else tr:node-label(tr:create($schema), name(), null)"/>
        </dt>
        <dd>
          <xsl:apply-templates mode="render-value" select="*|*/@codeListValue"/>
          <xsl:apply-templates mode="render-value" select="@*"/>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-field"
                match="*[gco:CharacterString]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="."/>
        <xsl:apply-templates mode="render-value" select="@*"/>
      </dd>
    </dl>
  </xsl:template>

  <!-- Some elements are only containers so bypass them -->
  <xsl:template mode="render-field"
                match="*[
                          count(gmd:*[name() != 'gmd:PT_FreeText']) = 1 and
                          count(*/@codeListValue) = 0
                        ]"
                priority="50">

    <xsl:apply-templates mode="render-value" select="@*"/>
    <xsl:apply-templates mode="render-field" select="*"/>
  </xsl:template>


  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
                match="*[name() = $configuration/editor/fieldsWithFieldset/name
    or @gco:isoType = $configuration/editor/fieldsWithFieldset/name]|
      gmd:report/*|
      gmd:result/*|
      gmd:extent[name(..)!='gmd:EX_TemporalExtent']|
      *[$isFlatMode = false() and gmd:* and
        not(gco:CharacterString) and not(gmd:URL)]">

    <div class="entry name">
      <h2>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:apply-templates mode="render-value"
                             select="@*"/>
      </h2>
      <div class="target">
        <xsl:choose>
          <xsl:when test="count(*) > 0">
            <xsl:apply-templates mode="render-field" select="*"/>
          </xsl:when>
          <xsl:otherwise>
            No information provided.
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>

  </xsl:template>



  <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_ResponsibleParty]"
                priority="100">
    <xsl:variable name="email">
      <xsl:for-each select="*/gmd:contactInfo/
                                      */gmd:address/*/gmd:electronicMailAddress">
        <xsl:apply-templates mode="render-value"
                             select="."/><xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Display name is <org name> - <individual name> (<position name> -->
    <xsl:variable name="displayName">
      <xsl:choose>
        <xsl:when
          test="*/gmd:organisationName and */gmd:individualName">
          <!-- Org name may be multilingual -->
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:organisationName"/>
          -
          <xsl:value-of select="*/gmd:individualName"/>
          <xsl:if test="*/gmd:positionName">
            (<xsl:apply-templates mode="render-value"
                                  select="*/gmd:positionName"/>)
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*/gmd:organisationName|*/gmd:individualName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="gn-contact">
      <h3>
        <i class="fa fa-envelope">&#160;</i>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:role/*/@codeListValue"/>
      </h3>
      <div class="row">
        <div class="col-md-6">
          <address itemprop="author"
                   itemscope="itemscope"
                   itemtype="http://schema.org/Organization">
            <strong>
              <xsl:choose>
                <xsl:when test="$email">
                  <a href="mailto:{normalize-space($email)}">
                    <xsl:value-of select="$displayName"/>&#160;
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$displayName"/>
                </xsl:otherwise>
              </xsl:choose>
            </strong>
            <br/>
            <xsl:for-each select="*/gmd:contactInfo/*">
              <xsl:for-each select="gmd:address/*">
                <div itemprop="address"
                      itemscope="itemscope"
                      itemtype="http://schema.org/PostalAddress">
                  <xsl:for-each select="gmd:deliveryPoint">
                    <span itemprop="streetAddress">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:city">
                    <span itemprop="addressLocality">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:administrativeArea">
                    <span itemprop="addressRegion">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:postalCode">
                    <span itemprop="postalCode">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:country">
                    <span itemprop="addressCountry">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                </div>
                <br/>
              </xsl:for-each>
            </xsl:for-each>
          </address>
        </div>
        <div class="col-md-6">
          <address>
            <xsl:for-each select="*/gmd:contactInfo/*">
              <xsl:for-each select="gmd:phone/*/gmd:voice[normalize-space(.) != '']">
                <div itemprop="contactPoint"
                      itemscope="itemscope"
                      itemtype="http://schema.org/ContactPoint">
                  <meta itemprop="contactType"
                        content="{ancestor::gmd:CI_ResponsibleParty/*/gmd:role/*/@codeListValue}"/>

                  <xsl:variable name="phoneNumber">
                    <xsl:apply-templates mode="render-value" select="."/>
                  </xsl:variable>
                  <i class="fa fa-phone">&#160;</i>
                  <a href="tel:{$phoneNumber}">
                    <xsl:value-of select="$phoneNumber"/>&#160;
                  </a>
                </div>
              </xsl:for-each>
              <xsl:for-each select="gmd:phone/*/gmd:facsimile[normalize-space(.) != '']">
                <xsl:variable name="phoneNumber">
                  <xsl:apply-templates mode="render-value" select="."/>
                </xsl:variable>
                <i class="fa fa-fax">&#160;</i>
                <a href="tel:{normalize-space($phoneNumber)}">
                  <xsl:value-of select="normalize-space($phoneNumber)"/>&#160;
                </a>
              </xsl:for-each>

              <xsl:for-each select="gmd:hoursOfService">
                <span itemprop="hoursAvailable"
                      itemscope="itemscope"
                      itemtype="http://schema.org/OpeningHoursSpecification">
                  <xsl:apply-templates mode="render-field"
                                       select="."/>
                </span>
              </xsl:for-each>

              <xsl:apply-templates mode="render-field"
                                   select="gmd:contactInstructions"/>
              <xsl:apply-templates mode="render-field"
                                   select="gmd:onlineResource"/>

            </xsl:for-each>
          </address>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Metadata linkage -->
  <xsl:template mode="render-field"
                match="grg:RE_Register"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(@uuid), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="@*"/>
        <a class="btn btn-link" href="{$nodeUrl}api/records/{@uuid}/formatters/xml">
          <i class="fa fa-file-code-o fa-2x">&#160;</i>
          <span><xsl:value-of select="$schemaStrings/metadataInXML"/></span>
        </a>
      </dd>
    </dl>

    <xsl:apply-templates mode="render-field" select="*"/>
  </xsl:template>


  <!-- Contained Item -->
  <xsl:template mode="render-field"
                match="grg:containedItem" priority="100">

    <div class="entry name">
      <h2>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>

      </h2>
      <div class="target">
        <xsl:choose>
          <xsl:when test="count(*) > 0">
            <xsl:if test="@id">
              <dl>
                <dt>
                  <xsl:value-of select="tr:node-label(tr:create($schema), name(@id), null)"/>
                </dt>
                <dd>
                  <xsl:apply-templates mode="render-value" select="@id"/>
                </dd>
              </dl>
            </xsl:if>

            <xsl:if test="@xlink:href">
              <dl>
                <dt>
                  <xsl:value-of select="tr:node-label(tr:create($schema), name(@xlink:href), null)"/>
                </dt>
                <dd>
                  <xsl:apply-templates mode="render-value" select="@xlink:href"/>
                </dd>
              </dl>
            </xsl:if>

            <xsl:apply-templates mode="render-field" select="*"/>
          </xsl:when>
          <xsl:otherwise>
            No information provided.
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>

  </xsl:template>


  <!-- Linkage -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_OnlineResource and */gmd:linkage/gmd:URL != '']"
                priority="100">
    <dl class="gn-link"
        itemprop="distribution"
        itemscope="itemscope"
        itemtype="http://schema.org/DataDownload">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:variable name="linkUrl"
                      select="*/gmd:linkage/gmd:URL"/>
        <xsl:variable name="linkName">
          <xsl:choose>
            <xsl:when test="*/gmd:name[* != '']">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:name"/>
            </xsl:when>
            <xsl:when test="*/gmd:description[* != '']">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:description"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$linkUrl"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <a href="{$linkUrl}" title="{$linkName}">
          <xsl:value-of select="$linkName"/>
        </a>
        &#160;

        <xsl:if test="*/gmd:description[* != '' and * != $linkName]">
          <p>
            <xsl:apply-templates mode="render-value"
                                 select="*/gmd:description"/>
          </p>
        </xsl:if>
      </dd>
    </dl>
  </xsl:template>

  <!-- Identifier -->
  <xsl:template mode="render-field"
                match="*[(gmd:RS_Identifier or gmd:MD_Identifier) and
                  */gmd:code/gco:CharacterString != '']"
                priority="100">
    <dl class="gn-code">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>

        <xsl:if test="*/gmd:codeSpace">
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:codeSpace"/>
          /
        </xsl:if>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:code"/>
        <xsl:if test="*/gmd:version">
          /
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:version"/>
        </xsl:if>
        <xsl:if test="*/gmd:authority">
          <p>&#160;
            <xsl:apply-templates mode="render-field"
                                 select="*/gmd:authority"/>
          </p>
        </xsl:if>
      </dd>
    </dl>
  </xsl:template>

  <!-- Date -->
  <xsl:template mode="render-field"
                match="gmd:date"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:if test="*/gmd:dateType/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:dateType/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:date/*"/>
      </dd>
    </dl>
  </xsl:template>


 <!-- Elements to avoid render -->
  <xsl:template mode="render-field" match="gmd:PT_Locale" priority="100"/>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field"
                match="*">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>


  <!-- ########################## -->
  <!-- Render values for text ... -->
   <xsl:template mode="render-value"
                match="*[gco:CharacterString]">

     <xsl:variable name="txt">
       <xsl:apply-templates mode="localised" select=".">
         <xsl:with-param name="langId" select="$langId"/>
       </xsl:apply-templates>
     </xsl:variable>

     <xsl:call-template name="addLineBreaksAndHyperlinks">
       <xsl:with-param name="txt" select="$txt"/>
     </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gml:beginPosition|gml:endPosition">

    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')"/>

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="@uom">
      &#160;<xsl:value-of select="@uom"/>
    </xsl:if>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value"
                match="gmd:URL">
    <a href="{.}">
      <xsl:value-of select="."/>&#160;
    </a>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive  -->
  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="MMM YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:DateTime[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date|gco:DateTime">
    <span data-gn-humanize-time="{.}">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gmd:language/gco:CharacterString">
    <span data-translate="">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value"
                match="@codeListValue">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Enumeration -->
  <xsl:template mode="render-value"
                match="gmd:MD_TopicCategoryCode|
                        gmd:MD_ObligationCode|
                        gmd:MD_PixelOrientationCode">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Attributes -->
  <xsl:template mode="render-value"
                match="grg:RE_Register/@uuid|grg:containedItem/@id|grg:containedItem/@xlink:href"
                priority="100">
    <span><xsl:value-of select="." /></span>
  </xsl:template>


  <xsl:template mode="render-value"
                match="@gco:nilReason[. = 'withheld']"
                priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}">&#160;</i>
  </xsl:template>
  <xsl:template mode="render-value"
                match="@*"/>


  <!-- Template used to return a gco:CharacterString element
      in default metadata language or in a specific locale
      if exist.
      FIXME : gmd:PT_FreeText should not be in the match clause as gco:CharacterString
      is mandatory and PT_FreeText optional. Added for testing GM03 import.
  -->
  <xsl:template name="localised" mode="localised" match="*[gco:CharacterString or gmd:PT_FreeText]">
    <xsl:param name="langId"/>

    <xsl:choose>
      <xsl:when
        test="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] and
        gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] != ''">
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId]"/>
      </xsl:when>
      <xsl:when test="not(gco:CharacterString)">
        <!-- If no CharacterString, try to use the first textGroup available -->
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup[position()=1]/gmd:LocalisedCharacterString"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="gco:CharacterString"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <!-- Get lang #id in metadata PT_Locale section,  deprecated: if not return the 2 first letters
       of the lang iso3code in uper case.

        if not return the lang iso3code in uper case.
       -->
  <xsl:function name="gn-fn-iso19135:getLangId" as="xs:string">
    <xsl:param name="md"/>
    <xsl:param name="lang"/>

    <xsl:value-of select="concat('#', upper-case($lang))"/>
  </xsl:function>

</xsl:stylesheet>

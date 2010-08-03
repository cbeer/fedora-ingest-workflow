<xsl:stylesheet xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:fedora-rels-ext="info:fedora/fedora-system:def/relations-external#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<!--	<xsl:output method="xml" encoding="UTF-8"/>-->
  <xsl:template match="UOIS">
    <oai_dc:dc>
	    <xsl:if test="WGBH_IDENTIFIER/@NOLA_CODE and @NAME[contains(., '.jpg')]">
		    <dc:identifier><xsl:value-of select="WGBH_IDENTIFIER/@NOLA_CODE" /></dc:identifier>
      </xsl:if>
      <dc:identifier><xsl:value-of select="@UOI_ID" /></dc:identifier>
      <xsl:choose>
	      <xsl:when test="WGBH_SOURCE[@SOURCE_TYPE = 'Digital Video Essence URL']">
		   <dc:source><xsl:value-of select="WGBH_SOURCE[@SOURCE_TYPE = 'Digital Video Essence URL']/@SOURCE" /></dc:source>
      </xsl:when>
      <xsl:otherwise>
      <dc:source><xsl:value-of select="@NAME" /></dc:source>
      </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
      <xsl:when test="WGBH_TITLE[@TITLE_TYPE = 'Element']">
        <dc:title><xsl:value-of select="WGBH_TITLE[@TITLE_TYPE = 'Element']/@TITLE" /></dc:title>
      </xsl:when>
      <xsl:when test="WGBH_TITLE[@TITLE_TYPE = 'Segment']">
        <dc:title><xsl:value-of select="WGBH_TITLE[@TITLE_TYPE = 'Segment']/@TITLE" /></dc:title>
      </xsl:when>
      <xsl:when test="WGBH_TITLE[@TITLE_TYPE = 'Program']">
        <dc:title><xsl:value-of select="WGBH_TITLE[@TITLE_TYPE = 'Program']/@TITLE" /></dc:title>
      </xsl:when>
      <xsl:when test="WGBH_TITLE[@TITLE_TYPE = 'Series']">
        <dc:title><xsl:value-of select="WGBH_TITLE[@TITLE_TYPE = 'Series']/@TITLE" /></dc:title>
      </xsl:when>
      <xsl:when test="generate-id(WGBH_TITLE[1]) = generate-id(WGBH_TITLE[last()])">
	<dc:title><xsl:value-of select="WGBH_TITLE[1]/@TITLE" /></dc:title>
      </xsl:when>
      <xsl:when test="WGBH_TITLE">
	<dc:title><xsl:value-of select="WGBH_TITLE[1]/@TITLE" /></dc:title>
      </xsl:when>
      </xsl:choose>
      <xsl:choose>
      <xsl:when test="WGBH_DESCRIPTION[@DESCRIPTION_TYPE = 'Abstract']">
        <dc:description><xsl:value-of select="WGBH_DESCRIPTION[@DESCRIPTION_TYPE = 'Abstract']/@DESCRIPTION" /></dc:description>
</xsl:when>
      <xsl:when test="WGBH_DESCRIPTION[@DESCRIPTION_TYPE = 'Description']">
        <dc:description><xsl:value-of select="WGBH_DESCRIPTION[@DESCRIPTION_TYPE = 'Description']/@DESCRIPTION" /></dc:description>
</xsl:when>
	<xsl:when test="generate-id(WGBH_DESCRIPTION[1]) = generate-id( WGBH_DESCRIPTION[last()])">
        <dc:description><xsl:value-of select="WGBH_DESCRIPTION[1]/@DESCRIPTION" /></dc:description>
	</xsl:when>
      <xsl:when test="WGBH_DESCRIPTION">
	<dc:description><xsl:value-of select="WGBH_DESCRIPTION[1]/@DESCRIPTION" /></dc:description>
      </xsl:when>
	</xsl:choose>
        <dcterms:dateAccepted><xsl:value-of select="@IMPORT_DT" /></dcterms:dateAccepted>
      <xsl:apply-templates />
    </oai_dc:dc>
  </xsl:template>
  <xsl:template match="WGBH_TYPE">
        <dc:type><xsl:value-of select="@ITEM_TYPE" /></dc:type>
  </xsl:template>
  <xsl:template match="WGBH_CONTRIBUTOR">
        <dc:contributor><xsl:value-of select="@CONTRIBUTOR_NAME" /></dc:contributor>
  </xsl:template>
  <xsl:template match="WGBH_PUBLISHER">
        <dc:publisher><xsl:value-of select="@PUBLISHER" /></dc:publisher>
  </xsl:template>
  <xsl:template match="WGBH_COVERAGE">
        <dc:coverage.PlaceName><xsl:value-of select="@EVENT_LOCATION" /></dc:coverage.PlaceName>
	<dcterms:spatial><xsl:value-of select="@EVENT_LOCATION" /></dcterms:spatial>
        <dc:date><xsl:value-of select="@DATE_PORTRAYED" /></dc:date>
	<dcterms:temporal><xsl:value-of select="@DATE_PORTRAYED" /></dcterms:temporal>
  </xsl:template>
  <xsl:template match="WGBH_FORMAT">
    <dc:format><xsl:value-of select="@ITEM_FORMAT" /></dc:format>
    <dc:format><xsl:value-of select="@MIME_TYPE" /></dc:format>
    <dc:format><xsl:value-of select="@BROADCAST_FORMAT" /></dc:format>
  </xsl:template>
  <xsl:template match="WGBH_RIGHTS[@RIGHTS_TYPE='Web']">
        <dc:rights><xsl:value-of select="@RIGHTS_NOTE" /></dc:rights>
  </xsl:template>
  <xsl:template match="WGBH_DESCRIPTION">
        <dcterms:extent><xsl:value-of select="@DESCRIPTION_COVERAGE" /></dcterms:extent>
  </xsl:template>
  <xsl:template match="text()|@*"></xsl:template>
</xsl:stylesheet>

<xsl:stylesheet xmlns="http://www.pbcore.org/PBCore/PBCoreNamespace.html" xmlns:ebucore="http://www.ebu.ch/metadata/schemas/EBUCore/ebuCoreMetadataSet.xsd" xmlns:fedora-rels-ext="info:fedora/fedora-system:def/relations-external#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:smil="http://www.w3.org/2001/SMIL20/Language" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<!--	<xsl:output method="xml" encoding="UTF-8"/> -->
  <xsl:template match="UOIS">
    <PBCoreDescriptionDocument>
      <xsl:apply-templates></xsl:apply-templates>
    </PBCoreDescriptionDocument>
  </xsl:template>
  <xsl:template match="text()|@*"></xsl:template>
  <xsl:template match="WGBH_IDENTIFIER[@NOLA_CODE != &apos;&apos;]">
    <pbcoreIdentifier>
      <identifier>
        <xsl:value-of select="@NOLA_CODE"></xsl:value-of>
      </identifier>
      <identifierSource>NOLA</identifierSource>
    </pbcoreIdentifier>
  </xsl:template>
  <xsl:template match="WGBH_SOURCE[@SOURCE_TYPE = &apos;Source Reference ID&apos;]">
    <pbcoreIdentifier>
      <identifier>
        <xsl:value-of select="@SOURCE"></xsl:value-of>
      </identifier>
      <identifierSource>Source Reference Number</identifierSource>
    </pbcoreIdentifier>
  </xsl:template>
  <xsl:template match="WGBH_TITLE[@TITLE_TYPE = &apos;File&apos;]">
    <pbcoreIdentifier>
      <identifier>
        <xsl:value-of select="@TITLE"></xsl:value-of>
      </identifier>
      <identifierSource>
        <xsl:value-of select="@TITLE_TYPE"></xsl:value-of>
      </identifierSource>
    </pbcoreIdentifier>
  </xsl:template>
  <xsl:template match="WGBH_TITLE">
    <pbcoreTitle>
      <title>
        <xsl:value-of select="@TITLE"></xsl:value-of>
      </title>
      <titleType>
        <xsl:value-of select="@TITLE_TYPE"></xsl:value-of>
      </titleType>
    </pbcoreTitle>
  </xsl:template>
  <xsl:template match="WGBH_DESCRIPTION[@DESCRIPTION_TYPE!=&apos;Other (see note)&apos;]">
    <pbcoreDescription>
      <description>
        <xsl:value-of select="@DESCRIPTION"></xsl:value-of>
      </description>
      <descriptionType>
        <xsl:value-of select="@DESCRIPTION_TYPE"></xsl:value-of>
      </descriptionType>
    </pbcoreDescription>
  </xsl:template>
  <xsl:template match="WGBH_DESCRIPTION[@DESCRIPTION_TYPE=&apos;Other (see note)&apos;]">
    <pbcoreDescription>
      <description>
        <xsl:value-of select="@DESCRIPTION"></xsl:value-of>
      </description>
      <descriptionType>Editorial Comments</descriptionType>
    </pbcoreDescription>
  </xsl:template>
  <xsl:template match="WGBH_SUBJECT[@SUBJECT_TYPE=&apos;Subject Heading&apos;]">
    <pbcoreSubject>
      <subject>
        <xsl:value-of select="@SUBJECT"></xsl:value-of>
      </subject>
      <subjectAuthorityUsed>
        <xsl:value-of select="@SUBJECT_TYPE"></xsl:value-of>
      </subjectAuthorityUsed>
    </pbcoreSubject>
  </xsl:template>
  <xsl:template match="WGBH_SUBJECT[@SUBJECT_TYPE=&apos;Geographical&apos;]">
    <pbcoreCoverage>
      <coverage>
        <xsl:value-of select="@SUBJECT"></xsl:value-of>
      </coverage>
      <coverageType>Spatial</coverageType>
    </pbcoreCoverage>
  </xsl:template>
  <xsl:template match="WGBH_SUBJECT[@SUBJECT_TYPE=&apos;Personal&apos;]">
    <pbcoreContributor>
      <contributor>
        <xsl:value-of select="@SUBJECT"></xsl:value-of>
      </contributor>
      <contributorRole>Subject</contributorRole>
    </pbcoreContributor>
  </xsl:template>
  <xsl:template match="WGBH_DATE_RELEASE">
    <pbcoreCoverage>
      <coverage>
        <xsl:value-of select="@DATE_RELEASE"></xsl:value-of>
      </coverage>
      <coverageType>Temporal</coverageType>
    </pbcoreCoverage>
  </xsl:template>
  <xsl:template match="WGBH_COVERAGE">
    <xsl:if test="@DATE_PORTRAYED != &apos;&apos;">
      <pbcoreCoverage>
        <coverage>
          <xsl:value-of select="@DATE_PORTRAYED"></xsl:value-of>
        </coverage>
        <coverageType>Temporal</coverageType>
      </pbcoreCoverage>
    </xsl:if>
    <xsl:if test="@EVENT_LOCATION != &apos;&apos;">
      <pbcoreCoverage>
        <coverage>
          <xsl:value-of select="@EVENT_LOCATION"></xsl:value-of>
        </coverage>
        <coverageType>Spatial</coverageType>
      </pbcoreCoverage>
    </xsl:if>
    <xsl:if test="@PRODUCTION_LOCATION != &apos;&apos;">
      <pbcoreCoverage>
        <coverage>
          <xsl:value-of select="@PRODUCTION_LOCATION"></xsl:value-of>
        </coverage>
        <coverageType>Spatial</coverageType>
      </pbcoreCoverage>
    </xsl:if>
  </xsl:template>
  <xsl:template match="WGBH_SUBJECT">
    <pbcoreSubject>
      <subject>
        <xsl:value-of select="@SUBJECT"></xsl:value-of>
      </subject>
      <subjectAuthorityUsed>
        <xsl:value-of select="@SUBJECT_TYPE"></xsl:value-of>
      </subjectAuthorityUsed>
    </pbcoreSubject>
  </xsl:template>
  <xsl:template match="WGBH_AUDIENCE">
    <pbcoreAudienceLevel>
      <audienceLevel>
        <xsl:value-of select="@AUDIENCE_LEVEL"></xsl:value-of>
      </audienceLevel>
    </pbcoreAudienceLevel>
  </xsl:template>
  <xsl:template match="WGBH_CONTRIBUTOR">
    <pbcoreContributor>
      <contributor>
        <xsl:value-of select="@CONTRIBUTOR_NAME"></xsl:value-of>
      </contributor>
      <contributorRole>
        <xsl:value-of select="@CONTRIBUTOR_ROLE"></xsl:value-of>
      </contributorRole>
    </pbcoreContributor>
  </xsl:template>
  <xsl:template match="WGBH_CREATOR">
    <pbcoreCreator>
      <creator>
        <xsl:value-of select="@CREATOR_NAME"></xsl:value-of>
      </creator>
      <creatorRole>
        <xsl:value-of select="@CREATOR_ROLE"></xsl:value-of>
      </creatorRole>
    </pbcoreCreator>
  </xsl:template>
  <xsl:template match="WGBH_PUBLISHER">
    <pbcorePublisher>
      <publisher>
        <xsl:value-of select="@PUBLISHER"></xsl:value-of>
      </publisher>
      <publisherRole>
        <xsl:value-of select="@PUBLISHER_TYPE"></xsl:value-of>
      </publisherRole>
    </pbcorePublisher>
  </xsl:template>
  <xsl:template match="WGBH_RIGHTS[@RIGHTS_CREDIT != &apos;&apos;]">
    <pbcoreRightsSummary>
      <rightsSummary>
        <xsl:value-of select="@RIGHTS_CREDIT"></xsl:value-of>
      </rightsSummary>
    </pbcoreRightsSummary>
  </xsl:template>
  <xsl:template match="WGBH_RIGHTS[@RIGHTS_TYPE = &apos;Web&apos;]">
    <pbcoreRightsSummary>
      <rightsSummary>
        <xsl:value-of select="@RIGHTS_NOTE"></xsl:value-of>
      </rightsSummary>
    </pbcoreRightsSummary>
  </xsl:template>
  <xsl:template match="WGBH_FORMAT">
    <pbcoreInstantiation>
      <formatStandard>
        <xsl:value-of select="@BROADCAST_FORMAT"></xsl:value-of>
      </formatStandard>
      <formatAspectRatio>
        <xsl:value-of select="@ASPECT_RATIO"></xsl:value-of>
      </formatAspectRatio>
      <formatDuration>
        <xsl:value-of select="@DURATION"></xsl:value-of>
      </formatDuration>
      <formatPhysical>
        <xsl:value-of select="@ITEM_FORMAT"></xsl:value-of>
      </formatPhysical>
      <formatColors>
        <xsl:value-of select="@COLOR"></xsl:value-of>
      </formatColors>
      <xsl:if test="@FORMAT_NOTE">
        <pbcoreAnnotation>
          <annotation>
            <xsl:value-of select="@FORMAT_NOTE"></xsl:value-of>
          </annotation>
        </pbcoreAnnotation>
      </xsl:if>
      <xsl:apply-templates mode="pbcoreInstantiation" select="//WGBH_SOURCE[@SOURCE_TYPE = &apos;Tracking Number&apos;]"></xsl:apply-templates>
      <xsl:apply-templates mode="pbcoreInstantiation" select="//WGBH_SOURCE[@SOURCE_TYPE != &apos;Publisher&apos;]"></xsl:apply-templates>
      <xsl:apply-templates mode="pbcoreInstantiation" select="//WGBH_TYPE"></xsl:apply-templates>
    </pbcoreInstantiation>
  </xsl:template>
  <xsl:template match="WGBH_SOURCE[@SOURCE_TYPE = &apos;Tracking Number&apos;]" mode="pbcoreInstantiation">
    <pbcoreFormatID>
      <formatIdentifier>
        <xsl:value-of select="@SOURCE"></xsl:value-of>
      </formatIdentifier>
      <formatIdentifierSource>wgbh.org/mars/barcode/</formatIdentifierSource>
    </pbcoreFormatID>
  </xsl:template>
  <xsl:template match="WGBH_TYPE" mode="pbcoreInstantiation">
    <formatGenerations>
      <xsl:value-of select="@ITEM_TYPE"></xsl:value-of>
    </formatGenerations>
  </xsl:template>
  <xsl:template match="WGBH_ANNOTATION" mode="pbcoreInstantiation">
    <pbcoreAnnotation>
      <annotation>
        <xsl:value-of select="@ANNOTATION"></xsl:value-of>
      </annotation>
    </pbcoreAnnotation>
  </xsl:template>
  <xsl:template match="WGBH_ANNOTATION[@ANNOTATION_TYPE = &apos;Publisher&apos;]">
    <pbcorePublisher>
      <publisher>
        <xsl:value-of select="@ANNOTATION"></xsl:value-of>
      </publisher>
      <publisherRole>Publisher</publisherRole>
    </pbcorePublisher>
  </xsl:template>
</xsl:stylesheet>

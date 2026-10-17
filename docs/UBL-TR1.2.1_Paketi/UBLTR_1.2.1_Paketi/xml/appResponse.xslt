<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:ccts="urn:un:unece:uncefact:documentation:2" xmlns:clm54217="urn:un:unece:uncefact:codelist:specification:54217:2001" xmlns:clm5639="urn:un:unece:uncefact:codelist:specification:5639:1988" xmlns:clm66411="urn:un:unece:uncefact:codelist:specification:66411:2001" xmlns:clmIANAMIMEMediaType="urn:un:unece:uncefact:codelist:specification:IANAMIMEMediaType:2003" xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:n1="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2" xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" xmlns:ubltr="urn:oasis:names:specification:ubl:schema:xsd:TurkishCustomizationExtensionComponents" xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:altova="http://www.altova.com">
	<xsl:output version="4.0" method="html" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>
	<xsl:param name="SV_OutputFormat" select="'HTML'"/>
	<xsl:variable name="XML" select="/"/>
<!--	<xsl:import-schema schema-location="..\xsd\maindoc\UBLTR-ApplicationResponse-2.0.xsd" namespace="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2"/> -->
	<xsl:template match="/">
		<html>
			<head>
				<title/>
				<style type="text/css">
					body {
						background-color: #FFFFFF;
						font-family: 'Tahoma', "Times New Roman", Times, serif;
						font-size: 11px;
						color: #666666;
					}
					
					h1, h2 {
						padding-bottom: 3px;
						padding-top: 3px;
						margin-bottom: 5px;
						text-transform: uppercase;
						font-family: Arial, Helvetica, sans-serif;
					}
					
					h1 {
						font-size: 1.4em;
						text-transform:none;
					}
					
					h2 {
						font-size: 1em;
						color: brown;
					}
					
					h3 {
						font-size: 1em;
						color: #333333;
						text-align: justify;
						margin: 0;
						padding: 0;
					}
					
					h4 {
						font-size: 1.1em;
						font-style: bold;
						font-family: Arial, Helvetica, sans-serif;
						color: #000000;
						margin: 0;
						padding: 0;
					}
					
					hr{
					    height:2px;
						color: #000000;
						background-color: #000000;
						border-bottom: 1px solid #000000;
					}
					
					p, ul, ol {
						margin-top: 1.5em;
					}
					
					ul, ol {
						margin-left: 3em;
					}
					
					blockquote {
						margin-left: 3em;
						margin-right: 3em;
						font-style: italic;
					}
					
					a {
						text-decoration: none;
						color: #70A300;
					}
					
					a:hover {
						border: none;
						color: #70A300;
					}
					
					#despatchTable{
						border-collapse:collapse;
						font-size:11px;
						float:right;
						border-color:gray;
					
					} 
					
					#ettnTable{
						border-collapse:collapse;
						font-size:11px;
						border-color:gray;
					}
					
					#customerPartyTable{
						border-width: 0px;
						border-spacing: ;
						border-style: inset;
						border-color: gray;
						border-collapse: collapse;
						background-color: 
					}
					
					#customerIDTable{
						border-width: 2px;
						border-spacing: ;
						border-style: inset;
						border-color: gray;
						border-collapse: collapse;
						background-color: 
					}
					
					#customerIDTableTd{
						border-width: 2px;
						border-spacing: ;
						border-style: inset;
						border-color: gray;
						border-collapse: collapse;
						background-color: 
					}
					
					#lineTable{
						border-width:2px;
						border-spacing: ;
						border-style: inset;
						border-color: black;
						border-collapse: collapse;
						background-color: ;
					}
					
					#lineTableTd{
						border-width: 1px;
						padding: 1px;
						border-style: inset;
						border-color: black;
						background-color: white;
					}
					
					#lineTableTr{
						border-width: 1px;
						padding: 0px;
						border-style: inset;
						border-color: black;
						background-color: white;
						-moz-border-radius: ;
					}
					
					#lineTableDummyTd {
						border-width: 1px;
						border-color:white;
						padding: 1px;
						border-style: inset;
						border-color: black;
						background-color: white;
					}
					
					#lineTableBudgetTd{
					border-width: 2px;
						border-spacing:0px;
						padding: 1px;
						border-style: inset;
						border-color: black;
						background-color: white;
						-moz-border-radius: ;
					}
					
					#notesTable{
						
						border-width: 2px;
						border-spacing: ;
						border-style: inset;
						border-color: black;
						border-collapse: collapse;
						background-color:
					}
					
					#notesTableTd{
						
						
						border-width: 0px;
						border-spacing: ;
						border-style: inset;
						border-color: black;
						border-collapse: collapse;
						background-color:
					}
					
					table{
						
						border-spacing:0px;
						
					}
					
					#budgetContainerTable{
						
						border-width: 0px;
						border-spacing: 0px;
						border-style: inset;
						border-color: black;
						border-collapse: collapse;
						background-color: ;
						
					}
					
					td{
						border-color:gray;
					}
				</style>
			</head>
			<body>
				<table border="0" >
					<tbody>
						<tr>
							<td align="right" colspan="2">
								<h1 align="right">
									<span>
										<xsl:text>UYGULAMA YANITI</xsl:text>
									</span>
								</h1>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<hr/>
							</td>
						</tr>
						<tr>
							<td valign="top" >
								<h2>
									<span>
										<xsl:text>GÖNDEREN TARAF</xsl:text>
									</span>
								</h2>
								<table border="0">
									<tbody>
										
											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
															<xsl:for-each select="cac:Person">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Ünvanı/Adı Soyadı:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
															<xsl:for-each select="cac:PartyName">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Ünvanı/Adı Soyadı:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
															<xsl:for-each select="cac:PartyIdentification">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:value-of select="cbc:ID/@schemeID"/><xsl:text>:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
																			<xsl:for-each select="cac:PostalAddress">
																				<tr>
																					<th valign="top">
																						<h3>
																							<span>
																								<xsl:text>Adres:</xsl:text>
																							</span>
																						</h3>
																					</th>
																					<td>
																						<table border="0">
																						<tbody>
																							<xsl:for-each select="cbc:StreetName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:BlockName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:BuildingName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:BuildingNumber">
																								<tr><td><xsl:text>No: </xsl:text><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:CitySubdivisionName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:PostalZone">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<tr><td>
																								<xsl:for-each select="cbc:CityName">
																									<xsl:apply-templates/>
																								</xsl:for-each>
																								<xsl:for-each select="cbc:Region">
																									<xsl:text>, </xsl:text><xsl:apply-templates/>
																								</xsl:for-each>
																								<xsl:for-each select="cbc:District">
																									<xsl:text>, </xsl:text><xsl:apply-templates/>
																								</xsl:for-each>
																								<xsl:for-each select="cac:Country">
																									<xsl:for-each select="cbc:Name">
																										<xsl:text>, </xsl:text><xsl:apply-templates/>
																									</xsl:for-each>
																								</xsl:for-each>
																							</td></tr>
																						</tbody>
																						</table>
																					</td>
																				</tr>
																			</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
														<xsl:for-each select="cac:Contact">
															<xsl:for-each select="cbc:Telephone">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Tel:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
															<xsl:for-each select="cbc:Telefax">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Fax:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
															<xsl:for-each select="cbc:ElectronicMail">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>E-Posta:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
															<xsl:for-each select="cac:OtherCommunication">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Diğer İletişim:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
															<xsl:for-each select="cbc:WebsiteURI">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Web Sitesi URI:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
											
											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:SenderParty">
														<xsl:for-each select="cac:AgentParty">
															<xsl:for-each select="cac:PartyIdentification">
																<xsl:for-each select="cbc:ID">
																	<tr>
																		<th>
																			<h3>
																				<span>
																					<xsl:text>Şube </xsl:text><xsl:value-of select="@schemeID"/><xsl:text>:</xsl:text>
																				</span>
																			</h3>
																		</th>
																		<td>
																			<xsl:apply-templates/>
																		</td>
																	</tr>
																</xsl:for-each>
															</xsl:for-each>
															<xsl:for-each select="cac:PartyName">
																<xsl:for-each select="cbc:Name">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Şube Adı:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
																</xsl:for-each>
															</xsl:for-each>
														</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
									</tbody>
								</table>
								<h2>
									<span>
										<xsl:text>ALAN TARAF</xsl:text>
									</span>
								</h2>
									<table border="0">
									<tbody>
										
											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
															<xsl:for-each select="cac:Person">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Ünvanı/Adı Soyadı:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
															<xsl:for-each select="cac:PartyName">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Ünvanı/Adı Soyadı:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
															<xsl:for-each select="cac:PartyIdentification">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:value-of select="cbc:ID/@schemeID"/><xsl:text>:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
																			<xsl:for-each select="cac:PostalAddress">
																				<tr>
																					<th valign="top">
																						<h3>
																							<span>
																								<xsl:text>Adres:</xsl:text>
																							</span>
																						</h3>
																					</th>
																					<td>
																						<table border="0">
																						<tbody>
																							<xsl:for-each select="cbc:StreetName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:BlockName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:BuildingName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:BuildingNumber">
																								<tr><td><xsl:text>No: </xsl:text><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:CitySubdivisionName">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<xsl:for-each select="cbc:PostalZone">
																								<tr><td><xsl:apply-templates/></td></tr>
																							</xsl:for-each>
																							<tr><td>
																								<xsl:for-each select="cbc:CityName">
																									<xsl:apply-templates/>
																								</xsl:for-each>
																								<xsl:for-each select="cbc:Region">
																									<xsl:text>, </xsl:text><xsl:apply-templates/>
																								</xsl:for-each>
																								<xsl:for-each select="cbc:District">
																									<xsl:text>, </xsl:text><xsl:apply-templates/>
																								</xsl:for-each>
																								<xsl:for-each select="cac:Country">
																									<xsl:for-each select="cbc:Name">
																										<xsl:text>, </xsl:text><xsl:apply-templates/>
																									</xsl:for-each>
																								</xsl:for-each>
																							</td></tr>
																						</tbody>
																						</table>
																					</td>
																				</tr>
																			</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>


											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
															<xsl:for-each select="cac:PartyTaxScheme">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Vergi Dairesi:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
														<xsl:for-each select="cac:Contact">
															<xsl:for-each select="cbc:Telephone">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Tel:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
															<xsl:for-each select="cbc:Telefax">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Fax:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
															<xsl:for-each select="cbc:ElectronicMail">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>E-Posta:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
															<xsl:for-each select="cac:OtherCommunication">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Diğer İletişim:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>

											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
															<xsl:for-each select="cbc:WebsiteURI">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Web Sitesi URI:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
															</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
											
											<xsl:for-each select="$XML">
												<xsl:for-each select="n1:ApplicationResponse">
													<xsl:for-each select="cac:ReceiverParty">
														<xsl:for-each select="cac:AgentParty">
															<xsl:for-each select="cac:PartyIdentification">
																<xsl:for-each select="cbc:ID">
																	<tr>
																		<th>
																			<h3>
																				<span>
																					<xsl:text>Şube </xsl:text><xsl:value-of select="@schemeID"/><xsl:text>:</xsl:text>
																				</span>
																			</h3>
																		</th>
																		<td>
																			<xsl:apply-templates/>
																		</td>
																	</tr>
																</xsl:for-each>
															</xsl:for-each>
															<xsl:for-each select="cac:PartyName">
																<xsl:for-each select="cbc:Name">
																<tr>
																	<th>
																		<h3>
																			<span>
																				<xsl:text>Şube Adı:</xsl:text>
																			</span>
																		</h3>
																	</th>
																	<td>
																		<xsl:apply-templates/>
																	</td>
																</tr>
																</xsl:for-each>
															</xsl:for-each>
														</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
									</tbody>
								</table>
								<br/>
							</td>
							<td valign="top" >
								<table border="0">
									<tbody>
										<tr>
											<td>
												<h2>
													<span>
														<xsl:text>BELGE BİLGİLERİ</xsl:text>
													</span>
												</h2>
											</td>
											<td/>
										</tr>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:UBLVersionID">
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>UBL Sürüm Numarası:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:CustomizationID">
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>Düzenleme Sürüm Numarası:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:ProfileID">										
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>Senaryo Adı:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
	
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:ID">										
													<tr>
														<td height="1">
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>Uygulama Yanıtı No:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:UUID">										
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>ETTN:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:IssueDate">										
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>Gönderim Tarihi:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>

										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:IssueTime">
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>Gönderim Zamanı:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cbc:Note">										
													<tr>
														<td>
															<h3>
																<span style="font-weight:bold; ">
																	<xsl:text>Not:</xsl:text>
																</span>
															</h3>
														</td>
														<td>
															<xsl:apply-templates/>
														</td>
													</tr>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<tr>
											<td/>
											<td/>
										</tr>
										<tr>
											<td>
												<h2>
													<span>
														<xsl:text>CEVAP BİLGİLERİ</xsl:text>
													</span>
												</h2>
											</td>
											<td/>
										</tr>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:Response">
														<xsl:for-each select="cbc:ReferenceID">										
															<tr>
																<th>
																	<h3>
																		<span>
																			<xsl:text>Referans Numarası</xsl:text>
																		</span>
																	</h3>
																</th>
																<td>
																	<xsl:apply-templates/>
																</td>
															</tr>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>										
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:Response">
														<xsl:for-each select="cbc:ResponseCode">										
															<tr>
																<th>
																	<h3>
																		<span>
																			<xsl:text>Cevap Kodu</xsl:text>
																		</span>
																	</h3>
																</th>
																<td>
																	<xsl:apply-templates/>
																</td>
															</tr>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>

										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:Response">
														<xsl:for-each select="cbc:Description">										
															<tr>
																<th>
																	<h3>
																		<span>
																			<xsl:text>Cevap Tanımı</xsl:text>
																		</span>
																	</h3>
																</th>
																<td>
																	<xsl:apply-templates/>
																</td>
															</tr>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>										
										
										<tr>
											<td/>
											<td/>
										</tr>
										<tr>
											<td>
												<h2>
													<span>
														<xsl:text>REFERANS BELGE BİLGİLERİ</xsl:text>
													</span>
												</h2>
											</td>
											<td/>
										</tr>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:DocumentReference">
														<xsl:for-each select="cbc:ID">										
															<tr>
																<th>
																	<h3>
																		<span>
																			<xsl:text>Belge No</xsl:text>
																		</span>
																	</h3>
																</th>
																<td>
																	<xsl:apply-templates/>
																</td>
															</tr>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:DocumentReference">
														<xsl:for-each select="cbc:DocumentTypeCode">										
															<tr>
																<th>
																	<h3>
																		<span>
																			<xsl:text>Belge Türü Kodu</xsl:text>
																		</span>
																	</h3>
																</th>
																<td>
																	<xsl:apply-templates/>
																</td>
															</tr>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>										
										
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:DocumentReference">
														<xsl:for-each select="cbc:DocumentType">										
															<tr>
																<th>
																	<h3>
																		<span>
																			<xsl:text>Belge Türü</xsl:text>
																		</span>
																	</h3>
																</th>
																<td>
																	<xsl:apply-templates/>
																</td>
															</tr>
														</xsl:for-each>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>										
									</tbody>
								</table>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<hr/>
							</td>
						</tr>
						
						<tr>
							<td colspan="2">
								<h2>
									<span>
										<xsl:text>SATIR CEVAPLARI</xsl:text>
									</span>
								</h2>
							</td>
						</tr>

						<tr>
							<td colspan="2">
								<table border="1">
									<thead>
										<tr>
											<th colspan="2">
												<span>
													<xsl:text>Satır Referansı</xsl:text>
												</span>
											</th>
											<th colspan="3">
												<span>
													<xsl:text>Satır Cevabı</xsl:text>
												</span>
											</th>
										</tr>
										<tr>
											<th>
												<span>
													<xsl:text>Satır Numarası / ID</xsl:text>
												</span>
											</th>
											<th>
												<span>
													<xsl:text>Belge Referansı</xsl:text>
												</span>
											</th>
											<th>
												<span>
													<xsl:text>Cevap Referans Numarası / ID</xsl:text>
												</span>
											</th>
											<th>
												<span>
													<xsl:text>Cevap Kodu</xsl:text>
												</span>
											</th>
											<th>
												<span>
													<xsl:text>Tanım</xsl:text>
												</span>
											</th>
										</tr>
									</thead>
									<tbody>
										<xsl:for-each select="$XML">
											<xsl:for-each select="n1:ApplicationResponse">
												<xsl:for-each select="cac:DocumentResponse">
													<xsl:for-each select="cac:LineResponse">
														<tr>
															<xsl:for-each select="cac:LineReference">
																<td>
																	<xsl:for-each select="cbc:LineID">
																		<xsl:apply-templates/>
																	</xsl:for-each>
																</td>
																<td>
																	<xsl:for-each select="cac:DocumentReference">
																		<xsl:for-each select="cbc:ID">
																			<xsl:apply-templates/>
																		</xsl:for-each>
																	</xsl:for-each>
																</td>
															</xsl:for-each>
														
															<xsl:for-each select="cac:Response">
																<td>
																	<xsl:for-each select="cbc:ReferenceID">
																		<xsl:apply-templates/>
																	</xsl:for-each>
																</td>
																<td>
																	<xsl:for-each select="cbc:ResponseCode">
																		<xsl:apply-templates/>
																	</xsl:for-each>
																</td>
																<td>
																	<xsl:for-each select="cbc:Description">
																		<xsl:apply-templates/>
																	</xsl:for-each>
																</td>
															</xsl:for-each>
														</tr>
													</xsl:for-each>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:for-each>		
									</tbody>
								</table>
							</td>
						</tr>

						<tr>
							<td colspan="2">
								<hr/>
							</td>
						</tr>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>

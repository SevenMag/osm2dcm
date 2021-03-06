VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsAddrRegistry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'***************************************************************************
'�������� ������
'***************************************************************************
Option Explicit

'��������� ����� � �����������
Const RS_ADDR_HOUSENUMER = "HouseNumber"
Const RS_ADDR_STREET = "Street"
Const RS_ADDR_CITY = "City"
Const RS_ADDR_COORDS = "Coords"
Const RS_ADDR_ERROR = "Error"
Const RS_ROUTABLE = "Routable"
Const RS_HAS_HOUSES = "HasHouses"

'������
Const RS_CITY_NAME = "Name"
Const RS_CITY_POPULATION = "Population"
Const RS_CITY_COORDS = "Coords"
Const RS_CITY_VALID = "Valid"
Const RS_CITY_URBANTYPE = "UrbanType"
Const RS_CITY_ORIGTYPE = "OrigType"

'���������� � �������
Dim rsCities     As ADODB.Recordset
Dim rsCityPolies As ADODB.Recordset
Dim rsStreets    As ADODB.Recordset
Dim rsHouses     As ADODB.Recordset

'������������ ���� �������
Const otCity = "0x0300" '-city
Const otTown = "0x0800"    '-town
Const otVillage = "0x0C00" '-village
Const otHamlet = "0x0F00" '-hamlet

'���� �������� ������
Const steOK = 0
Const steOutsideCity = 1
Const steStreetNotSet = 2
Const steStreetNotFound = 3
Const steStreetNotRelatedToCity = 4
Const steNumberRelatedToTerritory = 5
Const steStreetNotRoutable = 6
Private Sub Class_Initialize()

 On Error GoTo finalize
  Set rsHouses = New ADODB.Recordset
  rsHouses.Fields.Append RS_ADDR_HOUSENUMER, adWChar, 255
  rsHouses.Fields.Append RS_ADDR_STREET, adWChar, 255
  rsHouses.Fields.Append RS_ADDR_CITY, adWChar, 255
  rsHouses.Fields.Append RS_ADDR_COORDS, adWChar, 255
  rsHouses.Fields.Append RS_ADDR_ERROR, adInteger
  rsHouses.Open
  
  '�����
  Set rsStreets = New ADODB.Recordset
  rsStreets.Fields.Append RS_ADDR_STREET, adWChar, 255
  rsStreets.Fields.Append RS_ADDR_CITY, adWChar, 255
  rsStreets.Fields.Append RS_ROUTABLE, adInteger
  rsStreets.Fields.Append RS_ADDR_COORDS, adWChar, 255
  rsStreets.Fields.Append RS_HAS_HOUSES, adInteger

  rsStreets.Open
  rsStreets(RS_ADDR_STREET).Properties("Optimize") = True
  rsStreets(RS_ADDR_CITY).Properties("Optimize") = True
  
  '������
  Set rsCities = New ADODB.Recordset
  rsCities.Fields.Append RS_CITY_NAME, adWChar, 255
  rsCities.Fields.Append RS_CITY_POPULATION, adInteger
  rsCities.Fields.Append RS_CITY_COORDS, adWChar, 255
  rsCities.Fields.Append RS_CITY_VALID, adInteger
  rsCities.Fields.Append RS_CITY_ORIGTYPE, adWChar, 255
  rsCities.Open
  
  Set rsCityPolies = New ADODB.Recordset
  rsCityPolies.Fields.Append RS_CITY_NAME, adWChar, 255
  rsCityPolies.Fields.Append RS_CITY_URBANTYPE, adInteger
  rsCityPolies.Fields.Append RS_CITY_COORDS, adWChar, 255
  rsCityPolies.Fields.Append RS_CITY_VALID, adInteger
  rsCityPolies.Open
  rsCityPolies(RS_CITY_NAME).Properties("Optimize") = True
finalize:
  If Err.Number <> 0 Then
    Err.Raise Err.Number, "ProcessMP", Err.Description & " clsAddrRegistry.Initialize:" & Erl
  End If
End Sub

Private Sub Class_Terminate()
  Set rsHouses = Nothing
  Set rsStreets = Nothing
End Sub

Public Sub AddHouseToRegistry(strHouseNumber As String, _
                              strStreetDesc As String, _
                              strCity As String, strCoords As String)

 rsHouses.AddNew
 rsHouses(RS_ADDR_CITY).Value = strCity
 rsHouses(RS_ADDR_STREET).Value = strStreetDesc
 rsHouses(RS_ADDR_HOUSENUMER).Value = strHouseNumber
 rsHouses(RS_ADDR_COORDS).Value = strCoords
End Sub
Public Sub AddStreetToRegistry(strStreetDesc As String, strCity As String, blnRoutable As Boolean, strCoords As String)
Dim varFilter

 varFilter = rsStreets.Filter
' Debug.Print strCity, strStreetDesc
 rsStreets.Filter = RS_ADDR_CITY & "= '" & StrForFilter(strCity) & "' AND " & _
                    RS_ADDR_STREET & "= '" & StrForFilter(strStreetDesc) & "'"
 If rsStreets.RecordCount = 0 Then
   rsStreets.AddNew
   rsStreets(RS_ADDR_CITY).Value = strCity
   rsStreets(RS_ADDR_STREET).Value = strStreetDesc
   rsStreets(RS_ROUTABLE).Value = 0
   rsStreets(RS_HAS_HOUSES).Value = 0
   rsStreets(RS_ADDR_COORDS).Value = strCoords
 End If
 
 '� ����� �� ���������� ����� ��������� �����.
 If blnRoutable Then
   rsStreets(RS_ROUTABLE).Value = 1
 End If
 rsStreets.Filter = varFilter
End Sub

'���������� ������, ��� ������, ��� � �����
Public Sub AddCityToRegistry(strCityName As String, _
                             strCoords As String, _
                             intPopulation As Long, _
                             blnPolygon As Boolean, _
                             blnUrban As Boolean, _
                             strOrigType As String)
  If blnPolygon Then
    rsCityPolies.AddNew
    rsCityPolies(RS_CITY_NAME).Value = strCityName
    rsCityPolies(RS_CITY_URBANTYPE).Value = IIf(blnUrban, 1, 0)
    rsCityPolies(RS_CITY_COORDS).Value = strCoords
  Else
    rsCities.AddNew
    rsCities(RS_CITY_NAME).Value = strCityName
    rsCities(RS_CITY_POPULATION).Value = intPopulation
    rsCities(RS_CITY_COORDS).Value = strCoords
    rsCities(RS_CITY_ORIGTYPE).Value = strOrigType
  End If
 
End Sub

Public Function CheckStreet(strStreetDesc As String, strCity As String) As Integer
 Dim varFilter
 varFilter = rsStreets.Filter
  
' If Trim(strStreetDesc) = "�.��������" Then
'   Debug.Print strStreetDesc
' End If
 
 '����� �� ������.
 ' �� ����� ���� ��� ������������� ������, �� ���� �� �� ��� �� �������� ��������.
 ' C����� �� �� ������� ���� 101 �� �8

 If Trim$(strCity) = "" Then
   CheckStreet = steOutsideCity
   GoTo fin
 End If
 
 '����� �� ������.
 ' ��� ���� ������������� ������, �� ����� ������� ��� ���-�� ������ ���� ������
 If Trim$(strStreetDesc) = "" Then
   CheckStreet = steStreetNotSet
   GoTo fin
 End If
 
 '������ �������� ������ �����, � ������� ��������� ���.
 rsStreets.Filter = RS_ADDR_CITY & "= '" & StrForFilter(strCity) & "' AND " & _
                    RS_ADDR_STREET & "= '" & StrForFilter(strStreetDesc) & "'"
 
 '���� ����� ���� �� ���� ���������� �����
 If rsStreets.RecordCount > 0 Then
   If rsStreets(RS_ROUTABLE).Value <> 0 Then
    CheckStreet = steOK
   Else
    CheckStreet = steStreetNotRoutable
   End If
   '����� �������, ��� ����������� �����
   GoTo fin
 End If
 
 '���������� ������ ������
 ' ����� ����� ������������ � ������ ����������� ������ ��� ��������.
 ' �������� ����� ����� �������� ������
 If strCity = strStreetDesc Then
   CheckStreet = steNumberRelatedToTerritory
   GoTo fin
 End If
 
 '�������� "�����" �������� ����� "����������" ��� �������.
 '��� �������� ������������ ������ � "�����������" ������, ������ ��� ���� ������ ���������� �����������
 ' �������� ������������ �������� ��������. hw=service
 strStreetDesc = LCase$(strStreetDesc)
 If InStr(LCase$(strStreetDesc), "����������") <> 0 Or InStr(LCase$(strStreetDesc), "����.") <> 0 Or InStr(LCase$(strStreetDesc), "�������") Or InStr(LCase$(strStreetDesc), "�������") Then
   CheckStreet = steNumberRelatedToTerritory
   GoTo fin
 End If
 
 ' ��������� �������
 '����� ����� ��������������, �� ���� �� ������������ ������.
 rsStreets.Filter = RS_ADDR_CITY & "= '' AND " & _
                    RS_ADDR_STREET & "= '" & StrForFilter(strStreetDesc) & "'"
 
 '���� ����� ���� �� ���� �����
 If rsStreets.RecordCount > 0 Then
   If rsStreets(RS_ROUTABLE).Value <> 0 Then
    CheckStreet = steStreetNotRelatedToCity
   Else
    CheckStreet = steStreetNotRoutable
   End If
   rsStreets(RS_HAS_HOUSES).Value = 1
   GoTo fin
 End If
 
  
 '������ ������ �����
 CheckStreet = steStreetNotFound ' ����� ����� ������ ���
  
 
fin:
 rsStreets.Filter = varFilter

End Function

'�������� ����� �� ����������
' �������� ������� - ������� �������������� �����
Public Sub ValidateHouses()
  
  '����
  rsHouses.Filter = adFilterNone
  
  Do While Not rsHouses.EOF
     rsHouses(RS_ADDR_ERROR).Value = CheckStreet(rsHouses(RS_ADDR_STREET).Value, rsHouses(RS_ADDR_CITY).Value)
     rsHouses.MoveNext
  Loop
 
End Sub

'�������� ������� �� ����������
' ������� ������������� ������
' ������� population
Public Sub ValidateCities()
  
 rsCities.Filter = adFilterNone
 Do While Not rsCities.EOF
   'population
   '����� ��������� population ������ ��� city � town
   If ((rsCities(RS_CITY_ORIGTYPE).Value = otCity) Or (rsCities(RS_CITY_ORIGTYPE).Value = otTown)) Then
     If (rsCities(RS_CITY_POPULATION).Value = 0) Then
       rsCities(RS_CITY_POPULATION).Value = -1
     End If
   End If
   
   '������������� �������
   rsCityPolies.Filter = RS_CITY_NAME & "='" & StrForFilter(rsCities(RS_CITY_NAME).Value) & "'"
   If rsCityPolies.RecordCount <> 0 Then
     rsCities(RS_CITY_VALID).Value = 1
   Else
     '� �� ��� ������������� ������
     If Not ((rsCities(RS_CITY_ORIGTYPE).Value = otHamlet) Or (rsCities(RS_CITY_ORIGTYPE).Value = otVillage)) Then
       rsCities(RS_CITY_VALID).Value = 0
     Else
       rsCities(RS_CITY_VALID).Value = 1 ' ��� �������� ��������� ������� �� �����.
      ' Debug.Print rsCities(RS_CITY_NAME).Value, rsCities(RS_CITY_ORIGTYPE).Value
     End If
   End If
   
   rsCities.MoveNext
 Loop
End Sub

'"��������" ����, ����� �������, ��� ������� ���� �������, �� ��� �����.
Public Sub ValidateCitiesReverse()
  
 rsCityPolies.Filter = adFilterNone
 Do While Not rsCityPolies.EOF
   
   '������������� �������
   rsCities.Filter = RS_CITY_NAME & "='" & StrForFilter(rsCityPolies(RS_CITY_NAME).Value) & "'"
   If rsCities.RecordCount <> 0 Then
     rsCityPolies(RS_CITY_VALID).Value = 1
   Else
     '� �� ��� ������������� ������
     rsCityPolies(RS_CITY_VALID).Value = 0
     Debug.Print rsCityPolies(RS_CITY_NAME).Value
   End If
   
   rsCityPolies.MoveNext
 Loop
End Sub

'C��������� ������ ������ � xml
Public Sub PrintRegistryToXML()
  Dim intTotalHouses      As Long
  Dim intTotalStreets     As Long
  Dim intUnmatchedHouses  As Long
  
  Dim intHousesStreetNotFound     As Long
  Dim intHousesStreetNotSet       As Long
  Dim intHousesStreetNotRelatedToCity  As Long
  Dim intHousesStreetNotRoutableCG  As Long
  Dim intHousesNumberRelatedToTerritory As Long
  
  Dim intHousesWOCities   As Long
  Dim intCitiesWOPopulation As Long
  Dim intCitiesWOBounds   As Long
  Dim intCitiesWONodes    As Long
  Dim dblErrorRate        As Double
  Dim lat                 As String
  Dim lon                 As String
  
    
  
  
  rsHouses.Filter = adFilterNone
  rsStreets.Filter = adFilterNone
  rsHouses.Sort = RS_ADDR_CITY & ", " & RS_ADDR_STREET & ", " & RS_ADDR_HOUSENUMER
  intTotalHouses = rsHouses.RecordCount
  intTotalStreets = rsStreets.RecordCount
    
  '������ �� ����� ��� �������
  rsHouses.Filter = RS_ADDR_CITY & " = ''"
  intHousesWOCities = rsHouses.RecordCount
  
  rsHouses.Filter = RS_ADDR_ERROR & " = " & steStreetNotSet
  intHousesStreetNotSet = rsHouses.RecordCount
  
  rsHouses.Filter = RS_ADDR_ERROR & " = " & steStreetNotFound
  intHousesStreetNotFound = rsHouses.RecordCount
  
  rsHouses.Filter = RS_ADDR_ERROR & " = " & steStreetNotRelatedToCity
  intHousesStreetNotRelatedToCity = rsHouses.RecordCount
  
  rsHouses.Filter = RS_ADDR_ERROR & " = " & steNumberRelatedToTerritory
  intHousesNumberRelatedToTerritory = rsHouses.RecordCount
  
  rsHouses.Filter = RS_ADDR_ERROR & " = " & steStreetNotRoutable
  intHousesStreetNotRoutableCG = rsHouses.RecordCount
  
  '������ �� "���������������� �����"
  rsHouses.Filter = RS_ADDR_ERROR & " <> 0"
  intUnmatchedHouses = rsHouses.RecordCount
  If intTotalHouses <> 0 Then
    dblErrorRate = intUnmatchedHouses / intTotalHouses
  Else
    dblErrorRate = 0
  End If
    
  '����� ������� ��� ���������
  rsCities.Filter = RS_CITY_POPULATION & "=-1"
  intCitiesWOPopulation = rsCities.RecordCount
    
  '����� ������� ��� ������������� ������
  rsCities.Filter = RS_CITY_VALID & "=0"
  intCitiesWOBounds = rsCities.RecordCount
     
  '����� ������� ��� �����
  rsCityPolies.Filter = RS_CITY_VALID & "=0"
  intCitiesWONodes = rsCityPolies.RecordCount
  Print #4, "<AddressTest>"
  
  Print #4, "<Summary>"
  Print #4, " <TotalHouses>" & intTotalHouses & "</TotalHouses>"
  Print #4, " <TotalStreets>" & intTotalStreets & "</TotalStreets>"
  Print #4, " <UnmatchedHouses>" & intUnmatchedHouses & "</UnmatchedHouses>"
  Print #4, " <HousesWOCities>" & intHousesWOCities & "</HousesWOCities>"
  Print #4, " <HousesStreetNotSet>" & intHousesStreetNotSet & "</HousesStreetNotSet>"
  Print #4, " <HousesStreetNotFound>" & intHousesStreetNotFound & "</HousesStreetNotFound>"
  Print #4, " <HousesStreetNotRelatedToCity>" & intHousesStreetNotRelatedToCity & "</HousesStreetNotRelatedToCity>"
  Print #4, " <HousesStreetNotRoutable>" & intHousesStreetNotRoutableCG & "</HousesStreetNotRoutable>"
  Print #4, " <HousesNumberRelatedToTerritory>" & intHousesNumberRelatedToTerritory & "</HousesNumberRelatedToTerritory>"
    
  Print #4, " <CitiesWithoutPopulation>" & intCitiesWOPopulation & "</CitiesWithoutPopulation>"
  Print #4, " <CitiesWithoutPlacePolygon>" & intCitiesWOBounds & "</CitiesWithoutPlacePolygon>"
  Print #4, " <CitiesWithoutPlaceNode>" & intCitiesWONodes & "</CitiesWithoutPlaceNode>"
  Print #4, " <ErrorRate>" & dblErrorRate & "</ErrorRate>"
  
  Print #4, "</Summary>"
  
  '������ ��� ���������
  Print #4, "<CitiesWithoutPopulation>"
  rsCities.Sort = RS_CITY_NAME
  rsCities.Filter = RS_CITY_POPULATION & "=-1"
  Do While Not rsCities.EOF
    Print #4, "<City>"
    Print #4, " <City>" & MakeXmlString(rsCities(RS_CITY_NAME).Value) & "</City>"
    Print #4, " <Coord>"
    GetLatLon lat, lon, rsCities(RS_CITY_COORDS).Value
    Print #4, "   <lat>" & lat & "</lat>"
    Print #4, "   <lon>" & lon & "</lon>"
    Print #4, " </Coord>"
    Print #4, "</City>"
    rsCities.MoveNext
  Loop
  Print #4, "</CitiesWithoutPopulation>"
  
  '������ ��� �������� place
  Print #4, "<CitiesWithoutPlacePolygon>"
  rsCities.Filter = RS_CITY_VALID & "=0"
  Do While Not rsCities.EOF
    Print #4, "<City>"
    Print #4, " <City>" & MakeXmlString(rsCities(RS_CITY_NAME).Value) & "</City>"
    Print #4, " <Coord>"
    GetLatLon lat, lon, rsCities(RS_CITY_COORDS).Value
    Print #4, "   <lat>" & lat & "</lat>"
    Print #4, "   <lon>" & lon & "</lon>"
    Print #4, " </Coord>"
    Print #4, "</City>"
    rsCities.MoveNext
  Loop
  Print #4, "</CitiesWithoutPlacePolygon>"
  
  '������ c ��������� place, �� ��� �����
  Print #4, "<CitiesWithoutPlaceNode>"
  rsCityPolies.Filter = RS_CITY_VALID & "=0"
  Do While Not rsCityPolies.EOF
    Print #4, "<City>"
    Print #4, " <City>" & MakeXmlString(rsCityPolies(RS_CITY_NAME).Value) & "</City>"
    Print #4, " <Coord>"
    GetLatLon lat, lon, rsCityPolies(RS_CITY_COORDS).Value
    Print #4, "   <lat>" & lat & "</lat>"
    Print #4, "   <lon>" & lon & "</lon>"
    Print #4, " </Coord>"
    Print #4, "</City>"
    rsCityPolies.MoveNext
  Loop
  Print #4, "</CitiesWithoutPlaceNode>"
  
  '����� �������
  Print #4, "<AddressErrorList>"
  
  rsHouses.Filter = RS_ADDR_ERROR & " <> 0"
  Do While Not rsHouses.EOF
    Print #4, "<House>"
    Print #4, " <ErrType>" & MakeXmlString(rsHouses(RS_ADDR_ERROR).Value) & "</ErrType>"
    Print #4, " <City>" & MakeXmlString(rsHouses(RS_ADDR_CITY).Value) & "</City>"
    Print #4, " <Street>" & MakeXmlString(rsHouses(RS_ADDR_STREET).Value) & "</Street>"
    Print #4, " <HouseNumber>" & MakeXmlString(rsHouses(RS_ADDR_HOUSENUMER).Value) & "</HouseNumber>"
    Print #4, " <Coord>"
    GetLatLon lat, lon, rsHouses(RS_ADDR_COORDS).Value
    Print #4, "   <lat>" & lat & "</lat>"
    Print #4, "   <lon>" & lon & "</lon>"
    Print #4, " </Coord>"
   ' Print #4, " <JosmLink>" & MakeXmlString(MakeJOSMLink(rsHouses(RS_ADDR_COORDS).Value)) & "</JosmLink>"
    Print #4, "</House>"
    rsHouses.MoveNext
  Loop
  
  Print #4, "</AddressErrorList>"
  
  Print #4, "<StreetErrors>"
  '���, ������, �����, �� ������� ���� ����, �� ������� �� ������� � ��
  rsStreets.Filter = RS_ADDR_CITY & "= '' AND " & _
                     RS_HAS_HOUSES & "<> '0'"
  Do While Not rsStreets.EOF
    Print #4, "<Street>"
    Print #4, " <ErrType>1</ErrType>"
    Print #4, " <City>" & MakeXmlString(rsStreets(RS_ADDR_CITY).Value) & "</City>"
    Print #4, " <Street>" & MakeXmlString(rsStreets(RS_ADDR_STREET).Value) & "</Street>"
    Print #4, " <Routable>" & MakeXmlString(rsStreets(RS_ROUTABLE).Value) & "</Routable>"
    Print #4, " <Coord>"
    GetLatLon lat, lon, rsStreets(RS_ADDR_COORDS).Value
    Print #4, "   <lat>" & lat & "</lat>"
    Print #4, "   <lon>" & lon & "</lon>"
    Print #4, " </Coord>"
    Print #4, "</Street>"
    rsStreets.MoveNext
  Loop
  Print #4, "</StreetErrors>"
  Print #4, "</AddressTest>"
End Sub

Private Sub GetLatLon(ByRef lat As String, ByRef lon As String, strCoords As String)
  Dim s() As String
  If strCoords <> "" Then
     s = Split(strCoords, ",")
     lat = Trim$(s(0))
     lon = Trim$(s(1))
  Else
     lat = ""
     lon = ""
  End If

End Sub

Private Function MakeJOSMLink(strCoords As String) As String
  'http://localhost:8111/load_and_zoom?top=58.409244&bottom=58.405244&left=15.650212&right=15.656212
   Dim lat As String
   Dim lon As String
   
   Const delta = 0.0001
   If strCoords <> "" Then
     GetLatLon lat, lon, strCoords
     MakeJOSMLink = "http://localhost:8111/load_and_zoom?top=" & lat + delta & "&bottom=" & lat - delta & "&left=" & lon - delta & "&right=" & lon + delta
   Else
     MakeJOSMLink = ""
   End If
End Function

Private Function MakeXmlString(str As String) As String
  str = Replace(str, "&", "&amp;")
  MakeXmlString = str
End Function
Private Function StrForFilter(ByVal str As String) As String
   StrForFilter = Replace(str, "'", "''")
End Function

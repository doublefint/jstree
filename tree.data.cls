/// Класс с тестовыми данными для отладки работы с деревом
/// с http://jstree.com
Class tree.data Extends (%Persistent, %Populate)
{

/// parent node
Relationship parent As tree.data [ Cardinality = one, Inverse = childs ];

Index parent On parent;

Relationship childs As tree.data [ Cardinality = many, Inverse = parent ];

/// node name
Property name As %String [ Required ];

/// Дополнительные данные для демонстрации работы на стороне браузера
/// Additional data for demo purpose
Property city As %String;

/// Есть ли у узла дочерние?
ClassMethod hasChildren(id As %String) As %Boolean
{
	s child="", id=$g(id)
	#;&sql(Select ID Into :child From tree.data Where parent=:id)	
	#;Q (SQLCODE=0)
	Q $d(^tree.dataI("parent",id))>0
}

/// Generate data for 3 level tree
ClassMethod init() As %Status
{
	d ..%KillExtent()
	
	s parent = ..%New("Belarus",,"")
	, sc = parent.%Save() 
	, pid = parent.%Id()
	
	s node = ..%New("Minskaya",pid,"Minsk")
	, sc = node.%Save() 
	
	s node = ..%New("Vitebskaya",pid,"Vitebsk")
	, sc = node.%Save() 
	
	s node = ..%New("Mogilevskaya",pid,"Mogilev")
	, sc = node.%Save() 
	
	s node = ..%New("Gomelskaya",pid,"Gomel")
	, sc = node.%Save() 
	
	s node = ..%New("Grodnenskaya", pid, "Grodno")
	, sc = node.%Save() 
	
	
	s node = ..%New("Brestskaya", pid, "Brest")
	, sc = node.%Save() 
	
	
	Q $$$OK
}

/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
/// 
/// <P>If this method returns an error then the object will not be created.
/// <p>It is passed the arguments provided in the %New call, there may be up to ten
/// of these arguments, <var>p1, p2, p3, p4, p5, p6, p7, p8, p9, p10</var>
Method %OnNew(name As %String, parent As %String = "", city As %String = "") As %Status [ Private, ProcedureBlock = 1 ]
{
	s ..name=$g(name), ..city=$g(city), parent=$g(parent)
	d:..%ExistsId(parent) ..parentSetObjectId(parent)
	Quit $$$OK
}

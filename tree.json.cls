/// Пример для Cache v5.2
/// Серверная часть - отдает данные для построения дерева
/// На клиенте плагин с http://jstree.com
Class tree.json Extends %CSP.Page
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "utf-8";

/// Название таблицы ( класса ) - просто декларация
Parameter TABLENAME = "tree.data";

/// Выбираемые поля - просто декларация
Parameter FIELDS = "ID,parent,name,city";

ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	
	#;если сессия не нужна - освобождаем как можно скорее
	d %session.Unlock() 
	
	m args=%request.Data
	
	#define g(%name) $g(args(%name,1))
	s mode=$$$g("mode")
	
	d ##class(tree.data).init()
	
	#; пример полной выгрузки данных за один проход
	if mode="all" {
		#; DEMO only
		d ##class(tree.data).init()
		
		w "["
		d ..wall( .args )
		w "]"
		
	} else { ;step by step
	
		#; пример поузловой загрузки 
		d ..w( .args )
		
	}
	
	Quit $$$OK
}

/// вывести все сразу
ClassMethod wall(ByRef args As %String = "") As %String
{
	s sql="Select "_..#FIELDS
		_" From "_..#TABLENAME
		
	s rs=..rs(sql)
	
	s first=1 for { Q:'rs.%Next()
		s id = rs.Get("ID") ;NOTE: версионно зависимый код
		
		w:'first "," s:first first=0 		
		d ..w1(id)
		
	}
	
	d rs.Close() ;NOTE: Версионно-зависимый код
	k rs
	Q ""
}

/// Вывод узлов от текущего
ClassMethod w(ByRef args As %String) As %String
{
	
	s sql="Select ID from "_..#TABLENAME, qp=""
	s where = ..where(.args,.qp) s:where'="" sql=sql_" Where "_where ;фильтрация
	s order = ..order(.args) s:order'="" sql=sql_" Order By "_order ;сортировка
	
	#;w sql
	
	s rs=..rs(sql,.qp)
	
	w "["
	s first=1 for { Q:'rs.Next()
		w:'first "," s:first first=0
		s id =rs.Get("ID") ;Версия Cache
		d ..w1(id,1)
	}
	w "]"
	d rs.Close() ;Версия Cache
	k rs 
	Q ""
}

/// Вывод одного узла по id в js
/// children - выводить наличие дочерних (для поузловой выгрузки)
ClassMethod w1(id As %String, children As %Boolean = 0) As %String
{
	
	w !,"{""id"":",id
	
	#; можно извращаться с разбором параметра ..#FIELDS
	#; но, кто плавал, знает ...
		
	#;надеемся на то, что в name нет спецсимволов, кавычек и слэшей
	#; обратите внимание на text <-> name
	s name = ##class(tree.data).nameGetStored(id) 
	w ",""text"":""",name,"""" 
	
	#; узлу дерева необходим только id и надпись и id родительского узла
	s parent = ##class(tree.data).parentGetStored(id)
	s:parent="" parent="#" ;!!! особенность jstree
	w ",""parent"":""",parent,"""" 
	
	if children {
		#; для варианта с поузловой загрузкой 
		#; клиенту необходим признак наличия дочерних узлов
		s hasChildren = ##class(tree.data).hasChildren(id)
		w ",""children"":", $S( hasChildren = 1: "true", 1: "false" )
	}
	
	#; узлу дерева необходим только id и надпись
	#; поэтому дополнительные данные выводятся в отдельном объекте
	w ",""data"": {"	
		s city = ##class(tree.data).cityGetStored(id)
		w " ""city"": """,city,""""
	w "}"
		
	w "}"
	
	Q ""
}

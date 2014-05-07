/// Пример работы с jstree на клиенте
Class tree.web Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	&html<<!DOCTYPE html>
	<html><head><title>Cache+jstree example</title>
	
	<link href="js/jstree-3.0.0/themes/default/style.min.css" type='text/css' rel='stylesheet' />
	
	<style>
	 .block {min-width:200px; max-width:350px; max-height:200px; overflow: auto; }
	 .col {float:left;}
	</style>
	
	<script type="text/javascript" src='js/jquery-1.11.0.min.js'></script>
	<script type="text/javascript" src='js/jstree-3.0.0/jstree.min.js'></script>

	</head><body>
		
		<div class='col'>FULL MODE
			<div id='jstree_full' class='block'></div>
			<button id='btnReload'>Reload</button>
		</div>
		
		<div class='col'>AJAX MODE
			<div id='jstree_ajax' class='block'></div>
			<label for='city'>Город: </label><input id='city' readonly='true'>
		</div>
		
	</body>
	<script type='text/javascript'> $(function(){
			
			var treeFull = $('#jstree_full').jstree({
				'core' : {
					'data' : [
					
					#(##class(tree.json).wall())#
						
					]
				}
			}).jstree('open_all');
			
			$("#btnReload").on('click',function(){
				
				var data = treeFull.jstree(true).settings.core.data;
				//console.log( data );
				treeFull.jstree(true).settings.core.data = [
					{id:1,text:"Беларусь",parent:'#'}
					,{id:2,text:"Минская",parent:1}
					,{id:3,text:"Гродненская",parent:1}
					,{id:4,text:"Могилевская",parent:1}
					,{id:5,text:"Витебская",parent:1}
					,{id:6,text:"Гомельская",parent:1}
					,{id:7,text:"Брестская",parent:1}
				];
    			treeFull.jstree("refresh");
    			
			});
			
			
			/*Загрузка через собственную функцию*/
			$('#jstree_ajax').jstree({
				'core' : {
					'data' : function( node, callback ){
					
						var tree=this
							, id=(node.id=='#')?'':node.id
						;
					
						$.ajax({ url:'#(..Link("tree.json.cls"))#'
							,data: { 
								parent: id 
								,mode: 'nodebynode'
							}
						}).done(function( nodedata ){
							
							callback.call(tree, nodedata);
							
						});
					}	
				}	
			}).on("select_node.jstree", function(e, obj){
				
				$('#city').val(obj.node.data['city']);
				
			});
			
				
		});
		
	</script>
	</html>>
	Quit $$$OK
}

}

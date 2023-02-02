<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>座位列表</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
		//datagrid初始化 
	    $('#dataList').datagrid({ 
	        title:'座位列表',
	        iconCls:'icon-more',//图标 
	        border: true, 
	        collapsible: false,//是否可折叠的 
	        fit: true,//自动大小 
	        method: "post",
	        url:"SeatsServlet?oper=getSeatsList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect: true,//是否单选 
	        pagination: true,//分页控件 
	        rownumbers: true,//行号
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50},
 		        {field:'roomId',title:'自习室id',width:100,hidden:true},
 		        {field:'roomName',title:'自习室名称',width:100},
 		        {field:'rows',title:'第几排',width:100,hidden:true},
 		        {field:'cols',title:'第几列',width:100,hidden:true},
 		        {field:'rowsCols',title:'位置',width:100,
					formatter: function(value,row,index){
						return "第"+row.rows+"排第"+row.cols+"列"
					}
				},
	 		]],
	        toolbar: "#toolbar"
	    });

	    //设置分页控件 
	    var p = $('#dataList').datagrid('getPager'); 
	    $(p).pagination({ 
	        pageSize: 10,//每页显示的记录条数，默认为10 
	        pageList: [10,20,30,50,100],//可以设置每页记录条数的列表 
	        beforePageText: '第',//页数文本框前显示的汉字 
	        afterPageText: '页    共 {pages} 页', 
	        displayMsg: '当前显示 {from} - {to} 条记录   共 {total} 条记录', 
	    });

	    //设置工具类按钮
	    $("#add").click(function(){
	    	$("#addDialog").dialog("open");
	    });

	    //删除
	    $("#delete").click(function(){
	    	var selectRow = $("#dataList").datagrid("getSelected");
	    	//console.log(selectRow);
        	if(selectRow == null){
            	$.messager.alert("消息提醒", "请选择数据进行删除!", "warning");
            } else{
            	var SeatsId = selectRow.id;
            	$.messager.confirm("消息提醒", "确认删除？", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "SeatsServlet?oper=DeleteSeats",
							data: {id: SeatsId},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("消息提醒","删除成功!","info");
									//刷新表格
									$("#dataList").datagrid("reload");
								} else{
									$.messager.alert("消息提醒","删除失败!","warning");
									return;
								}
							}
						});
            		}
            	});
            }
	    });

	  	//设置添加自习室窗口
	    $("#addDialog").dialog({
	    	title: "添加座位",
	    	width: 500,
	    	height: 400,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'添加',
					plain: true,
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						} else{
							//var gradeid = $("#add_gradeList").combobox("getValue");
							$.ajax({
								type: "post",
								url: "SeatsServlet?oper=AddSeats",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","添加成功!","info");
										//关闭窗口
										$("#addDialog").dialog("close");
										//清空原表格数据
										$("#add_id").textbox('setValue', "");
										$("#add_room").combobox('setValue', "");
										$("#add_rows").combobox('setValue', "");
										$("#add_cols").combobox('setValue', "");
										//重新刷新页面数据
							  			$('#dataList').datagrid("reload");
										
									} else{
										$.messager.alert("消息提醒",msg,"warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'重置',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						$("#add_id").textbox('setValue', "");
						$("#add_room").combobox('setValue', "");
						$("#add_rows").combobox('setValue', "");
						$("#add_cols").combobox('setValue', "");
					}
				},
			]
	    });

		//新增操作会议室下拉
		$("#add_room").combobox({
			url: "RoomServlet?oper=getRoomList&t="+new Date().getTime()+"&from=combox&isEnable=1",
			editable: true,
			valueField: 'id',
			textField: 'name',
			onLoadSuccess: function(){
				console.log("自习室加载成功");
			},
			onSelect: function(rec) {//当选中combobox中的内容时候触发的事件 类似与change事件 参数rec 为当前选中项目的json 类型的数据  json中的键和值 应与  valueField和textField属性中的值一致 如 rec.id 为当前选中项的 id
				var rowDatas = [];
				var colDatas = [];
				var rows = 0;
				var cols = 0;
				$.ajax({
					type: "post",
					url: "RoomServlet?oper=getRoomList",
					data: {id: rec.id},
					async: false,
					success: function(data){
						const dataObj = eval("("+data+")");
						rows = dataObj.rows[0].rows;
						cols = dataObj.rows[0].cols;
					}
				});

				//初始化排数据
				$('#add_rows').combobox({
					textField:'name',
					valueField:'val',
					width:90
				});
				for (let i = 0; i < rows; i++) {
					const rowData = {
						"name": i+1,
						"val": i+1
					};
					rowDatas.push(rowData);
				}
				$('#add_rows').combobox('clear').combobox('loadData',rowDatas);

				//初始化列数据
				$('#add_cols').combobox({
					textField:'name',
					valueField:'val',
					width:90
				});
				for (let i = 0; i < rows; i++) {
					const rowData = {
						"name": i+1,
						"val": i+1
					};
					colDatas.push(rowData);
				}
				$('#add_cols').combobox('clear').combobox('loadData',rowDatas);
			}
		});

		/**
		 * 编辑操作-自习室下拉
		 */
		$("#edit_room").combobox({
			url: "RoomServlet?oper=getRoomList&t="+new Date().getTime()+"&from=combox",
			editable: true,
			valueField: 'id',
			textField: 'name'
		});

		/**
		 * 搜索框下拉
		 */
		$("#search_name").combobox({
			url: "RoomServlet?oper=getRoomList&t="+new Date().getTime()+"&from=combox",
			editable: true,
			valueField: 'id',
			textField: 'name'
		}),

	  	//搜索按钮监听事件
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			roomId: $('#search_name').combobox('getValue')
	  		});
	  	});
	  	
	  //修改按钮监听事件
	  	$("#edit-btn").click(function(){
	  		var selectRow = $("#dataList").datagrid("getSelected");
        	if(selectRow == null){
            	$.messager.alert("消息提醒", "请选择数据进行修改!", "warning");
            	return;
            }
        	$("#editDialog").dialog("open");
	  	});
	  
	  //设置编辑自习室窗口
	    $("#editDialog").dialog({
	    	title: "编辑自习室",
	    	width: 500,
	    	height: 400,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'确定修改',
					plain: true,
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#editForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						} else{
							//var gradeid = $("#add_gradeList").combobox("getValue");
							$.ajax({
								type: "post",
								url: "SeatsServlet?oper=EditSeats",
								data: {
									id: $("#edit_id").val(),
									rows: $("#edit_rows").combobox('getValue'),
									cols: $("#edit_cols").combobox('getValue'),
									roomId: $("#edit_room").combobox('getValue')
								},
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","修改成功!","info");
										//关闭窗口
										$("#editDialog").dialog("close");
										//清空原表格数据
										$("#edit_id").textbox('setValue', "");
										$("#edit_room").combobox('setValue', "");
										$("#edit_rows").combobox('setValue', "");
										$("#edit_cols").combobox('setValue', "");
										//重新刷新页面数据
							  			$('#dataList').datagrid("reload");
										
									} else{
										$.messager.alert("消息提醒",msg,"warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'重置',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						$("#edit_id").textbox('setValue', "");
						$("#edit_room").combobox('setValue', "");
						$("#edit_rows").combobox('setValue', "");
						$("#edit_cols").combobox('setValue', "");
					}
				},
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");

				//初始化排列数据
				var rowDatas = [];
				var colDatas = [];
				var rows = 0;
				var cols = 0;
				$.ajax({
					type: "post",
					url: "RoomServlet?oper=getRoomList",
					data: {id: selectRow.roomId},
					async: false,
					success: function(data){
						const dataObj = eval("("+data+")");
						rows = dataObj.rows[0].rows;
						cols = dataObj.rows[0].cols;
					}
				});

				//初始化排数据
				$('#edit_rows').combobox({
					textField:'name',
					valueField:'val',
					width:90
				});
				for (let i = 0; i < rows; i++) {
					const rowData = {
						"name": i+1,
						"val": i+1
					};
					rowDatas.push(rowData);
				}
				$('#edit_rows').combobox('clear').combobox('loadData',rowDatas);

				//初始化列数据
				$('#edit_cols').combobox({
					textField:'name',
					valueField:'val',
					width:90
				});
				for (let i = 0; i < rows; i++) {
					const rowData = {
						"name": i+1,
						"val": i+1
					};
					colDatas.push(rowData);
				}
				$('#edit_cols').combobox('clear').combobox('loadData',rowDatas);

				//设置值
				$("#edit_room").combobox('setValue', selectRow.roomId);
				$("#edit_id").textbox('setValue', selectRow.id);
				$("#edit_rows").combobox('setValue', selectRow.rows);
				$("#edit_cols").combobox('setValue', selectRow.cols);
			}
	    });
	  
	});
	</script>
</head>
<body>
	<!-- 数据列表 -->
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	</table> 
	
	<!-- 工具栏 -->
	<div id="toolbar">
	<c:if test="${userType == 1 }">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">添加</a></div>
	</c:if>
	<c:if test="${userType == 1 }">
		<div style="float: left; margin-right: 10px;"><a id="edit-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">修改</a></div>
	</c:if>
	<c:if test="${userType == 1 }">
		<div style="float: left; margin-right: 10px;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">删除</a></div>
	</c:if>
		<div style="margin-top: 3px;">
			自习室名称：
			<select id="search_name" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="roomId">
				<option></option>
			</select>
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
		</div>
	</div>
	
	<!-- 添加窗口 -->
	<div id="addDialog" style="padding: 10px">  
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>自习室:</td>
					<td>
						<select id="add_room" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="roomId">
							<option></option>
						</select>
					</td>
				</tr>
	    		<tr>
	    			<td>位置:</td>
					<td>
						<select id="add_rows" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="rows">
							<option></option>
						</select>排
					</td>
					<td>
						<select id="add_cols" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="cols">
							<option></option>
						</select>列
					</td>
					</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<!-- 编辑窗口 -->
	<div id="editDialog" style="padding: 10px">  
    	<form id="editForm" method="post">
	    	<table cellpadding="8" >
				<tr hidden="true">
					<td>id:</td>
					<td><input id="edit_id" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="id"  hidden="true"/></td>
				</tr>
				<tr>
					<td>自习室:</td>
					<td>
						<select id="edit_room" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="roomId">
							<option></option>
						</select>
					</td>
				</tr>
				<tr>
					<td>位置:</td>
					<td>
						<select id="edit_rows" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="rows">
							<option></option>
						</select>排
					</td>
					<td>
						<select id="edit_cols" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="cols">
							<option></option>
						</select>列
					</td>
					</td>
				</tr>
	    	</table>
	    </form>
	</div>
	
</body>
</html>
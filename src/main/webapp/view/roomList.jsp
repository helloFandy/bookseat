<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>自习室列表</title>
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
	        title:'自习室列表', 
	        iconCls:'icon-more',//图标 
	        border: true, 
	        collapsible: false,//是否可折叠的 
	        fit: true,//自动大小 
	        method: "post",
	        url:"RoomServlet?oper=getRoomList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect: true,//是否单选 
	        pagination: true,//分页控件 
	        rownumbers: true,//行号 
	        sortName: 'id',
	        sortOrder: 'DESC', 
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50, sortable: true},    
 		        {field:'name',title:'自习室名称',width:200},
 		        {field:'location',title:'自习室位置',width:100},
 		        {field:'rows',title:'自习室排数',width:100,hidden:true},
 		        {field:'cols',title:'自习室列数',width:100,hidden:true},
 		        {field:'rowsCols',title:'规格',width:100,
					formatter: function(value,row,index){
						return row.rows+"排X"+row.cols+"列"
					},
				},
 		        {field:'isEnable',title:'是否可用',width:100,
					formatter: function(value,row,index){
						if (value == 2){
							return '不可用';
						} else if (value == 1){
							return '可用';
						}else {
							return 'not found'
						}
					}},
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
            	var roomId = selectRow.id;
            	$.messager.confirm("消息提醒", "确认删除？", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "RoomServlet?oper=DeleteRoom",
							data: {id: roomId},
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
	    	title: "添加自习室",
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
								url: "RoomServlet?oper=AddRoom",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","添加成功!","info");
										//关闭窗口
										$("#addDialog").dialog("close");
										//清空原表格数据
										$("#add_name").textbox('setValue', "");
										$("#info").val("");
										//重新刷新页面数据
							  			//$('#gradeList').combobox("setValue", gradeid);
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
						$("#add_name").textbox('setValue', "");
						//重新加载年级
						$("#info").val("");
					}
				},
			]
	    });

	  	//搜索按钮监听事件
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			name: $('#search_name').val(),
	  			isEnable: $("#search_isEnable").combobox('getValue')
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
								url: "RoomServlet?oper=EditRoom",
								data: {
									id: $("#edit_id").val(),
									name: $("#edit_name").val(),
									location: $("#edit_location").val(),
									isEnable: $("#edit_isEnable").combobox('getValue'),
									cols: $("#edit_cols").combobox('getValue'),
									rows: $("#edit_rows").combobox('getValue')
								},
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","修改成功!","info");
										//关闭窗口
										$("#editDialog").dialog("close");
										//清空原表格数据
										$("#edit_id").textbox('setValue', "");
										$("#edit_name").textbox('setValue', "");
										$("#edit_location").textbox('setValue', "");
										$("#edit_isEnable").combobox('setValue', "");
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
						$("#edit_name").textbox('setValue', "");
						$("#edit_id").textbox('setValue', "");
						$("#edit_location").textbox('setValue', "");
						$("#edit_isEnable").combobox('setValue', "");
						$("#edit_rows").combobox('setValue', "");
						$("#edit_cols").combobox('setValue', "");
					}
				},
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");
				//设置值
				$("#edit_name").textbox('setValue', selectRow.name);
				$("#edit_id").textbox('setValue', selectRow.id);
				$("#edit_location").textbox('setValue',selectRow.location);
				$("#edit_isEnable").combobox('setValue', selectRow.isEnable);
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
			自习室名称：<input id="search_name" class="easyui-textbox" name="name" />
			是否可用：
				<select id="search_isEnable" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="isEnable">
					<option></option>
					<option value="1">可用</option>
					<option value="2">不可用</option>
				</select>
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
		</div>
	</div>
	
	<!-- 添加窗口 -->
	<div id="addDialog" style="padding: 10px">  
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>自习室名称:</td>
	    			<td><input id="add_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name"  data-options="required:true, missingMessage:'不能为空'" /></td>
	    		</tr>
	    		<tr>
	    			<td>自习室位置:</td>
	    			<td>
						<input id="add_location" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="location"  data-options="required:true, missingMessage:'不能为空'" /></td>
	    			</td>
	    		</tr>
				<tr>
					<td>规格:</td>
					<td>
						<select id="add_rows" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="rows">
							<option></option>
							<option value="1">1排</option>
							<option value="2">2排</option>
							<option value="3">3排</option>
							<option value="4">4排</option>
							<option value="5">5排</option>
							<option value="6">6排</option>
							<option value="7">7排</option>
							<option value="8">8排</option>
							<option value="9">9排</option>
							<option value="10">10排</option>
						</select>
					</td>
					<td>
						<select id="add_cols" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="cols">
							<option></option>
							<option value="1">1列</option>
							<option value="2">2列</option>
							<option value="3">3列</option>
							<option value="4">4列</option>
							<option value="5">5列</option>
							<option value="6">6列</option>
							<option value="7">7列</option>
							<option value="8">8列</option>
							<option value="9">9列</option>
							<option value="10">10列</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>是否可用:</td>
					<td>
						<select id="add_isEnable" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="isEnable">
							<option></option>
							<option value="1">可用</option>
							<option value="2">不可用</option>
						</select>
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
	    			<td>自习室名称:</td>
	    			<td><input id="edit_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name"  data-options="required:true, missingMessage:'不能为空'" /></td>
	    		</tr>
	    		<tr>
	    			<td>自习室位置:</td>
	    			<td>
						<input id="edit_location" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="location"  data-options="required:true, missingMessage:'不能为空'" /></td>
	    			</td>
	    		</tr>
				<tr>
					<td>规格:</td>
					<td>
						<select id="edit_rows" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="rows">
							<option></option>
							<option value="1">1排</option>
							<option value="2">2排</option>
							<option value="3">3排</option>
							<option value="4">4排</option>
							<option value="5">5排</option>
							<option value="6">6排</option>
							<option value="7">7排</option>
							<option value="8">8排</option>
							<option value="9">9排</option>
							<option value="10">10排</option>
						</select>
					</td>
					<td>
						<select id="edit_cols" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="cols">
							<option></option>
							<option value="1">1列</option>
							<option value="2">2列</option>
							<option value="3">3列</option>
							<option value="4">4列</option>
							<option value="5">5列</option>
							<option value="6">6列</option>
							<option value="7">7列</option>
							<option value="8">8列</option>
							<option value="9">9列</option>
							<option value="10">10列</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>是否可用:</td>
					<td>
						<select id="edit_isEnable" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="isEnable">
							<option></option>
							<option value=1>可用</option>
							<option value=2>不可用</option>
						</select>
					</td>
				</tr>
	    	</table>
	    </form>
	</div>
	
</body>
</html>